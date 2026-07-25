import time
import os
import sys
from aquarium_pipeline import PipelineConfig, VideoPlayer

def main():
    print("Initializing Aquarium Video Playback Pipeline...")
    
    # 1. Define custom config path if needed
    config = PipelineConfig()
    
    # Verify path
    if not os.path.exists(config.video_path):
        print(f"Error: Target video file not found at: {config.video_path}")
        print("Please check the configuration or ensure the video is located in assets/videos/.")
        sys.exit(1)

    # 2. Initialize Player (this also runs loader validation)
    player = VideoPlayer(config)
    player.loader.print_metadata()

    # 3. Start Background Processing Thread
    print("Starting background video pipeline...")
    player.start()

    try:
        # Run demo for 10 seconds and grab some frames
        print("Demonstrating frame capture for 10 seconds (Ctrl+C to stop)...")
        end_time = time.time() + 10.0
        
        while time.time() < end_time:
            # Retrieve frame package
            frame_package = player.get_next_frame(timeout=0.5)
            if frame_package is not None:
                frame, meta = frame_package
                print(
                    f"[Client Interface] Grabbed Frame #{meta['frame_number']} | "
                    f"Video TS: {meta['video_timestamp']:.2f}s | "
                    f"Elapsed: {meta['elapsed_time']:.2f}s | "
                    f"Frame Shape: {frame.shape}"
                )
            # Sleep slightly to not overload console print
            time.sleep(0.5)
            
    except KeyboardInterrupt:
        print("\nStopping demo...")
    finally:
        # 4. Clean up Resources
        print("Shutting down video player pipeline...")
        player.close()
        print("Pipeline shut down successfully.")

if __name__ == "__main__":
    main()
