import time
import logging
from typing import Dict, Any

from .sha3_conditioner import Sha3Conditioner

logger = logging.getLogger("AquariumConditioner")

class Blake3Conditioner:
    """
    Attempts to apply BLAKE3 conditioning. Automatically falls back to SHA3-512 if unavailable.
    """
    def __init__(self):
        self.blake3_module = None
        try:
            import blake3
            self.blake3_module = blake3
            logger.info("BLAKE3 module successfully imported.")
        except ImportError:
            logger.warning("BLAKE3 module not found. Falling back to SHA3-512.")
            self.sha3_fallback = Sha3Conditioner()

    def condition(self, data_bytes: bytes) -> Dict[str, Any]:
        """
        Applies BLAKE3 or falls back to SHA3-512.
        """
        if self.blake3_module is not None:
            # BLAKE3 is available
            hasher = self.blake3_module.blake3()
            hasher.update(data_bytes)
            # Output 512-bit digest (64 bytes)
            digest = hasher.hexdigest(length=64)
            return {
                "algorithm": "BLAKE3",
                "digest": digest,
                "digest_size": 512,
                "timestamp": time.time()
            }
        else:
            return self.sha3_fallback.condition(data_bytes)
