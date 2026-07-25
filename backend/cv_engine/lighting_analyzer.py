import cv2
import numpy as np
from typing import Dict, Any, Optional
from .config import CVEngineConfig

class LightingAnalyzer:
    """
    Measures global and local lighting properties including brightness, contrast, reflections, and uniformity.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.prev_brightness: Optional[float] = None

    def analyze(self, frame: cv2.typing.MatLike) -> Dict[str, Any]:
        """
        Analyzes brightness, contrast, uniformity, and reflections.
        """
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # 1. Average Brightness (0.0 to 1.0)
        brightness = float(np.mean(gray)) / 255.0

        # 2. Contrast (standard deviation of pixel intensities)
        contrast = float(np.std(gray)) / 128.0  # Normalized roughly by max standard deviation

        # 3. Reflection Intensity: High-intensity peaks (e.g. pixels > 240)
        reflection_pixels = np.sum(gray > 240)
        reflection_intensity = float(np.clip(reflection_pixels / gray.size, 0.0, 1.0))

        # 4. Uniformity: Divide frame into 4 quadrants and look at standard deviation of means
        h, w = gray.shape
        quadrants = [
            gray[0:h//2, 0:w//2],
            gray[0:h//2, w//2:w],
            gray[h//2:h, 0:w//2],
            gray[h//2:h, w//2:w]
        ]
        quad_means = [np.mean(q) for q in quadrants]
        # Uniformity is inversely proportional to variation between quadrants
        uniformity = float(1.0 - (np.std(quad_means) / 128.0))
        uniformity = max(0.0, min(1.0, uniformity))

        # 5. Dynamic Lighting Changes
        dynamic_change = 0.0
        if self.prev_brightness is not None:
            dynamic_change = abs(brightness - self.prev_brightness)
        self.prev_brightness = brightness

        return {
            "brightness": brightness,
            "contrast": contrast,
            "reflection_intensity": reflection_intensity,
            "uniformity": uniformity,
            "dynamic_change": dynamic_change
        }
