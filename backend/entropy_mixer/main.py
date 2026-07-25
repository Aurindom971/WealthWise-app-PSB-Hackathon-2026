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
from entropy_engine.entropy_monitor import EntropyMonitor

from entropy_mixer.config import MixerConfig
from entropy_mixer.entropy_mixer import EntropyMixer
from entropy_mixer.entropy_monitor import EntropyMixerMonitor

# Configure logger
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("AquariumMixerMain")

def print_mixer_dashboard(combined_blob: dict, audit: dict):
    """Renders a live terminal view of the multi-source entropy mixer status."""
    print("=" * 65)
    print("         MULTI-SOURCE ENTROPY MIXING ENGINE - LIVE STATUS")
    print("=" * 65)
    print(f"  Time: {combined_blob['timestamp']:<25} | Source Count: {combined_blob['source_count']}")
    print(f"  Overall Mixing Health: {audit['overall_health']}")
    print("-" * 65)
    print("  SOURCE HEALTH STATUS:")
    for src, status in audit["source_status"].items():
        print(f"    - {src:<15}: {status}")
    print("-" * 65)
    print("  ENTROPY PAYLOADS:")
    # Aquarium
    aq = combined_blob["aquarium_entropy"]
    print(f"    1. Aquarium Pool Score: {aq['entropy_score']:.2f} | Status: {aq['pool_health']}")
    # OS
    os_data = combined_blob["os_entropy"]
    print(f"    2. OS Secure Bytes ({os_data['entropy_len']} B): {os_data['entropy_bytes_hex'][:30]}...")
    # CPU
    cpu = combined_blob["cpu_entropy"]
    print(f"    3. CPU Jitter Variance: {cpu['timing_variance']:.2f} ns | Score: {cpu['jitter_score']:.4f}")
    # Hardware
    hw = combined_blob["hardware_entropy"]
    print(f"    4. Hardware RNG support: {hw['status_message']}")
    # Network
    net = combined_blob["network_entropy"]
    print(f"    5. Network Latency: {net['average_latency_ms']:.2f} ms | Jitter Score: {net['jitter_score']:.4f}")
    print("=" * 65)

def main():
    logger.info("Initializing complete Video Ingestion + CV + Entropy Pool + Mixer Pipeline...")

    # Load configurations
    pipeline_cfg = PipelineConfig()
    cv_cfg = CVEngineConfig()
    cv_cfg.enable_visualization = False
    
    entropy_cfg = EntropyConfig()
    mixer_cfg = MixerConfig()

    # Phase 2 & 3 Modules
    player = VideoPlayer(pipeline_cfg)
    extractor = FeatureExtractor(cv_cfg)

    # Phase 4 Modules
    normalizer = FeatureNormalizer(entropy_cfg)
    collector = EntropyCollector(entropy_cfg)
    metrics_calc = EntropyMetricsCalculator(entropy_cfg)
    pool = EntropyPool(entropy_cfg)
    monitor = EntropyMonitor(entropy_cfg)

    # Phase 5 Modules
    mixer = EntropyMixer(mixer_cfg, pool)
    mixer_monitor = EntropyMixerMonitor(mixer_cfg)

    # Start Ingestion
    player.start()

    try:
        while True:
            # 1. Read frame
            frame_package = player.get_next_frame(timeout=1.0)
            if frame_package is None:
                continue

            frame, metadata = frame_package

            # 2. Extract CV
            feature_vector, internal_maps = extractor.process_frame(frame, metadata)

            # 3. Phase 4 collection
            norm_features = normalizer.normalize(feature_vector)
            fingerprints = collector.generate_fingerprints(norm_features)
            entropy_scores = metrics_calc.calculate_contributions(norm_features)
            pool.accumulate(entropy_scores)

            # 4. Phase 5 Multi-source Mix
            combined_blob = mixer.collect_all_entropy()

            # 5. Phase 5 Health Audit
            audit = mixer_monitor.audit_sources(combined_blob)

            # Print mixer dashboard
            print_mixer_dashboard(combined_blob, audit)

            # Sleep slightly to throttle HUD print speed
            time.sleep(0.1)

    except KeyboardInterrupt:
        logger.info("Pipeline stopped by user.")
    finally:
        logger.info("Shutting down resources...")
        player.close()
        logger.info("Pipeline shut down successfully.")

if __name__ == "__main__":
    main()
