from dataclasses import dataclass


@dataclass
class SessionTokenConfig:
    """
    Configuration for the Secure Session Token Generation Engine.
    All settings are tunable without modifying source code.
    """

    # ── Token Defaults ──────────────────────────────────────────────
    # Default token size in bits. Must be a multiple of 8.
    default_token_bits: int = 256

    # Default encoding: "base64url", "hex", or "raw"
    default_encoding: str = "base64url"

    # ── Dashboard ────────────────────────────────────────────────────
    dashboard_enabled: bool = True
    dashboard_refresh_interval: float = 0.15  # seconds

    # Maximum characters to reveal in the masked token preview
    max_token_preview_chars: int = 10

    # ── Logging / Debug ──────────────────────────────────────────────
    log_level: str = "INFO"
    debug_mode: bool = False

    # ── Algorithm Metadata ───────────────────────────────────────────
    algorithm_name: str = "ChaCha20 CSPRNG"

    # ── Validation ───────────────────────────────────────────────────
    # Minimum acceptable token length in bits for the validator
    min_token_bits: int = 128

    def __post_init__(self) -> None:
        if self.default_token_bits % 8 != 0:
            raise ValueError("default_token_bits must be a multiple of 8")
        if self.default_token_bits < self.min_token_bits:
            raise ValueError(
                f"default_token_bits ({self.default_token_bits}) must be >= "
                f"min_token_bits ({self.min_token_bits})"
            )
        if self.default_encoding not in ("base64url", "hex", "raw"):
            raise ValueError(
                f"Unsupported encoding '{self.default_encoding}'. "
                "Must be 'base64url', 'hex', or 'raw'."
            )
