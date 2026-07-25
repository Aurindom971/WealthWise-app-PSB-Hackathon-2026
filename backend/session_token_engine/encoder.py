import base64
from typing import Union


def encode_base64url(data: bytes) -> str:
    """
    Encode raw bytes into a URL-safe Base64 string without padding.
    Uses RFC 4648 §5 alphabet (A-Z, a-z, 0-9, '-', '_').
    """
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def encode_hex(data: bytes) -> str:
    """
    Encode raw bytes into a lowercase hexadecimal string.
    """
    return data.hex()


def encode_raw(data: bytes) -> bytes:
    """
    Passthrough — returns the raw bytes unchanged.
    """
    return data


def encode(data: bytes, encoding: str) -> Union[str, bytes]:
    """
    Dispatch encoder based on the encoding name.

    Args:
        data:     Raw bytes to encode.
        encoding: One of 'base64url', 'hex', 'raw'.

    Returns:
        Encoded representation (str for base64url/hex, bytes for raw).

    Raises:
        ValueError: If the encoding name is not recognised.
    """
    _encoders = {
        "base64url": encode_base64url,
        "hex": encode_hex,
        "raw": encode_raw,
    }
    encoder_fn = _encoders.get(encoding)
    if encoder_fn is None:
        raise ValueError(
            f"Unsupported encoding '{encoding}'. "
            f"Choose from: {', '.join(_encoders.keys())}"
        )
    return encoder_fn(data)


def get_valid_charset(encoding: str) -> str:
    """
    Returns a regex character-class pattern that matches all legal
    characters for a given encoding.

    Useful for the token validator to reject malformed tokens.
    """
    _charsets = {
        "base64url": r"[A-Za-z0-9_\-]",
        "hex": r"[0-9a-f]",
    }
    charset = _charsets.get(encoding)
    if charset is None:
        raise ValueError(f"No charset defined for encoding '{encoding}'")
    return charset
