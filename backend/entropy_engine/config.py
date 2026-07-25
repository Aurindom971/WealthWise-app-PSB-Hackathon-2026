from dataclasses import dataclass, field
from typing import Dict, Tuple

@dataclass
class EntropyConfig:
    # Normalization bounds (min, max) for feature normalizer
    fish_count_bounds: Tuple[float, float] = (0.0, 10.0)
    fish_speed_bounds: Tuple[float, float] = (0.0, 50.0)
    bubble_count_bounds: Tuple[float, float] = (0.0, 300.0)
    bubble_speed_bounds: Tuple[float, float] = (0.0, 30.0)
    motion_magnitude_bounds: Tuple[float, float] = (0.0, 20.0)
    frame_diff_percent_bounds: Tuple[float, float] = (0.0, 50.0)
    ripple_intensity_bounds: Tuple[float, float] = (0.0, 1.0)
    brightness_bounds: Tuple[float, float] = (0.0, 1.0)
    contrast_bounds: Tuple[float, float] = (0.0, 1.0)
    hsv_drift_bounds: Tuple[float, float] = (0.0, 0.05)
    edge_density_bounds: Tuple[float, float] = (0.0, 0.1)
    sensor_noise_bounds: Tuple[float, float] = (0.0, 2.0)

    # Entropy Contribution Weights
    weights: Dict[str, float] = field(default_factory=lambda: {
        "fish_motion": 0.25,
        "bubble_motion": 0.20,
        "optical_flow": 0.20,
        "frame_difference": 0.15,
        "lighting": 0.05,
        "histogram_drift": 0.05,
        "edge_change": 0.05,
        "noise": 0.05
    })

    # Entropy Pool Configuration
    pool_max_capacity: float = 100000.0  # Max accumulated entropy value
    entropy_buffer_size: int = 500

    # Monitor Alert Thresholds
    stability_threshold: float = 0.01  # Min change to detect active movement
    diversity_threshold: float = 0.4   # Min standard deviation of features
    low_entropy_warning_threshold: float = 0.2
