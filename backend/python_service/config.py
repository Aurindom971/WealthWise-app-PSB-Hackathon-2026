"""
Python Token Service – Configuration

All values can be overridden via environment variables.
"""

import os
from dataclasses import dataclass


@dataclass
class ServiceConfig:
    """Configuration for the FastAPI Token Generation Service."""

    # ── Server ───────────────────────────────────────────────────────
    host: str = os.getenv("TOKEN_SERVICE_HOST", "0.0.0.0")
    port: int = int(os.getenv("TOKEN_SERVICE_PORT", "8100"))
    debug: bool = os.getenv("TOKEN_SERVICE_DEBUG", "false").lower() == "true"

    # ── Logging ──────────────────────────────────────────────────────
    log_level: str = os.getenv("TOKEN_SERVICE_LOG_LEVEL", "INFO")
    log_token_preview_chars: int = int(
        os.getenv("TOKEN_SERVICE_LOG_PREVIEW_CHARS", "8")
    )

    # ── Token ────────────────────────────────────────────────────────
    # Default expiry in seconds returned to callers (30 min)
    token_expires_in: int = int(
        os.getenv("TOKEN_SERVICE_TOKEN_EXPIRES_IN", "1800")
    )

    # ── Service Metadata ─────────────────────────────────────────────
    service_name: str = "Aquarium Token Service"
    service_version: str = "1.0"
