import threading
import time

class SeedManager:
    """
    Safely stores the 512-bit conditioned entropy digest in-memory only.
    Enforces size and validation rules.
    """
    def __init__(self):
        self.lock = threading.Lock()
        self.current_seed_bytes: bytes = b""
        self.last_load_time: float = 0.0

    def load_seed(self, seed_hex: str) -> None:
        """
        Validates and loads a hex-encoded seed.
        The seed must represent a 512-bit value (64 bytes).
        """
        if not seed_hex:
            raise ValueError("Seed is empty or None")

        # Convert to bytes
        try:
            seed_bytes = bytes.fromhex(seed_hex)
        except ValueError:
            raise ValueError("Seed is not a valid hex string")

        if len(seed_bytes) != 64:
            raise ValueError(f"Invalid seed size: {len(seed_bytes)} bytes. Expected exactly 64 bytes (512 bits)")

        with self.lock:
            # Overwrite in-memory seed securely
            self.current_seed_bytes = seed_bytes
            self.last_load_time = time.time()

    def get_seed(self) -> bytes:
        """
        Retrieves the current in-memory seed bytes.
        """
        with self.lock:
            if not self.current_seed_bytes:
                raise RuntimeError("Seed Manager has not been initialized with a valid seed yet.")
            return self.current_seed_bytes
            
    def get_last_load_time(self) -> float:
        with self.lock:
            return self.last_load_time
