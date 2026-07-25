import cv2
import numpy as np
from typing import Dict, Any, Tuple, Optional
from .config import CVEngineConfig

class EdgeAnalyzer:
    """
    Computes Canny edge density and change statistics.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.prev_edges: Optional[cv2.typing.MatLike] = None

    def analyze(self, frame: cv2.typing.MatLike) -> Tuple[Dict[str, Any], cv2.typing.MatLike]:
        """
        Runs Canny edge detection and measures edge characteristics.
        """
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Apply Gaussian blur to reduce noise
        blurred = cv2.GaussianBlur(gray, (5, 5), 0)

        # Canny edge detection
        edges = cv2.Canny(blurred, 50, 150)

        # Edge Count & Density
        edge_pixels = np.sum(edges == 255)
        total_pixels = edges.size
        density = float(edge_pixels / total_pixels)

        # Edge Change Rate
        change_rate = 0.0
        if self.prev_edges is not None:
            # XOR edge maps to find new/disappeared edge pixels
            xor_map = cv2.bitwise_xor(self.prev_edges, edges)
            change_pixels = np.sum(xor_map == 255)
            change_rate = float(change_pixels / total_pixels)

        # Edge Strength: Average gradient magnitude along edges
        sobelx = cv2.Sobel(gray, cv2.CV_64F, 1, 0, ksize=3)
        sobely = cv2.Sobel(gray, cv2.CV_64F, 0, 1, ksize=3)
        mag = cv2.magnitude(sobelx, sobely)
        edge_strength = float(np.mean(mag[edges == 255])) if edge_pixels > 0 else 0.0

        self.prev_edges = edges

        stats = {
            "density": density,
            "edge_count": int(edge_pixels),
            "change": change_rate,
            "strength": edge_strength
        }

        return stats, edges
