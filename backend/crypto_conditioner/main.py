import sys
import os
import time
import json
import logging

# Ensure parent directory is in sys.path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from aquarium_pipeline import PipelineConfig, VideoPlayer
from cv_engine.config import CVEngineConfig
from cv_engine.feature_extractor import FeatureExtractor

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
from crypto_conditioner.conditioning_monitor import ConditioningMonitor
from crypto_conditioner.utils import mask_digest

# Configure logger
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("AquariumConditionerMain")

def print_conditioner_dashboard(digest_payload: dict, stats: dict, input_size: int):
    """Renders a live terminal view of the cryptographic conditioner HUD."""
    print("=" * 65)
    print("         CRYPTOGRAPHIC ENTROPY CONDITIONING ENGINE - LIVE HUD")
    print("=" * 65)
    print(f"  Time: {digest_payload['timestamp']:<25}")
    print(f"  Conditioning Status: {digest_payload['status']}")
    print("-" * 65)
    print(f"  Current Algorithm:   {digest_payload['algorithm']}")
    print(f"  Input Blob Size:     {input_size} Bytes")
    print(f"  Digest Size:         {digest_payload['digest_size']} Bits")
    print(f"  Conditioning Time:   {digest_payload['processing_time_ms']:.4f} ms")
    print(f"  Conditioned Digest:  {mask_digest(digest_payload['digest'])}")
    print("-" * 65)
    print("  CONDITIONING STATISTICS:")
    print(f"    - Total Operations:   {stats['total_operations']}")
    print(f"    - Success Rate:       {stats['success_rate']:.2f}%")
    print(f"    - Avg Latency:        {stats['average_processing_time_ms']:.4f} ms")
    print("=" * 65)

def main():
    logger.info("Initializing Video + CV + Pool + Mixer + Conditioner Pipeline...")

    # Load configurations
    pipeline_cfg = PipelineConfig()
    cv_cfg = CVEngineConfig()
    cv_cfg.enable_visualization = False
    
    entropy_cfg = EntropyConfig()
    mixer_cfg = MixerConfig()
    cond_cfg = ConditionerConfig()

    # Ingestion Modules
    player = VideoPlayer(pipeline_cfg)
    extractor = FeatureExtractor(cv_cfg)

    # Entropy Engine Modules
    normalizer = FeatureNormalizer(entropy_cfg)
    collector = EntropyCollector(entropy_cfg)
    metrics_calc = EntropyMetricsCalculator(entropy_cfg)
    pool = EntropyPool(entropy_cfg)

    # Mixing Engine Modules
    mixer = EntropyMixer(mixer_cfg, pool)

    # Cryptographic Conditioner Modules
    conditioner = EntropyConditioner()
    
    if cond_cfg.algorithm == "BLAKE3":
        hash_engine = Blake3Conditioner()
    else:
        hash_engine = Sha3Conditioner()
        
    monitor = ConditioningMonitor()

    # Start Ingestion Thread
    player.start()

    try:
        while True:
            # 1. Read Frame
            frame_package = player.get_next_frame(timeout=1.0)
            if frame_package is None:
                continue

            frame, metadata = frame_package

            # 2. Extract CV Features
            feature_vector, _ = extractor.process_frame(frame, metadata)

            # 3. Accumulate Entropy Pool
            norm_features = normalizer.normalize(feature_vector)
            _ = collector.generate_fingerprints(norm_features)
            entropy_scores = metrics_calc.calculate_contributions(norm_features)
            pool.accumulate(entropy_scores)

            # 4. Mix Sources into Combined Entropy Blob
            combined_blob = mixer.collect_all_entropy()

            # 5. Cryptographically Condition Entropy Payload
            t0 = time.perf_counter()
            try:
                # Deterministic serialization
                serialized_bytes = conditioner.serialize(combined_blob)
                input_size = len(serialized_bytes)

                # Hash conditioning
                hash_res = hash_engine.condition(serialized_bytes)
                duration_ms = (time.perf_counter() - t0) * 1000.0

                digest_payload = {
                    "algorithm": hash_res["algorithm"],
                    "digest": hash_res["digest"],
                    "digest_size": hash_res["digest_size"],
                    "timestamp": str(hash_res["timestamp"]),
                    "processing_time_ms": duration_ms,
                    "status": "SUCCESS"
                }

                # Log performance
                monitor.log_success(duration_ms)

                # Render Dashboard
                print_conditioner_dashboard(digest_payload, monitor.get_stats(), input_size)

            except Exception as e:
                monitor.log_failure()
                logger.error(f"Entropy conditioning operation failed: {e}")

            # Sleep slightly to throttle HUD print rate
            time.sleep(0.1)

    except KeyboardInterrupt:
        logger.info("Pipeline stopped by user.")
    finally:
        logger.info("Shutting down resources...")
        player.close()
        logger.info("Pipeline shut down successfully.")

if __name__ == "__main__":
    main()
