import json
from typing import Dict, Any

class EntropyConditioner:
    """
    Handles combined entropy blob validation and deterministic serialization to byte arrays.
    """
    def __init__(self):
        pass

    def validate_blob(self, blob: Dict[str, Any]) -> None:
        """
        Validates the Combined Entropy Blob structure. Raises ValueError/KeyError if invalid.
        """
        if not blob:
            raise ValueError("Entropy blob is empty or None")

        required_keys = [
            "aquarium_entropy",
            "os_entropy",
            "cpu_entropy",
            "hardware_entropy",
            "network_entropy",
            "timestamp",
            "source_count"
        ]

        for key in required_keys:
            if key not in blob:
                raise KeyError(f"Missing required entropy source key: {key}")

        # Basic format checks
        if not isinstance(blob["timestamp"], str) or not blob["timestamp"]:
            raise ValueError("Entropy timestamp is invalid or empty")

    def serialize(self, blob: Dict[str, Any]) -> bytes:
        """
        Serializes the combined entropy blob to a deterministic byte stream.
        Consistent ordering of fields is enforced by sorting keys.
        """
        # Ensure input is valid
        self.validate_blob(blob)

        # Serialize deterministically using sort_keys
        serialized_str = json.dumps(blob, sort_keys=True)
        return serialized_str.encode("utf-8")
