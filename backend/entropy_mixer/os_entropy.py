import os
import time
import platform
from typing import Dict, Any
from .config import MixerConfig
from .utils import bytes_to_hex

class OsEntropySource:
    """
    Collects cryptographically secure random bytes from the OS kernel (urandom / CryptGenRandom).
    """
    def __init__(self, config: MixerConfig):
        self.config = config

    def collect(self) -> Dict[str, Any]:
        """
        Gathers secure bytes and wraps metadata.
        """
        # Determine source
        system_name = platform.system()
        
        # os.urandom is guaranteed to wrap CryptGenRandom (Windows), getrandom() (Linux), or getentropy() (macOS)
        secure_bytes = os.urandom(self.config.os_entropy_bytes)

        return {
            "source": f"OS Kernel ({system_name})",
            "timestamp": time.time(),
            "entropy_bytes_hex": bytes_to_hex(secure_bytes),
            "entropy_len": len(secure_bytes)
        }
