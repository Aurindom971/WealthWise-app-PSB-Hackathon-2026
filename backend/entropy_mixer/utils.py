import base64

def bytes_to_hex(b: bytes) -> str:
    """Converts bytes to hex string."""
    return b.hex()

def bytes_to_base64(b: bytes) -> str:
    """Converts bytes to base64 string."""
    return base64.b64encode(b).decode("utf-8")
