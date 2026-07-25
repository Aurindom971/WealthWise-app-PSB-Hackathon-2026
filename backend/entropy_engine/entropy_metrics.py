import numpy as np
from typing import Dict
from .config import EntropyConfig

class EntropyMetricsCalculator:
    """
    Computes contribution scores for localized entropy categories based on current feature variation.
    """
    def __init__(self, config: EntropyConfig):
        self.config = config

    def calculate_contributions(self, norm_features: Dict[str, float]) -> Dict[str, float]:
        """
        Maps normalized features directly to distinct entropy categories.
        """
        # 1. Fish Motion contribution
        fish_entropy = (norm_features["fish_count"] * 0.4) + (norm_features["fish_speed"] * 0.6)

        # 2. General Motion contribution
        motion_entropy = norm_features["motion_magnitude"]

        # 3. Bubble Motion contribution
        bubble_entropy = (norm_features["bubble_count"] * 0.5) + (norm_features["bubble_speed"] * 0.5)

        # 4. Lighting Entropy
        lighting_entropy = (norm_features["brightness"] * 0.3) + (norm_features["contrast"] * 0.4) + (norm_features["histogram_drift"] * 0.3)

        # 5. Sensor/Pixel Noise entropy
        noise_entropy = norm_features["noise_level"]

        # Apply weights and return scaled/normalized scores
        scores = {
            "fish_entropy": float(np.clip(fish_entropy, 0.0, 1.0)),
            "motion_entropy": float(np.clip(motion_entropy, 0.0, 1.0)),
            "bubble_entropy": float(np.clip(bubble_entropy, 0.0, 1.0)),
            "lighting_entropy": float(np.clip(lighting_entropy, 0.0, 1.0)),
            "noise_entropy": float(np.clip(noise_entropy, 0.0, 1.0))
        }

        # Calculate a combined composite score based on defined configuration weights
        w = self.config.weights
        composite = (
            (scores["fish_entropy"] * w.get("fish_motion", 0.25)) +
            (scores["motion_entropy"] * w.get("optical_flow", 0.20)) +
            (scores["bubble_entropy"] * w.get("bubble_motion", 0.20)) +
            (scores["lighting_entropy"] * w.get("lighting", 0.05)) +
            (scores["noise_entropy"] * w.get("noise", 0.05))
        )
        scores["composite"] = float(np.clip(composite, 0.0, 1.0))

        return scores
