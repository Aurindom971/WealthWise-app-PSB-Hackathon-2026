import re
import logging
from dataclasses import dataclass, field
from typing import List

from .encoder import get_valid_charset
from .utils import mask_token

logger = logging.getLogger("SessionTokenEngine.Validator")


@dataclass(frozen=True)
class ValidationResult:
    """
    Immutable result of a structural token validation.
    """

    is_valid: bool
    errors: List[str]
    token_preview: str  # masked preview, never the full token


class TokenValidator:
    """
    Structural validation of session tokens.

    Validates:
      • Non-empty value
      • Correct encoding character set
      • Minimum byte-length
      • Base64URL padding correctness
      • Hex string even-length

    Does NOT perform authentication or session management.
    """

    def __init__(self, min_token_bits: int = 128, preview_len: int = 10) -> None:
        self._min_token_bits = min_token_bits
        self._preview_len = preview_len

    def validate(self, token: str, encoding: str = "base64url") -> ValidationResult:
        """
        Validate the structural integrity of a token string.

        Args:
            token:    The encoded token string to validate.
            encoding: The encoding that was used ('base64url' or 'hex').

        Returns:
            A ``ValidationResult`` with ``is_valid`` and any ``errors``.
        """
        errors: List[str] = []
        preview = mask_token(token, self._preview_len) if isinstance(token, str) else "***"

        # ── 1. Non-empty ────────────────────────────────────────────
        if not token or not isinstance(token, str):
            errors.append("Token is empty or not a string")
            return ValidationResult(is_valid=False, errors=errors, token_preview=preview)

        # ── 2. Character set ────────────────────────────────────────
        try:
            charset_pattern = get_valid_charset(encoding)
            if not re.fullmatch(f"{charset_pattern}+", token):
                errors.append(
                    f"Token contains characters outside the valid "
                    f"'{encoding}' charset"
                )
        except ValueError:
            # 'raw' encoding has no charset to validate
            pass

        # ── 3. Encoding-specific structural checks ──────────────────
        if encoding == "base64url":
            # Base64URL without padding — length must be valid
            remainder = len(token) % 4
            # Valid remainders after stripping padding: 0, 2, 3
            if remainder == 1:
                errors.append(
                    "Invalid Base64URL length (mod-4 remainder is 1, "
                    "which cannot occur in valid Base64)"
                )

        elif encoding == "hex":
            if len(token) % 2 != 0:
                errors.append("Hex-encoded token must have even length")

        # ── 4. Minimum length ───────────────────────────────────────
        estimated_bytes = self._estimate_byte_length(token, encoding)
        min_bytes = self._min_token_bits // 8
        if estimated_bytes < min_bytes:
            errors.append(
                f"Token too short: estimated {estimated_bytes} bytes, "
                f"minimum required {min_bytes} bytes ({self._min_token_bits} bits)"
            )

        is_valid = len(errors) == 0
        if not is_valid:
            logger.warning(
                "Token validation failed [%s]: %s",
                preview,
                "; ".join(errors),
            )

        return ValidationResult(
            is_valid=is_valid,
            errors=errors,
            token_preview=preview,
        )

    # ── Internal Helpers ────────────────────────────────────────────

    @staticmethod
    def _estimate_byte_length(token: str, encoding: str) -> int:
        """
        Estimate the raw byte-length represented by an encoded token.
        """
        if encoding == "hex":
            return len(token) // 2
        elif encoding == "base64url":
            # Base64 encodes 3 bytes into 4 chars; without padding:
            # bytes = floor(len * 3 / 4)
            return (len(token) * 3) // 4
        else:
            return len(token)
