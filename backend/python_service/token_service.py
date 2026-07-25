"""
Python Token Service – Token Generation Service

Wraps the existing Phase 8 SessionTokenGenerator in a thread-safe singleton
that is initialised once at application startup and reused for every request.

This module is the ONLY bridge between the FastAPI layer and the entropy
pipeline.  It does NOT perform authentication, database access, or any
business logic.
"""

import sys
import os
import time
import logging
import threading
from typing import Optional, Dict, Any

# ── Path setup so sibling packages (session_token_engine, …) are importable ──
_BACKEND_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _BACKEND_ROOT not in sys.path:
    sys.path.insert(0, _BACKEND_ROOT)

# ── Phase 2: Video Ingestion ────────────────────────────────────────
from aquarium_pipeline import PipelineConfig, VideoPlayer

# ── Phase 3: CV Feature Extraction ──────────────────────────────────
from cv_engine.config import CVEngineConfig
from cv_engine.feature_extractor import FeatureExtractor

# ── Phase 4: Entropy Engine ─────────────────────────────────────────
from entropy_engine.config import EntropyConfig
from entropy_engine.feature_normalizer import FeatureNormalizer
from entropy_engine.entropy_collector import EntropyCollector
from entropy_engine.entropy_metrics import EntropyMetricsCalculator
from entropy_engine.entropy_pool import EntropyPool

# ── Phase 5: Entropy Mixer ──────────────────────────────────────────
from entropy_mixer.config import MixerConfig
from entropy_mixer.entropy_mixer import EntropyMixer

# ── Phase 6: Crypto Conditioner ─────────────────────────────────────
from crypto_conditioner.config import ConditionerConfig
from crypto_conditioner.entropy_conditioner import EntropyConditioner
from crypto_conditioner.sha3_conditioner import Sha3Conditioner
from crypto_conditioner.blake3_conditioner import Blake3Conditioner

# ── Phase 7: ChaCha20 CSPRNG ───────────────────────────────────────
from csprng.config import CSPRNGConfig
from csprng.seed_manager import SeedManager
from csprng.chacha20_csprng import ChaCha20Csprng
from csprng.random_generator import RandomByteGenerator
from csprng.reseed_manager import ReseedManager
from csprng.health_monitor import CsprngHealthMonitor

# ── Phase 8: Session Token Engine ──────────────────────────────────
from session_token_engine.config import SessionTokenConfig
from session_token_engine.token_generator import TokenGenerator
from session_token_engine.session_token import SessionTokenGenerator, SessionToken
from session_token_engine.health_monitor import TokenHealthMonitor

from .config import ServiceConfig

logger = logging.getLogger("TokenService")


class AquariumTokenService:
    """
    Singleton-style service that owns the full Aquarium Entropy pipeline
    (Phases 2-8) and exposes a single ``generate()`` method.

    Designed for:
    • One-time initialisation via ``startup()``
    • Thread-safe concurrent ``generate()`` calls from FastAPI workers
    • Clean shutdown via ``shutdown()``
    """

    def __init__(self, service_cfg: ServiceConfig) -> None:
        self._service_cfg = service_cfg
        self._session_gen: Optional[SessionTokenGenerator] = None
        self._health_mon: Optional[TokenHealthMonitor] = None
        self._player: Optional[VideoPlayer] = None
        self._reseed_mgr: Optional[ReseedManager] = None
        self._entropy_thread: Optional[threading.Thread] = None
        self._stop_event = threading.Event()
        self._ready = False

    # ── Lifecycle ───────────────────────────────────────────────────

    def startup(self) -> None:
        """Boot the full entropy pipeline (Phases 2-8). Blocks until
        the CSPRNG has been seeded and the session token engine is online."""

        logger.info(
            "Initialising full Aquarium Pipeline (Phases 2-8): "
            "Video → CV → Entropy → Mixer → Conditioner → CSPRNG → Tokens …"
        )

        # ── Configurations ──────────────────────────────────────────
        pipeline_cfg = PipelineConfig()
        cv_cfg = CVEngineConfig()
        cv_cfg.enable_visualization = False   # headless service

        entropy_cfg = EntropyConfig()
        mixer_cfg = MixerConfig()
        cond_cfg = ConditionerConfig()

        csprng_cfg = CSPRNGConfig()
        csprng_cfg.reseed_interval = 10.0     # fast reseed

        session_cfg = SessionTokenConfig()

        # ── Phase 2-3: Video + CV ───────────────────────────────────
        self._player = VideoPlayer(pipeline_cfg)
        extractor = FeatureExtractor(cv_cfg)

        # ── Phase 4: Entropy Pool ───────────────────────────────────
        normalizer = FeatureNormalizer(entropy_cfg)
        collector = EntropyCollector(entropy_cfg)
        metrics_calc = EntropyMetricsCalculator(entropy_cfg)
        pool = EntropyPool(entropy_cfg)

        # ── Phase 5: Mixer ──────────────────────────────────────────
        mixer = EntropyMixer(mixer_cfg, pool)

        # ── Phase 6: Conditioner ────────────────────────────────────
        conditioner = EntropyConditioner()
        if cond_cfg.algorithm == "BLAKE3":
            hash_engine = Blake3Conditioner()
        else:
            hash_engine = Sha3Conditioner()

        def fetch_fresh_seed() -> str:
            combined = mixer.collect_all_entropy()
            serialized = conditioner.serialize(combined)
            conditioned = hash_engine.condition(serialized)
            return conditioned["digest"]

        # ── Phase 7: CSPRNG (initial seed) ──────────────────────────
        seed_manager = SeedManager()
        self._player.start()

        logger.info("Gathering initial entropy to seed CSPRNG …")
        initial_seed_hex: Optional[str] = None
        while initial_seed_hex is None:
            frame_package = self._player.get_next_frame(timeout=1.0)
            if frame_package is not None:
                frame, metadata = frame_package
                feature_vector, _ = extractor.process_frame(frame, metadata)
                norm_features = normalizer.normalize(feature_vector)
                entropy_scores = metrics_calc.calculate_contributions(norm_features)
                pool.accumulate(entropy_scores)
                initial_seed_hex = fetch_fresh_seed()
            time.sleep(0.05)

        seed_manager.load_seed(initial_seed_hex)
        csprng = ChaCha20Csprng(seed_manager)
        generator = RandomByteGenerator(csprng)
        self._reseed_mgr = ReseedManager(
            csprng_cfg, seed_manager, csprng, fetch_fresh_seed
        )

        logger.info("Phase 7 CSPRNG online.")

        # ── Phase 8: Session Token Engine ───────────────────────────
        token_gen = TokenGenerator(generator)
        self._session_gen = SessionTokenGenerator(token_gen, session_cfg)
        self._health_mon = TokenHealthMonitor(session_cfg)

        # ── Background entropy feeder thread ────────────────────────
        # Continuously feeds video frames into the entropy pool and
        # triggers CSPRNG reseed checks so the keystream stays fresh.
        def _entropy_feed_loop() -> None:
            while not self._stop_event.is_set():
                try:
                    frame_package = self._player.get_next_frame(timeout=0.5)
                    if frame_package is not None:
                        frame, metadata = frame_package
                        fv, _ = extractor.process_frame(frame, metadata)
                        nf = normalizer.normalize(fv)
                        es = metrics_calc.calculate_contributions(nf)
                        pool.accumulate(es)
                    self._reseed_mgr.check_and_reseed()
                except Exception:
                    logger.exception("Entropy feed error (non-fatal)")
                time.sleep(0.1)

        self._entropy_thread = threading.Thread(
            target=_entropy_feed_loop, daemon=True, name="entropy-feeder"
        )
        self._entropy_thread.start()

        self._ready = True
        logger.info("Aquarium Token Service is READY.")

    def shutdown(self) -> None:
        """Gracefully stop the entropy pipeline."""
        logger.info("Shutting down Aquarium Token Service …")
        self._stop_event.set()
        if self._entropy_thread and self._entropy_thread.is_alive():
            self._entropy_thread.join(timeout=5.0)
        if self._player:
            self._player.close()
        self._ready = False
        logger.info("Token Service shut down successfully.")

    # ── Public API ──────────────────────────────────────────────────

    @property
    def is_ready(self) -> bool:
        return self._ready

    def generate(self) -> Dict[str, Any]:
        """
        Generate a single session token through the existing Phase 8
        pipeline and return a serialisable dictionary.

        Returns:
            {
                "token":        "…",
                "algorithm":    "ChaCha20 CSPRNG",
                "generated_at": "…",
                "expires_in":   1800
            }

        Raises:
            RuntimeError: If the service has not been started.
        """
        if not self._ready or self._session_gen is None:
            raise RuntimeError("Token service is not initialised.")

        session_token, elapsed_ms = self._session_gen.generate()
        self._health_mon.record_generation(elapsed_ms)

        return {
            "token": session_token.token,
            "algorithm": session_token.algorithm,
            "generated_at": session_token.created_at,
            "expires_in": self._service_cfg.token_expires_in,
            "generation_time_ms": round(elapsed_ms, 3),
        }
