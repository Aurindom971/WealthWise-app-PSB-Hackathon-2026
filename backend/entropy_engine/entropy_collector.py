import zlib
import json
from typing import Dict, Any
from .config import EntropyConfig

class EntropyCollector:
    """
    Computes fingerprints (hashes) for localized sub-categories of numerical features.
    This facilitates entropy tracking and duplicate detection.
    """
    def __init__(self, config: EntropyConfig):
        self.config = config

    def generate_fingerprints(self, norm_features: Dict[str, float]) -> Dict[str, str]:
        """
        Creates compact deterministic signatures for localized features using CRC32.
        """
        # Group features into categories
        categories = {
            "fish": ["fish_count", "fish_speed", "fish_direction"],
            "motion": ["motion_magnitude", "frame_difference", "ripple_score"],
            "bubbles": ["bubble_count", "bubble_speed", "bubble_velocity"],
            "environment": ["brightness", "contrast", "histogram_drift", "edge_density"],
            "noise": ["noise_level"]
        }

        fingerprints = {}
        for cat_name, keys in categories.items():
            cat_data = {k: norm_features.get(k, 0.0) for k in keys}
            # String representation
            serialized = json.dumps(cat_data, sort_keys=True)
            # Generate checksum
            checksum = zlib.crc32(serialized.encode("utf-8"))
            fingerprints[cat_name] = f"{checksum:08x}"

        return fingerprints
