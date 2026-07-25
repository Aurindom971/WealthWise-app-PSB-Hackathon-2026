import numpy as np
from typing import Dict, Any, List
from .config import EntropyConfig

class EntropyMonitor:
    """
    Analyzes entropy values and alerts on duplicate states or low-entropy anomalies.
    """
    def __init__(self, config: EntropyConfig):
        self.config = config
        self.past_fingerprints: List[str] = []

    def analyze_quality(
        self, 
        norm_features: Dict[str, float], 
        fingerprints: Dict[str, str], 
        entropy_scores: Dict[str, float]
    ) -> Dict[str, Any]:
        """
        Calculates health metrics, detecting static states and feature diversity.
        """
        # 1. Feature diversity is standard deviation of normalized features
        vals = list(norm_features.values())
        diversity = float(np.std(vals)) if vals else 0.0

        # 2. Check for repeated feature states (checks environment / motion fingerprints)
        curr_fingerprint = fingerprints.get("environment", "") + fingerprints.get("motion", "")
        duplicate_detected = False
        if curr_fingerprint in self.past_fingerprints:
            duplicate_detected = True

        # Keep rolling memory of last 60 fingerprints
        self.past_fingerprints.append(curr_fingerprint)
        if len(self.past_fingerprints) > 60:
            self.past_fingerprints.pop(0)

        # 3. Check for low entropy warnings
        composite = entropy_scores.get("composite", 0.0)
        status_msg = "High Entropy Status"
        if composite < self.config.low_entropy_warning_threshold:
            status_msg = "Low Entropy Warning"
        elif duplicate_detected:
            status_msg = "Degraded (Static State Detected)"

        # Pool saturation estimation (diversity metric)
        saturation = "Optimal"
        if diversity < self.config.diversity_threshold:
            saturation = "Stale Features"

        return {
            "feature_diversity": diversity,
            "repeated_state_detected": duplicate_detected,
            "status_message": status_msg,
            "saturation_status": saturation,
            "entropy_stability": composite
        }
