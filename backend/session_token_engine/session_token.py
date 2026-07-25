import threading
import logging
from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any

from .config import SessionTokenConfig
from .token_generator import TokenGenerator
from .encoder import encode
from .utils import iso_timestamp, monotonic_ms

logger = logging.getLogger("SessionTokenEngine.SessionToken")


@dataclass(frozen=True)
class SessionToken:
    """
    Immutable representation of a generated session token.
    """

    token: str
    encoding: str
    length_bits: int
    created_at: str
    algorithm: str


class SessionTokenGenerator:
    """
    Core session token factory.

    Generates cryptographically secure session tokens by:
      1. Requesting raw random bytes from ``TokenGenerator`` (Phase 7 CSPRNG).
      2. Encoding them via the configured encoding (Base64URL / Hex / Raw).
      3. Wrapping the result in an immutable ``SessionToken`` dataclass.

    Thread-safe for concurrent callers.
    """

    def __init__(
        self,
        token_gen: TokenGenerator,
        config: SessionTokenConfig,
    ) -> None:
        self._token_gen = token_gen
        self._config = config
        self._lock = threading.Lock()
        self._generation_count: int = 0

    # ── Public API ──────────────────────────────────────────────────

    def generate(
        self,
        length_bits: Optional[int] = None,
        encoding: Optional[str] = None,
    ) -> SessionToken:
        """
        Generate a single session token.

        Args:
            length_bits: Token size in bits (default from config, must be multiple of 8).
            encoding:    Encoding scheme (default from config).

        Returns:
            A populated ``SessionToken`` instance.
        """
        bits = length_bits or self._config.default_token_bits
        enc = encoding or self._config.default_encoding

        if bits % 8 != 0:
            raise ValueError(f"length_bits must be a multiple of 8, got {bits}")

        byte_length = bits // 8

        start = monotonic_ms()
        raw_bytes = self._token_gen.generate_random_bytes(byte_length)
        encoded = encode(raw_bytes, enc)
        elapsed_ms = monotonic_ms() - start

        # If encoding is 'raw', convert bytes to hex string for the dataclass
        token_value = encoded if isinstance(encoded, str) else encoded.hex()

        session_token = SessionToken(
            token=token_value,
            encoding=enc,
            length_bits=bits,
            created_at=iso_timestamp(),
            algorithm=self._config.algorithm_name,
        )

        with self._lock:
            self._generation_count += 1

        logger.debug(
            "Session token #%d generated (%d-bit, %s) in %.2f ms",
            self._generation_count,
            bits,
            enc,
            elapsed_ms,
        )

        return session_token, elapsed_ms

    def generate_batch(
        self,
        count: int,
        length_bits: Optional[int] = None,
        encoding: Optional[str] = None,
    ) -> List[SessionToken]:
        """
        Generate a batch of session tokens.

        Args:
            count:       Number of tokens to generate.
            length_bits: Per-token size in bits.
            encoding:    Encoding scheme.

        Returns:
            List of ``SessionToken`` instances.
        """
        if count <= 0:
            raise ValueError(f"Batch count must be positive, got {count}")
        results = []
        for _ in range(count):
            token, _ = self.generate(length_bits, encoding)
            results.append(token)
        return results

    # ── Serialisation ───────────────────────────────────────────────

    @staticmethod
    def to_dict(session_token: SessionToken) -> Dict[str, Any]:
        """
        Serialise a ``SessionToken`` to a plain dictionary suitable for
        JSON API responses.
        """
        return {
            "token": session_token.token,
            "encoding": session_token.encoding,
            "length": session_token.length_bits,
            "timestamp": session_token.created_at,
            "algorithm": session_token.algorithm,
        }

    # ── Monitoring Helpers ──────────────────────────────────────────

    @property
    def generation_count(self) -> int:
        with self._lock:
            return self._generation_count
