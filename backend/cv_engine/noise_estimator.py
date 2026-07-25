import cv2
import numpy as np
from typing import Dict, Any
from .config import CVEngineConfig

class NoiseEstimator:
    """
    Estimates high-frequency noise variance on the green channel using a Laplacian method.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config

    def estimate(self, frame: cv2.typing.MatLike) -> Dict[str, Any]:
        """
        Uses Immerkær's fast noise estimation method on the green channel.
        """
        # Convert to gray or green channel (green usually has the best sensor response)
        # Using Green channel (index 1)
        green = frame[..., 1]

        # Laplacian kernel
        # [ 1 -2  1]
        # [-2  4 -2]
        # [ 1 -2  1]
        # This highlights high-frequency local changes (e.g. noise)
        kernel = np.array([
            [1, -2, 1],
            [-2, 4, -2],
            [1, -2, 1]
        ], dtype=np.float32)

        # Convolve
        sigma = cv2.filter2D(green, cv2.CV_32F, kernel)

        # Sum of absolute differences divided by normalized scaling factor
        sum_abs = np.sum(np.abs(sigma))
        h, w = green.shape
        
        # Scaling constant for the specific Laplacian kernel
        # scale = sqrt(pi/2) / (6 * (w-2) * (h-2))
        scale = np.sqrt(np.pi / 2.0) / (6.0 * (w - 2) * (h - 2))
        noise_level = float(sum_abs * scale)

        # Variance is sigma^2
        variance = noise_level ** 2

        return {
            "pixel_noise": noise_level,
            "sensor_noise": variance,
            "noise_variance": variance
        }
