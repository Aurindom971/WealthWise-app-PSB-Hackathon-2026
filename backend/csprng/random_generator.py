import struct
from typing import Dict, Any
from .chacha20_csprng import ChaCha20Csprng
from .utils import bytes_to_hex, bytes_to_base64

class RandomByteGenerator:
    """
    Exposes high-level APIs to request formatted secure values (hex, Base64, integers).
    All entropy originates strictly from the ChaCha20 keystream.
    """
    def __init__(self, csprng: ChaCha20Csprng):
        self.csprng = csprng
        self.bytes_generated_count = 0

    def generate_bytes(self, length: int) -> bytes:
        data = self.csprng.generate_bytes(length)
        self.bytes_generated_count += length
        return data

    def generate_hex(self, length: int) -> str:
        data = self.generate_bytes(length)
        return bytes_to_hex(data)

    def generate_base64(self, length: int) -> str:
        data = self.generate_bytes(length)
        return bytes_to_base64(data)

    def generate_nonce(self, length: int = 16) -> str:
        # Returns a hex string representation of the nonce
        return self.generate_hex(length)

    def generate_uint32(self) -> int:
        """Generates an unsigned 32-bit integer (0 to 2^32 - 1)."""
        data = self.generate_bytes(4)
        # Unpack as unsigned int
        return struct.unpack(">I", data)[0]

    def generate_uint64(self) -> int:
        """Generates an unsigned 64-bit integer (0 to 2^64 - 1)."""
        data = self.generate_bytes(8)
        # Unpack as unsigned long long
        return struct.unpack(">Q", data)[0]
