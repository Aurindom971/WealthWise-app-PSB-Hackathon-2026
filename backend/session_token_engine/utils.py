import hmac
import time
from datetime import datetime, timezone


def mask_token(token: str, preview_len: int = 10) -> str:
    """
    Returns a masked preview of a token for safe dashboard display.
    Example: 'mQ4Hs9aB...'

    Never reveals the full token.
    """
    if not isinstance(token, str):
        return "***"
    if len(token) <= preview_len:
        # Even short tokens are partially masked for safety
        half = max(1, len(token) // 2)
        return token[:half] + "..."
    return token[:preview_len] + "..."


def constant_time_compare(a: str, b: str) -> bool:
    """
    Constant-time string comparison using hmac.compare_digest.
    Prevents timing-based side-channel attacks on token comparisons.
    """
    return hmac.compare_digest(a.encode("utf-8"), b.encode("utf-8"))


def iso_timestamp() -> str:
    """
    Returns the current UTC time as an ISO 8601 string.
    Example: '2026-07-25T06:05:00.000000Z'
    """
    return datetime.now(timezone.utc).isoformat()


def monotonic_ms() -> float:
    """
    Returns high-resolution monotonic time in milliseconds.
    Used for measuring generation latency.
    """
    return time.monotonic() * 1000.0
