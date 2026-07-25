import os
from dataclasses import dataclass

@dataclass
class PipelineConfig:
    # Path configuration
    # The default checks for 'backend/assets/videos/fish security.mp4', or falls back to 'assets/videos/aquarium.mp4'
    video_path: str = os.getenv(
        "AQUARIUM_VIDEO_PATH", 
        os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "videos", "fish security.mp4")
    )
    
    # Resizing configuration (default 1280x720)
    target_width: int = 960
    target_height: int = 540
    
    # Buffer sizes
    buffer_size: int = 10
    queue_size: int = 30
