import cv2
import numpy as np
from typing import Dict, Any, List, Tuple
from .config import CVEngineConfig
from .utils import calculate_distance

class BubbleDetector:
    """
    Detects rising bubbles using thresholding, morphological opening/closing, and contour analysis.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.prev_centers: List[Tuple[float, float]] = []

    def detect(self, frame: cv2.typing.MatLike) -> Dict[str, Any]:
        """
        Thresholds lighter regions (bubbles) and calculates contour-based metrics.
        """
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Adaptive/simple thresholding to extract bright bubbles
        # Since bubbles are often bright white highlights, we threshold high-intensity regions
        _, thresh = cv2.threshold(gray, 200, 255, cv2.THRESH_BINARY)

        # Morphology to separate merged bubbles and remove noise
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
        morphed = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel)
        morphed = cv2.morphologyEx(morphed, cv2.MORPH_CLOSE, kernel)

        contours, _ = cv2.findContours(morphed, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        bubble_centers = []
        bubble_radii = []
        bubble_areas = []
        
        for cnt in contours:
            area = cv2.contourArea(cnt)
            if self.config.bubble_min_area <= area <= self.config.bubble_max_area:
                (x, y), radius = cv2.minEnclosingCircle(cnt)
                bubble_centers.append((float(x), float(y)))
                bubble_radii.append(float(radius))
                bubble_areas.append(float(area))

        # Calculate speeds/velocity relative to previous frame
        speeds = []
        rise_velocities = []

        for curr in bubble_centers:
            # Find the closest bubble in the previous frame
            if self.prev_centers:
                min_dist = min(calculate_distance(curr, prev) for prev in self.prev_centers)
                speeds.append(min_dist)
                
                # Rise velocity: change in Y (bubbles rise, meaning Y index decreases)
                # Let's find the best matching vertical delta
                best_match = min(self.prev_centers, key=lambda p: calculate_distance(curr, p))
                dy = best_match[1] - curr[1]  # positive if rising
                rise_velocities.append(dy)

        avg_speed = float(np.mean(speeds)) if speeds else 0.0
        avg_rise_vel = float(np.mean(rise_velocities)) if rise_velocities else 0.0

        # Save state
        self.prev_centers = bubble_centers

        return {
            "count": len(bubble_centers),
            "centers": bubble_centers,
            "radii": bubble_radii,
            "areas": bubble_areas,
            "average_speed": avg_speed,
            "average_rise_velocity": avg_rise_vel
        }
