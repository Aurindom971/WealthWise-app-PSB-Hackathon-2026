import os
from dataclasses import dataclass, field
from enum import Enum
from typing import Literal

@dataclass
class CVEngineConfig:
    # Model config
    yolo_model_path: str = "yolov8n.pt"  # Will auto-download standard COCO
    yolo_conf_threshold: float = 0.05
    yolo_iou_threshold: float = 0.60
    yolo_tracker: str = "bytetrack.yaml"
    yolo_img_size: int = 640

    # Tracking parameters
    max_lost_frames: int = 30
    min_tracking_distance: float = 100.0  # Max distance to associate centroids

    # Bubble detection parameters
    bubble_min_area: float = 5.0
    bubble_max_area: float = 200.0

    # Optical flow parameters
    optical_flow_pyr_scale: float = 0.5
    optical_flow_levels: int = 3
    optical_flow_winsize: int = 15
    optical_flow_iterations: int = 3
    optical_flow_poly_n: int = 5
    optical_flow_poly_sigma: float = 1.2

    # Visualizations
    enable_visualization: bool = True
    visualization_window_name: str = "Aquarium Entropy CV Engine"
    stats_panel_width: int = 500

    # Trajectory visualization
    # "short" = recent trail only (default), "full" = full lifetime, "hidden" = no trail
    trail_mode: str = "short"
    trail_length: int = 20          # Max recent positions to draw (when trail_mode="short")
    trail_thickness: int = 2        # Line thickness in pixels (1-2 recommended)
    trail_opacity_min: float = 0.15 # Opacity of oldest trail segment (0.0 - 1.0)
    trail_opacity_max: float = 0.85 # Opacity of newest trail segment (0.0 - 1.0)
    trail_lost_timeout: float = 3.0 # Seconds before a lost track's trajectory is deleted
