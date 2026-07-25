import threading
import logging
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from csprng.random_generator import RandomByteGenerator

logger = logging.getLogger("SessionTokenEngine.TokenGenerator")


class TokenGenerator:
    """
    Bridge to the Phase 7 ChaCha20 CSPRNG.

    This is the ONLY class that touches the CSPRNG.  Every other module in
    session_token_engine requests randomness through this interface, ensuring
    a single auditable chokepoint for all random byte generation.

    Thread-safe: protects the byte counter with a lock.
    """

    def __init__(self, csprng_generator: "RandomByteGenerator") -> None:
        """
        Args:
            csprng_generator: A fully initialised Phase 7
                              ``RandomByteGenerator`` instance.
        """
        self._csprng = csprng_generator
        self._lock = threading.Lock()
        self._total_bytes_requested: int = 0

    # ── Public API ──────────────────────────────────────────────────

    def generate_random_bytes(self, length: int) -> bytes:
        """
        Request *length* cryptographically secure random bytes.

        All bytes originate exclusively from the Phase 7 ChaCha20 keystream.

        Args:
            length: Number of bytes to generate (must be > 0).

        Returns:
            ``bytes`` of the requested length.

        Raises:
            ValueError: If *length* is not a positive integer.
        """
        if not isinstance(length, int) or length <= 0:
            raise ValueError(f"Requested byte length must be a positive integer, got {length}")

        random_bytes = self._csprng.generate_bytes(length)

        with self._lock:
            self._total_bytes_requested += length

        logger.debug("Generated %d random bytes via ChaCha20 CSPRNG", length)
        return random_bytes

    # ── Monitoring Helpers ──────────────────────────────────────────

    @property
    def total_bytes_requested(self) -> int:
        with self._lock:
            return self._total_bytes_requested
