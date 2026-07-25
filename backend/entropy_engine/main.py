import sys
import os
import time
import json
import logging
import cv2

# Ensure parent directory is in sys.path to find packages
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from aquarium_pipeline import PipelineConfig, VideoPlayer
from cv_engine.config import CVEngineConfig
from cv_engine.feature_extractor import FeatureExtractor
from cv_engine.visualization import Visualizer

from entropy_engine.config import EntropyConfig
from entropy_engine.feature_normalizer import FeatureNormalizer
from entropy_engine.entropy_collector import EntropyCollector
from entropy_engine.entropy_metrics import EntropyMetricsCalculator
from entropy_engine.entropy_buffer import EntropyBuffer
from entropy_engine.entropy_pool import EntropyPool
from entropy_engine.entropy_monitor import EntropyMonitor

# Configure logger
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("AquariumEntropyMain")

def print_dashboard(
    frame_number: int,
    video_timestamp: str,
    entropy_scores: dict,
    pool_status: dict,
    quality_status: dict,
    fps: float
):
    """Prints a clean live terminal dashboard of the entropy statistics."""
    # Clear console line/terminal on systems
    # For compatibility, we print separation bounds
    print("=" * 60)
    print("           AQUARIUM ENTROPY POOL ENGINE - LIVE HUD")
    print("=" * 60)
    print(f"  Frame Number: {frame_number:<10} | Video TS: {video_timestamp:<12}")
    print(f"  CV Pipeline FPS: {fps:.2f}")
    print("-" * 60)
    print(f"  Entropy Pool Size:     {pool_status['current_size']:.2f} / {pool_status['max_capacity']:.2f}")
    print(f"  Pool Fill Percentage:  {pool_status['fill_percentage']:.2f}%")
    print(f"  Pool Health:           {pool_status['health']}")
    print(f"  Pool Age:              {pool_status['pool_age_seconds']:.2f}s")
    print(f"  Total Extracted:       {pool_status['total_extracted']:.2f}")
    print("-" * 60)
    print("  ENTROPY CONTRIBUTIONS (Weighted):")
    print(f"    - Fish Motion Entropy:   {entropy_scores['fish_entropy']:.4f}")
    print(f"    - General Motion:        {entropy_scores['motion_entropy']:.4f}")
    print(f"    - Bubble Turbulence:     {entropy_scores['bubble_entropy']:.4f}")
    print(f"    - Ambient Lighting:      {entropy_scores['lighting_entropy']:.4f}")
    print(f"    - Sensor/Pixel Noise:    {entropy_scores['noise_entropy']:.4f}")
    print(f"    - Weighted Composite:    {entropy_scores['composite']:.4f}")
    print("-" * 60)
    print("  QUALITY MONITOR STATUS:")
    print(f"    - Feature Diversity:     {quality_status['feature_diversity']:.4f}")
    print(f"    - Status Message:        {quality_status['status_message']}")
    print(f"    - Saturation:            {quality_status['saturation_status']}")
    print("=" * 60)

def main():
    logger.info("Initializing Video + CV + Entropy Ingestion Pipeline...")

    # Load configurations
    pipeline_cfg = PipelineConfig()
    cv_cfg = CVEngineConfig()
    # Disable CV window inside console task to prevent GUI blocks, but keep logic enabled
    cv_cfg.enable_visualization = False
    
    entropy_cfg = EntropyConfig()

    # Phase 2 & 3 Modules
    player = VideoPlayer(pipeline_cfg)
    extractor = FeatureExtractor(cv_cfg)

    # Phase 4 Modules
    normalizer = FeatureNormalizer(entropy_cfg)
    collector = EntropyCollector(entropy_cfg)
    metrics_calc = EntropyMetricsCalculator(entropy_cfg)
    buffer = EntropyBuffer(entropy_cfg.entropy_buffer_size)
    pool = EntropyPool(entropy_cfg)
    monitor = EntropyMonitor(entropy_cfg)

    # Start Video Thread
    player.start()

    cv_fps_start = time.time()
    cv_frames_processed = 0
    fps = 30.0

    try:
        while True:
            # 1. Get next frame from Phase 2
            frame_package = player.get_next_frame(timeout=1.0)
            if frame_package is None:
                continue

            frame, metadata = frame_package

            # 2. Extract CV features from Phase 3
            feature_vector, internal_maps = extractor.process_frame(frame, metadata)

            # 3. Phase 4 - Normalize Features
            norm_features = normalizer.normalize(feature_vector)

            # 4. Phase 4 - Hash / Fingerprint Features
            fingerprints = collector.generate_fingerprints(norm_features)

            # 5. Phase 4 - Compute Entropy Contributions
            entropy_scores = metrics_calc.calculate_contributions(norm_features)

            # 6. Phase 4 - Accumulate into Entropy Pool
            pool.accumulate(entropy_scores)

            # 7. Phase 4 - Monitor Quality
            quality_status = monitor.analyze_quality(norm_features, fingerprints, entropy_scores)

            # Create final API representation
            api_payload = {
                "timestamp": str(metadata.get("unix_timestamp", 0.0)),
                "frame_number": feature_vector["frame_number"],
                "normalized_features": norm_features,
                "feature_fingerprints": fingerprints,
                "entropy_scores": entropy_scores,
                "pool_status": pool.get_status(),
                "quality_status": quality_status
            }

            # 8. Store in rolling buffer
            buffer.append(api_payload)

            # Update FPS
            cv_frames_processed += 1
            now = time.time()
            if now - cv_fps_start >= 1.0:
                fps = cv_frames_processed / (now - cv_fps_start)
                cv_frames_processed = 0
                cv_fps_start = now

            # Print dashboard to console
            print_dashboard(
                api_payload["frame_number"],
                feature_vector["video_timestamp"],
                entropy_scores,
                api_payload["pool_status"],
                quality_status,
                fps
            )

            # Sleep slightly to throttle dashboard refresh speed
            time.sleep(0.05)

    except KeyboardInterrupt:
        logger.info("Pipeline stopped by user.")
    finally:
        logger.info("Shutting down resources...")
        player.close()
        logger.info("Pipeline shut down successfully.")

if __name__ == "__main__":
    main()
