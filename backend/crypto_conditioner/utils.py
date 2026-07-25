def mask_digest(digest: str) -> str:
    """Masks a digest, showing only the first 16 characters for security."""
    if len(digest) <= 16:
        return digest
    return f"{digest[:16]}..."
