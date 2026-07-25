import cv2
import numpy as np
from typing import Dict, Any, Tuple, Optional
from .config import CVEngineConfig

class OpticalFlowAnalyzer:
    """
    Computes Dense Optical Flow (Farneback) on consecutive frames.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.prev_gray: Optional[cv2.typing.MatLike] = None

    def analyze(self, frame: cv2.typing.MatLike) -> Tuple[Dict[str, Any], Optional[cv2.typing.MatLike]]:
        """
        Calculates motion statistics and returns the numeric values + motion map (heatmap).
        """
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # Default empty output if first frame
        if self.prev_gray is None:
            self.prev_gray = gray
            empty_heatmap = np.zeros_like(frame)
            return {
                "average_magnitude": 0.0,
                "maximum_magnitude": 0.0,
                "direction": 0.0
            }, empty_heatmap

        # Calculate Farneback dense optical flow
        flow = cv2.calcOpticalFlowFarneback(
            self.prev_gray,
            gray,
            None,
            pyr_scale=self.config.optical_flow_pyr_scale,
            levels=self.config.optical_flow_levels,
            winsize=self.config.optical_flow_winsize,
            iterations=self.config.optical_flow_iterations,
            poly_n=self.config.optical_flow_poly_n,
            poly_sigma=self.config.optical_flow_poly_sigma,
            flags=0
        )

        # Update previous frame
        self.prev_gray = gray

        # Split vector components
        flow_x = flow[..., 0]
        flow_y = flow[..., 1]

        # Calculate magnitude and direction (angle in degrees)
        magnitude, angle = cv2.cartToPolar(flow_x, flow_y, angleInDegrees=True)

        avg_mag = float(np.mean(magnitude))
        max_mag = float(np.max(magnitude))
        avg_dir = float(np.mean(angle))

        # Generate a motion heatmap for visual overlay (HSV representation)
        hsv = np.zeros((frame.shape[0], frame.shape[1], 3), dtype=np.uint8)
        hsv[..., 0] = (angle / 2).astype(np.uint8)  # Map 0-360 degrees to 0-180 for OpenCV HSV
        hsv[..., 1] = 255
        hsv[..., 2] = cv2.normalize(magnitude, None, 0, 255, cv2.NORM_MINMAX).astype(np.uint8)
        
        motion_heatmap = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)

        stats = {
            "average_magnitude": avg_mag,
            "maximum_magnitude": max_mag,
            "direction": avg_dir
        }

        return stats, motion_heatmap
