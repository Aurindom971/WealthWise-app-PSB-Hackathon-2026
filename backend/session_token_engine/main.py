"""
Phase 8 – Secure Session Token Generation Engine :: Live Dashboard

Boots the full pipeline (Phases 2-7), obtains a RandomByteGenerator from
the Phase 7 ChaCha20 CSPRNG, and runs a continuous session-token generation
loop with a live terminal HUD.

Usage:
    cd backend
    python -m session_token_engine.main
"""

import sys
import os
import time
import logging

# ── Path Setup ──────────────────────────────────────────────────────
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

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

# ── Phase 8: Session Token Engine ───────────────────────────────────
from session_token_engine.config import SessionTokenConfig
from session_token_engine.token_generator import TokenGenerator
from session_token_engine.session_token import SessionTokenGenerator
from session_token_engine.validator import TokenValidator
from session_token_engine.health_monitor import TokenHealthMonitor
from session_token_engine.utils import mask_token

# ── Logger ──────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("SessionTokenEngine.Main")


# ════════════════════════════════════════════════════════════════════
#  LIVE DASHBOARD
# ════════════════════════════════════════════════════════════════════

def print_session_token_dashboard(
    token_stats: dict,
    csprng_stats: dict,
    latest_token_preview: str,
    latest_validation: str,
    cfg: SessionTokenConfig,
) -> None:
    """Render the live terminal HUD for the Session Token Engine."""
    print("=" * 70)
    print("      SECURE SESSION TOKEN GENERATION ENGINE — LIVE DASHBOARD")
    print("=" * 70)

    # ── Generator Status ────────────────────────────────────────────
    print(f"  Generator Status:        {token_stats['generator_status']}")
    print(f"  Generator Health:        {token_stats['generator_health']}")
    print(f"  Algorithm:               {cfg.algorithm_name}")
    print(f"  Current Encoding:        {token_stats['current_encoding']}")
    print("-" * 70)

    # ── Token Statistics ────────────────────────────────────────────
    print(f"  Tokens Generated:        {token_stats['total_tokens_generated']}")
    print(f"  Generation Rate:         {token_stats['generation_rate_tps']:.2f} tokens/sec")
    print(f"  Avg Generation Time:     {token_stats['average_generation_time_ms']:.3f} ms")
    print(f"  Errors:                  {token_stats['total_errors']}")
    print(f"  Last Generated:          {token_stats['last_generation_timestamp']}")
    print(f"  Uptime:                  {token_stats['uptime_seconds']:.1f} seconds")
    print("-" * 70)

    # ── Latest Token (masked) ───────────────────────────────────────
    print(f"  Latest Token Preview:    {latest_token_preview}")
    print(f"  Validation:              {latest_validation}")
    print("-" * 70)

    # ── Underlying CSPRNG Status ────────────────────────────────────
    print(f"  CSPRNG Health:           {csprng_stats['generator_health']}")
    print(f"  CSPRNG Reseed Count:     {csprng_stats['reseed_count']}")
    print(f"  CSPRNG Bytes Generated:  {csprng_stats['bytes_generated']} bytes")
    print(f"  CSPRNG Generation Rate:  {csprng_stats['generation_rate_bps']:.2f} B/s")
    print("=" * 70)


# ════════════════════════════════════════════════════════════════════
#  PUBLIC API  –  generate_session_token()
# ════════════════════════════════════════════════════════════════════

# Module-level reference populated by main() for import convenience
_session_token_generator: SessionTokenGenerator = None  # type: ignore[assignment]
_token_health_monitor: TokenHealthMonitor = None  # type: ignore[assignment]


def generate_session_token() -> dict:
    """
    Public API — Generate a single session token and return a
    serialisable dictionary.

    Returns:
        {
            "token": "...",
            "encoding": "base64url",
            "length": 256,
            "timestamp": "...",
            "algorithm": "ChaCha20 CSPRNG"
        }
    """
    if _session_token_generator is None:
        raise RuntimeError(
            "Session token engine has not been initialised. "
            "Call main() or initialise the pipeline first."
        )
    token, elapsed_ms = _session_token_generator.generate()
    _token_health_monitor.record_generation(elapsed_ms)
    return SessionTokenGenerator.to_dict(token)


# ════════════════════════════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════════════════════════════

def main() -> None:
    global _session_token_generator, _token_health_monitor

    logger.info(
        "Initialising Full Pipeline (Phases 2-8): "
        "Video → CV → Entropy → Mixer → Conditioner → CSPRNG → Session Tokens …"
    )

    # ── Configurations ──────────────────────────────────────────────
    pipeline_cfg = PipelineConfig()
    cv_cfg = CVEngineConfig()
    cv_cfg.enable_visualization = False

    entropy_cfg = EntropyConfig()
    mixer_cfg = MixerConfig()
    cond_cfg = ConditionerConfig()

    csprng_cfg = CSPRNGConfig()
    csprng_cfg.reseed_interval = 10.0  # fast reseed for demo

    session_cfg = SessionTokenConfig()

    # ── Phase 2-3: Video + CV ───────────────────────────────────────
    player = VideoPlayer(pipeline_cfg)
    extractor = FeatureExtractor(cv_cfg)

    # ── Phase 4: Entropy Pool ───────────────────────────────────────
    normalizer = FeatureNormalizer(entropy_cfg)
    collector = EntropyCollector(entropy_cfg)
    metrics_calc = EntropyMetricsCalculator(entropy_cfg)
    pool = EntropyPool(entropy_cfg)

    # ── Phase 5: Mixer ──────────────────────────────────────────────
    mixer = EntropyMixer(mixer_cfg, pool)

    # ── Phase 6: Conditioner ────────────────────────────────────────
    conditioner = EntropyConditioner()
    if cond_cfg.algorithm == "BLAKE3":
        hash_engine = Blake3Conditioner()
    else:
        hash_engine = Sha3Conditioner()

    def fetch_fresh_seed_callback() -> str:
        combined = mixer.collect_all_entropy()
        serialized = conditioner.serialize(combined)
        conditioned = hash_engine.condition(serialized)
        return conditioned["digest"]

    # ── Phase 7: CSPRNG ─────────────────────────────────────────────
    seed_manager = SeedManager()
    player.start()

    logger.info("Gathering initial entropy to seed CSPRNG …")
    initial_seed_hex = None
    while initial_seed_hex is None:
        frame_package = player.get_next_frame(timeout=1.0)
        if frame_package is not None:
            frame, metadata = frame_package
            feature_vector, _ = extractor.process_frame(frame, metadata)
            norm_features = normalizer.normalize(feature_vector)
            entropy_scores = metrics_calc.calculate_contributions(norm_features)
            pool.accumulate(entropy_scores)
            initial_seed_hex = fetch_fresh_seed_callback()
        time.sleep(0.05)

    seed_manager.load_seed(initial_seed_hex)
    csprng = ChaCha20Csprng(seed_manager)
    generator = RandomByteGenerator(csprng)
    reseed_mgr = ReseedManager(csprng_cfg, seed_manager, csprng, fetch_fresh_seed_callback)
    csprng_monitor = CsprngHealthMonitor(csprng_cfg, seed_manager, generator, reseed_mgr)

    logger.info("Phase 7 CSPRNG online. Initialising Phase 8 Session Token Engine …")

    # ── Phase 8: Session Token Engine ───────────────────────────────
    token_gen = TokenGenerator(generator)
    session_gen = SessionTokenGenerator(token_gen, session_cfg)
    validator = TokenValidator(
        min_token_bits=session_cfg.min_token_bits,
        preview_len=session_cfg.max_token_preview_chars,
    )
    health_mon = TokenHealthMonitor(session_cfg)

    # Expose for the public API
    _session_token_generator = session_gen
    _token_health_monitor = health_mon

    logger.info("Session Token Engine online. Starting live dashboard …")

    # ── Main Loop ───────────────────────────────────────────────────
    try:
        while True:
            # 1. Feed entropy pool from video frames
            frame_package = player.get_next_frame(timeout=0.5)
            if frame_package is not None:
                frame, metadata = frame_package
                feature_vector, _ = extractor.process_frame(frame, metadata)
                norm_features = normalizer.normalize(feature_vector)
                entropy_scores = metrics_calc.calculate_contributions(norm_features)
                pool.accumulate(entropy_scores)

            # 2. CSPRNG reseed check
            reseed_mgr.check_and_reseed()

            # 3. Generate a session token
            try:
                session_token, elapsed_ms = session_gen.generate()
                health_mon.record_generation(elapsed_ms)

                # 4. Validate the generated token
                validation = validator.validate(
                    session_token.token, session_token.encoding
                )
                validation_str = (
                    "✔ Valid"
                    if validation.is_valid
                    else f"✘ Invalid: {'; '.join(validation.errors)}"
                )

                # 5. Mask the token for display
                preview = mask_token(
                    session_token.token,
                    session_cfg.max_token_preview_chars,
                )

            except Exception as exc:
                health_mon.record_error()
                logger.error("Token generation error: %s", exc)
                preview = "ERROR"
                validation_str = str(exc)

            # 6. Render dashboard
            token_stats = health_mon.get_health_stats()
            csprng_stats = csprng_monitor.get_stats()
            print_session_token_dashboard(
                token_stats,
                csprng_stats,
                preview,
                validation_str,
                session_cfg,
            )

            time.sleep(session_cfg.dashboard_refresh_interval)

    except KeyboardInterrupt:
        logger.info("Session Token Engine stopped by user.")
    finally:
        logger.info("Shutting down resources …")
        player.close()
        logger.info("Pipeline shut down successfully.")


if __name__ == "__main__":
    main()
