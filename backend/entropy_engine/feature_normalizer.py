import logging
from typing import Dict, Any
from .config import EntropyConfig
from .utils import normalize_value

logger = logging.getLogger("AquariumEntropy")

class FeatureNormalizer:
    """
    Normalizes structured CV feature vector variables to values between 0.0 and 1.0.
    """
    def __init__(self, config: EntropyConfig):
        self.config = config

    def normalize(self, raw_features: Dict[str, Any]) -> Dict[str, float]:
        """
        Extracts raw features and normalizes them based on configured limits.
        """
        # 1. Fish metrics
        fish = raw_features.get("fish", {})
        fish_count = float(fish.get("count", 0))
        detections = fish.get("detections", [])
        avg_fish_speed = 0.0
        avg_fish_dir = 0.0
        if detections:
            avg_fish_speed = sum(d.get("speed", 0.0) for d in detections) / len(detections)
            avg_fish_dir = sum(d.get("direction", 0.0) for d in detections) / len(detections)

        # 2. Bubble metrics
        bubbles = raw_features.get("bubbles", {})
        bubble_count = float(bubbles.get("count", 0))
        bubble_speed = float(bubbles.get("average_speed", 0.0))
        bubble_vel = float(bubbles.get("average_rise_velocity", 0.0))

        # 3. Motion metrics
        motion = raw_features.get("motion", {})
        motion_mag = float(motion.get("average_magnitude", 0.0))

        # 4. Frame difference
        frame_diff = raw_features.get("frame_difference", {})
        change_pct = float(frame_diff.get("change_percent", 0.0))

        # 5. Ripple metrics
        ripples = raw_features.get("ripples", {})
        ripple_intensity = float(ripples.get("intensity", 0.0))

        # 6. Lighting metrics
        lighting = raw_features.get("lighting", {})
        brightness = float(lighting.get("brightness", 0.0))
        contrast = float(lighting.get("contrast", 0.0))

        # 7. Histogram drift
        hist = raw_features.get("histogram", {})
        hsv_drift = float(hist.get("hsv_drift", 0.0))

        # 8. Edge metrics
        edges = raw_features.get("edges", {})
        edge_density = float(edges.get("density", 0.0))

        # 9. Noise metrics
        noise = raw_features.get("noise", {})
        sensor_noise = float(noise.get("sensor_noise", 0.0))

        # Normalize
        norm_features = {
            "fish_count": normalize_value(fish_count, *self.config.fish_count_bounds),
            "fish_speed": normalize_value(avg_fish_speed, *self.config.fish_speed_bounds),
            "fish_direction": avg_fish_dir / 360.0,  # Direction naturally 0-360
            "bubble_count": normalize_value(bubble_count, *self.config.bubble_count_bounds),
            "bubble_speed": normalize_value(bubble_speed, *self.config.bubble_speed_bounds),
            "bubble_velocity": normalize_value(bubble_vel, *self.config.bubble_speed_bounds),
            "motion_magnitude": normalize_value(motion_mag, *self.config.motion_magnitude_bounds),
            "frame_difference": normalize_value(change_pct, *self.config.frame_diff_percent_bounds),
            "ripple_score": normalize_value(ripple_intensity, *self.config.ripple_intensity_bounds),
            "brightness": normalize_value(brightness, *self.config.brightness_bounds),
            "contrast": normalize_value(contrast, *self.config.contrast_bounds),
            "histogram_drift": normalize_value(hsv_drift, *self.config.hsv_drift_bounds),
            "edge_density": normalize_value(edge_density, *self.config.edge_density_bounds),
            "noise_level": normalize_value(sensor_noise, *self.config.sensor_noise_bounds)
        }

        return norm_features
