import cv2
import numpy as np
from typing import Dict, Any, List, Optional
from .config import CVEngineConfig

class HistogramAnalyzer:
    """
    Computes RGB and HSV color histograms and measures color drift and distribution.
    Returns only compact descriptors (no raw histograms).
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.prev_rgb_hist: Optional[List[np.ndarray]] = None
        self.prev_hsv_hist: Optional[List[np.ndarray]] = None

    def analyze(self, frame: cv2.typing.MatLike) -> Dict[str, Any]:
        """
        Calculates color distribution and drift metrics without raw array outputs.
        """
        # 1. RGB Histogram Calculation
        rgb_channels = cv2.split(frame)
        rgb_hists = []
        for chan in rgb_channels:
            hist = cv2.calcHist([chan], [0], None, [32], [0, 256])
            cv2.normalize(hist, hist, 0, 1, cv2.NORM_MINMAX)
            rgb_hists.append(hist)

        # 2. HSV Histogram Calculation
        hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        hsv_channels = cv2.split(hsv)
        hsv_hists = []
        for chan in hsv_channels:
            hist = cv2.calcHist([chan], [0], None, [32], [0, 256])
            cv2.normalize(hist, hist, 0, 1, cv2.NORM_MINMAX)
            hsv_hists.append(hist)

        # 3. Compact descriptors: Mean color and standard deviation
        mean_bgr = [float(x) for x in cv2.mean(frame)[:3]]
        std_bgr = [float(x) for x in cv2.meanStdDev(frame)[1].flatten()]

        # 4. Histogram Drift / Similarity
        rgb_drift = 0.0
        hsv_drift = 0.0

        if self.prev_rgb_hist is not None:
            # Calculate correlation drift (1.0 is identical, so drift is 1.0 - correlation)
            rgb_corrs = [
                cv2.compareHist(self.prev_rgb_hist[i], rgb_hists[i], cv2.HISTCMP_CORREL)
                for i in range(3)
            ]
            rgb_drift = float(1.0 - np.mean(rgb_corrs))

        if self.prev_hsv_hist is not None:
            hsv_corrs = [
                cv2.compareHist(self.prev_hsv_hist[i], hsv_hists[i], cv2.HISTCMP_CORREL)
                for i in range(3)
            ]
            hsv_drift = float(1.0 - np.mean(hsv_corrs))

        # Save states
        self.prev_rgb_hist = rgb_hists
        self.prev_hsv_hist = hsv_hists

        return {
            "mean_bgr": mean_bgr,
            "std_bgr": std_bgr,
            "rgb_drift": rgb_drift,
            "hsv_drift": hsv_drift
        }
