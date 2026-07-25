import cv2
import numpy as np
from typing import Dict, Any
from .config import CVEngineConfig

class RippleDetector:
    """
    Analyzes ripples and fine water surface texture changes using Laplacian variance and optical flow metrics.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config

    def analyze(self, frame: cv2.typing.MatLike, motion_stats: Dict[str, Any]) -> Dict[str, Any]:
        """
        Estimates ripple intensity, frequency and direction from high-frequency spatial variation.
        """
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Calculate Laplacian to highlight edges/ripples
        laplacian = cv2.Laplacian(gray, cv2.CV_64F)
        lap_var = np.var(laplacian)

        # Map Laplacian variance to Ripple Intensity (normalized roughly 0.0 to 1.0)
        # Standard values for standard video ranges: min var ~50, max ~2000
        intensity = float(np.clip(lap_var / 1500.0, 0.0, 1.0))

        # Ripple frequency estimated by zero crossing rates of spatial derivatives
        # We look at horizontal differences
        dx = np.diff(gray, axis=1)
        zero_crossings = np.sum(np.diff(np.sign(dx), axis=1) != 0)
        frequency = float(np.clip(zero_crossings / (gray.size * 0.5), 0.0, 1.0))

        # Direction from optical flow heading
        direction = motion_stats.get("direction", 0.0)

        # Water motion score combines intensity and motion magnitude
        motion_mag = motion_stats.get("average_magnitude", 0.0)
        water_motion_score = float(np.clip((intensity * 0.4) + (motion_mag * 0.6), 0.0, 1.0))

        return {
            "intensity": intensity,
            "frequency": frequency,
            "water_motion_score": water_motion_score,
            "direction": direction
        }
