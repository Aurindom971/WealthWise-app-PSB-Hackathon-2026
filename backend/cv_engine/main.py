import sys
import os
import time
import cv2
import json
import logging

# Ensure parent directory is in sys.path to find aquarium_pipeline package
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from aquarium_pipeline import PipelineConfig, VideoPlayer
from cv_engine.config import CVEngineConfig
from cv_engine.feature_extractor import FeatureExtractor
from cv_engine.visualization import Visualizer

# Configure loggers
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger("AquariumCVMain")

def main():
    logger.info("Initializing Video Ingestion & CV Feature Extraction Pipeline...")

    # Load configurations
    pipeline_cfg = PipelineConfig()
    cv_cfg = CVEngineConfig()

    # Initialize Player & Engine
    player = VideoPlayer(pipeline_cfg)
    player.loader.print_metadata()

    extractor = FeatureExtractor(cv_cfg)
    visualizer = Visualizer(cv_cfg)

    # Start Phase 2 Video Reading Thread
    player.start()

    cv_fps_start = time.time()
    cv_frames_processed = 0
    fps = 30.0

    try:
        while True:
            # Get next frame package from Phase 2 queue
            frame_package = player.get_next_frame(timeout=1.0)
            if frame_package is None:
                logger.warning("Frame queue timeout. Waiting for frames...")
                continue

            frame, metadata = frame_package

            # Process frame through Phase 3 CV extraction modules
            t0 = time.time()
            feature_vector, internal_maps = extractor.process_frame(frame, metadata)
            processing_time = time.time() - t0

            # Calculate actual processing FPS
            cv_frames_processed += 1
            now = time.time()
            if now - cv_fps_start >= 1.0:
                fps = cv_frames_processed / (now - cv_fps_start)
                cv_frames_processed = 0
                cv_fps_start = now

            # Print generated numerical feature vector as JSON to stdout
            print(json.dumps(feature_vector, indent=2))

            # Optional HUD Visualization Window
            if cv_cfg.enable_visualization:
                hud_frame = visualizer.draw(frame, feature_vector, internal_maps, fps)
                cv2.imshow(cv_cfg.visualization_window_name, hud_frame)

                # Key controls (Q to quit)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    logger.info("Quit request received. Stopping pipeline...")
                    break

    except KeyboardInterrupt:
        logger.info("Pipeline interrupted by user.")
    finally:
        # Clean up all streams and threads
        logger.info("Shutting down resources...")
        player.close()
        cv2.destroyAllWindows()
        logger.info("Pipeline shut down successfully.")

if __name__ == "__main__":
    main()
