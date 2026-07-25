import base64

def bytes_to_hex(b: bytes) -> str:
    return b.hex()

def bytes_to_base64(b: bytes) -> str:
    return base64.b64encode(b).decode("utf-8")
