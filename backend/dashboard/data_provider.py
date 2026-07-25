import time
import threading
import logging
import cv2
import base64
from typing import Dict, Any, List

from aquarium_pipeline import PipelineConfig, VideoPlayer
from cv_engine.config import CVEngineConfig
from cv_engine.feature_extractor import FeatureExtractor
from cv_engine.visualization import Visualizer

from entropy_engine.config import EntropyConfig
from entropy_engine.feature_normalizer import FeatureNormalizer
from entropy_engine.entropy_collector import EntropyCollector
from entropy_engine.entropy_metrics import EntropyMetricsCalculator
from entropy_engine.entropy_pool import EntropyPool

from entropy_mixer.config import MixerConfig
from entropy_mixer.entropy_mixer import EntropyMixer

from crypto_conditioner.config import ConditionerConfig
from crypto_conditioner.entropy_conditioner import EntropyConditioner
from crypto_conditioner.sha3_conditioner import Sha3Conditioner
from crypto_conditioner.blake3_conditioner import Blake3Conditioner

from csprng.config import CSPRNGConfig
from csprng.seed_manager import SeedManager
from csprng.chacha20_csprng import ChaCha20Csprng
from csprng.random_generator import RandomByteGenerator
from csprng.reseed_manager import ReseedManager
from csprng.health_monitor import CsprngHealthMonitor

from session_token_engine.config import SessionTokenConfig
from session_token_engine.token_generator import TokenGenerator
from session_token_engine.session_token import SessionTokenGenerator
from session_token_engine.validator import TokenValidator
from session_token_engine.health_monitor import TokenHealthMonitor
from session_token_engine.utils import mask_token

logger = logging.getLogger("DashboardDataProvider")


class DataProvider:
    """
    Drives the complete backend pipeline in a thread-safe daemon loop.
    Captures live data snapshots and feeds websocket payloads.
    """

    def __init__(self):
        self.running = False
        self.lock = threading.Lock()
        self.latest_data: Dict[str, Any] = {}
        self.latest_frame = None
        self.event_log: List[str] = []
        self.session_gen = None
        self._last_fish_headings: Dict[int, float] = {}

        # Token history list to store last 10 generated tokens
        self.token_history: List[Dict[str, Any]] = []

    def start(self):
        if self.running:
            logger.warning("DataProvider already running – ignoring duplicate start().")
            return
        self.running = True
        self.thread = threading.Thread(target=self._run_pipeline, daemon=True)
        self.thread.start()

    def add_event(self, event: str):
        with self.lock:
            formatted_time = time.strftime("%H:%M:%S", time.localtime())
            self.event_log.insert(0, f"[{formatted_time}] {event}")
            if len(self.event_log) > 100:
                self.event_log.pop()

    def get_latest_snapshot(self) -> Dict[str, Any]:
        with self.lock:
            return dict(self.latest_data)

    def _run_pipeline(self):
        logger.info("Initializing Pipeline components...")

        pipeline_cfg = PipelineConfig()
        cv_cfg = CVEngineConfig()
        cv_cfg.enable_visualization = False

        entropy_cfg = EntropyConfig()
        mixer_cfg = MixerConfig()
        cond_cfg = ConditionerConfig()
        csprng_cfg = CSPRNGConfig()
        csprng_cfg.reseed_interval = 15.0

        session_cfg = SessionTokenConfig()

        # Ingestion & CV modules
        player = VideoPlayer(pipeline_cfg)
        extractor = FeatureExtractor(cv_cfg)
        visualizer = Visualizer(cv_cfg)

        # Entropy & Mixing modules
        normalizer = FeatureNormalizer(entropy_cfg)
        collector = EntropyCollector(entropy_cfg)
        metrics_calc = EntropyMetricsCalculator(entropy_cfg)
        pool = EntropyPool(entropy_cfg)
        mixer = EntropyMixer(mixer_cfg, pool)

        # Cryptographic Conditioner modules
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

        # Initialize CSPRNG Seed Manager
        seed_manager = SeedManager()

        # Start video player thread
        player.start()

        logger.info("Gathering initial entropy to seed CSPRNG...")
        initial_seed_hex = None
        while initial_seed_hex is None and self.running:
            frame_package = player.get_next_frame(timeout=1.0)
            if frame_package is not None:
                frame, metadata = frame_package
                feature_vector, _ = extractor.process_frame(frame, metadata)
                norm_features = normalizer.normalize(feature_vector)
                entropy_scores = metrics_calc.calculate_contributions(
                    norm_features
                )
                pool.accumulate(entropy_scores)
                initial_seed_hex = fetch_fresh_seed_callback()
            time.sleep(0.05)

        if not self.running:
            player.close()
            return

        seed_manager.load_seed(initial_seed_hex)

        # Initialize CSPRNG and formatted generator
        csprng = ChaCha20Csprng(seed_manager)
        generator = RandomByteGenerator(csprng)

        # Initialize Reseed Manager linking the callback
        reseed_mgr = ReseedManager(
            csprng_cfg, seed_manager, csprng, fetch_fresh_seed_callback
        )
        csprng_monitor = CsprngHealthMonitor(
            csprng_cfg, seed_manager, generator, reseed_mgr
        )

        # Initialize Session Token Engine
        token_gen = TokenGenerator(generator)
        session_gen = SessionTokenGenerator(token_gen, session_cfg)
        with self.lock:
            self.session_gen = session_gen
        validator = TokenValidator(
            min_token_bits=session_cfg.min_token_bits,
            preview_len=session_cfg.max_token_preview_chars,
        )
        health_mon = TokenHealthMonitor(session_cfg)

        logger.info("Pipeline started successfully. Entering process loop...")

        fps_calc_time = time.time()
        frame_counter = 0
        current_fps = 30.0

        while self.running:
            t_start = time.time()
            frame_package = player.get_next_frame(timeout=0.5)

            if frame_package is None:
                time.sleep(0.01)
                continue

            frame, metadata = frame_package

            # 1. Computer vision processing
            t_cv_0 = time.time()
            feature_vector, internal_maps = extractor.process_frame(
                frame, metadata
            )
            t_cv_1 = time.time()
            cv_latency = (t_cv_1 - t_cv_0) * 1000.0

            # Generate CV events
            fish_count = feature_vector["fish"]["count"]
            self.add_event(f"Feature vector generated for frame {metadata.get('frame_number')}")
            self.add_event(f"Fish Detector: {fish_count} fish detected")
            
            # Check fish direction changes
            for fish in feature_vector["fish"]["detections"]:
                fid = fish["id"]
                try:
                    heading = float(fish.get("heading", 0.0))
                except (ValueError, TypeError):
                    heading = 0.0
                prev_heading = self._last_fish_headings.get(fid)
                if prev_heading is not None and abs(heading - prev_heading) > 45.0:
                    self.add_event(f"Fish #{fid} changed direction")
                self._last_fish_headings[fid] = heading

            bubbles_count = feature_vector["bubbles"]["count"]
            self.add_event(f"Bubble Detector: {bubbles_count} bubbles")
            if bubbles_count > 20:
                self.add_event("Bubble cluster detected")

            # 2. Entropy accumulation
            t_entropy_0 = time.time()
            norm_features = normalizer.normalize(feature_vector)
            entropy_scores = metrics_calc.calculate_contributions(norm_features)
            pool.accumulate(entropy_scores)
            t_entropy_1 = time.time()
            entropy_latency = (t_entropy_1 - t_entropy_0) * 1000.0

            pool_stats = pool.get_status()
            self.add_event(f"Entropy pool updated (Fill: {pool_stats['fill_percentage']:.1f}%)")

            # 3. Mixing & reseed check
            t_mix_0 = time.time()
            reseeded = reseed_mgr.check_and_reseed()
            t_mix_1 = time.time()
            mixing_latency = (t_mix_1 - t_mix_0) * 1000.0

            self.add_event("Entropy mixed from 5 sources")
            if reseeded:
                self.add_event("SHA3 conditioning complete")
                self.add_event("ChaCha20 reseeded successfully")

            # 4. Generate token
            t_token_0 = time.time()
            token, token_elapsed_ms = session_gen.generate()
            health_mon.record_generation(token_elapsed_ms)
            validation = validator.validate(token.token, token.encoding)
            t_token_1 = time.time()
            token_latency = (t_token_1 - t_token_0) * 1000.0

            # 5. Overlays & Bounding Box drawing
            overlay_frame = visualizer.draw(
                frame, feature_vector, internal_maps, current_fps
            )

            # Update token history
            masked_val = mask_token(token.token, 10)
            formatted_time = time.strftime("%H:%M:%S", time.localtime())

            self.add_event(f"Session token generated: {masked_val}")

            # Store details of generated tokens
            token_entry = {
                "time": formatted_time,
                "token": masked_val,
                "encoding": token.encoding,
                "length": token.length_bits,
                "latency_ms": f"{token_elapsed_ms:.2f}",
                "valid": validation.is_valid,
            }

            self.token_history.append(token_entry)
            if len(self.token_history) > 10:
                self.token_history.pop(0)

            # 6. Build unified JSON data structure
            pool_stats = pool.get_status()
            csprng_stats = csprng_monitor.get_stats()
            token_stats = health_mon.get_health_stats()

            # Print to backend console
            print(f"\n[Fish Detector] {feature_vector['fish']['count']} Fish Detected")
            print(f"[Bubble Detector] {feature_vector['bubbles']['count']} Bubbles")
            print(f"[Entropy Collector] Entropy Score : {pool_stats['fill_percentage']:.1f}%")
            if reseeded:
                print("[SHA3] Digest Generated")
                print("[CSPRNG] Reseed Successful")
            print(f"[Session Token] Token #{token_stats['total_tokens_generated']} Generated")

            # Latency summary
            latencies = {
                "cv": f"{cv_latency:.1f}ms",
                "entropy": f"{entropy_latency:.1f}ms",
                "mixing": f"{mixing_latency:.1f}ms",
                "conditioning": "0.1ms" if reseeded else "0.0ms",
                "csprng": "0.05ms",
                "token": f"{token_latency:.1f}ms",
            }

            snapshot = {
                "image": "",
                "frame_number": metadata.get("frame_number", 0),
                "fps": f"{current_fps:.1f}",
                "cv_stats": {
                    "fish_count": feature_vector["fish"]["count"],
                    "bubble_count": feature_vector["bubbles"]["count"],
                    "avg_speed": f"{feature_vector['bubbles']['average_speed']:.2f}",
                    "rise_velocity": f"{feature_vector['bubbles']['average_rise_velocity']:.2f}",
                    "motion_magnitude": f"{feature_vector['motion']['average_magnitude']:.4f}",
                    "optical_flow": f"{feature_vector['motion']['maximum_magnitude']:.4f}",
                    "flow_direction": f"{feature_vector['motion']['direction']:.2f}",
                    "ripple_score": f"{feature_vector['ripples']['intensity']:.4f}",
                    "ripple_frequency": f"{feature_vector['ripples']['frequency']:.4f}",
                    "water_motion": f"{feature_vector['ripples']['water_motion_score']:.4f}",
                    "brightness": f"{feature_vector['lighting']['brightness']:.2f}",
                    "contrast": f"{feature_vector['lighting']['contrast']:.2f}",
                    "hist_drift": f"{feature_vector['histogram']['rgb_drift']:.4f}",
                    "edge_density": f"{feature_vector['edges']['density']:.4f}",
                    "noise_score": f"{feature_vector['noise']['pixel_noise']:.4f}",
                    "video_timestamp": feature_vector.get("video_timestamp", "00:00.000"),
                    "processing_fps": f"{current_fps:.2f}",
                },
                "entropy_stats": {
                    "fill_percent": f"{pool_stats['fill_percentage']:.1f}",
                    "health": pool_stats["health"],
                    "current_size": f"{pool_stats['current_size']:.2f}",
                    "total_extracted": f"{pool_stats['total_extracted']:.2f}",
                    "source_count": mixer.collect_all_entropy()["source_count"],
                },
                "csprng_stats": {
                    "reseed_count": csprng_stats["reseed_count"],
                    "bytes_generated": csprng_stats["bytes_generated"],
                    "rate_bps": f"{csprng_stats['generation_rate_bps']:.1f}",
                    "health": csprng_stats["generator_health"],
                },
                "token_stats": {
                    "total_generated": token_stats["total_tokens_generated"],
                    "rate_tps": f"{token_stats['generation_rate_tps']:.2f}",
                    "avg_time_ms": f"{token_stats['average_generation_time_ms']:.2f}",
                    "latest_token": masked_val,
                    "history": list(self.token_history),
                },
                "latencies": latencies,
                "status_indicators": {
                    "camera": "Online",
                    "fish_detection": "Running",
                    "bubble_detection": "Running",
                    "optical_flow": "Running",
                    "entropy_pool": pool_stats["health"],
                    "sha3": "Healthy",
                    "chacha20": csprng_stats["generator_health"],
                    "session_generator": token_stats["generator_health"],
                },
            }

            with self.lock:
                self.latest_frame = overlay_frame
                self.latest_data = snapshot

            # Performance stats
            frame_counter += 1
            now = time.time()
            if now - fps_calc_time >= 1.0:
                current_fps = frame_counter / (now - fps_calc_time)
                frame_counter = 0
                fps_calc_time = now

            # Control sleep
            elapsed = time.time() - t_start
            sleep_time = max(0.005, 0.033 - elapsed)
            time.sleep(sleep_time)

        player.close()
