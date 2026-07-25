"""
Python Token Service – Utility Helpers
"""


def mask_token(token: str, preview_len: int = 8) -> str:
    """
    Return a safe masked preview of a token for logging.
    Example: 'AbCdEfGh...'

    Never reveals the full token value.
    """
    if not isinstance(token, str) or len(token) == 0:
        return "***"
    chars = min(preview_len, max(1, len(token) // 2))
    return token[:chars] + "..."
