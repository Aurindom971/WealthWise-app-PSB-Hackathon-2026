import cv2
import numpy as np
from typing import Dict, Any, Tuple, Optional
from .config import CVEngineConfig

class FrameDifferencer:
    """
    Compares frame N with frame N-1 to detect spatial changes.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.prev_gray: Optional[cv2.typing.MatLike] = None

    def analyze(self, frame: cv2.typing.MatLike) -> Tuple[Dict[str, Any], cv2.typing.MatLike]:
        """
        Returns stats about frame differences and the diff mask.
        """
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Blur to reduce high frequency noise
        gray_blurred = cv2.GaussianBlur(gray, (5, 5), 0)

        if self.prev_gray is None:
            self.prev_gray = gray_blurred
            empty_mask = np.zeros_like(gray)
            return {
                "changed_pixels": 0,
                "change_percent": 0.0,
                "bounding_regions_count": 0
            }, empty_mask

        # Absolute difference
        diff = cv2.absdiff(self.prev_gray, gray_blurred)
        _, thresh = cv2.threshold(diff, 25, 255, cv2.THRESH_BINARY)

        self.prev_gray = gray_blurred

        # Stats
        changed_pixels = int(np.sum(thresh == 255))
        total_pixels = thresh.size
        change_percent = (changed_pixels / total_pixels) * 100.0

        # Find bounding regions of change
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        bounding_regions = []
        for cnt in contours:
            if cv2.contourArea(cnt) > 50:  # Filter out very small noise
                x, y, w, h = cv2.boundingRect(cnt)
                bounding_regions.append([x, y, x + w, y + h])

        return {
            "changed_pixels": changed_pixels,
            "change_percent": change_percent,
            "bounding_regions_count": len(bounding_regions),
            "bounding_regions": bounding_regions
        }, thresh
