"""
Python Token Service – API Routes

Defines the two REST endpoints:
    GET  /health                  → HealthResponse
    POST /generate-session-token  → TokenResponse | ErrorResponse
"""

import time
import logging

from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse

from .schemas import TokenResponse, ErrorResponse, HealthResponse
from .config import ServiceConfig
from .utils import mask_token

logger = logging.getLogger("TokenService.Routes")

# ── Router ──────────────────────────────────────────────────────────
router = APIRouter()

# These will be injected by app.py at startup
_token_service = None   # AquariumTokenService instance
_service_cfg = None     # ServiceConfig instance


def register_service(token_service, service_cfg: ServiceConfig) -> None:
    """Called once from app.py to wire the singleton service into routes."""
    global _token_service, _service_cfg
    _token_service = token_service
    _service_cfg = service_cfg


# ── GET /health ─────────────────────────────────────────────────────

@router.get(
    "/health",
    response_model=HealthResponse,
    summary="Health Check",
    description="Returns service health status.",
    tags=["Health"],
)
async def health_check() -> HealthResponse:
    return HealthResponse(
        status="healthy",
        service=_service_cfg.service_name if _service_cfg else "Aquarium Token Service",
        version=_service_cfg.service_version if _service_cfg else "1.0",
    )


# ── POST /generate-session-token ───────────────────────────────────

@router.post(
    "/generate-session-token",
    response_model=TokenResponse,
    responses={500: {"model": ErrorResponse}},
    summary="Generate Session Token",
    description=(
        "Generates a cryptographically secure session token using the "
        "Aquarium Entropy Engine (Phases 2-8).  No request body required."
    ),
    tags=["Token Generation"],
)
async def generate_session_token() -> TokenResponse:
    logger.info("POST /generate-session-token")

    if _token_service is None or not _token_service.is_ready:
        logger.error("Token service is not ready")
        return JSONResponse(
            status_code=500,
            content=ErrorResponse(
                success=False,
                error="Session token generation failed.",
            ).model_dump(),
        )

    try:
        t0 = time.monotonic()
        result = _token_service.generate()
        elapsed_ms = (time.monotonic() - t0) * 1000.0

        token_preview = mask_token(
            result["token"],
            _service_cfg.log_token_preview_chars if _service_cfg else 8,
        )

        logger.info(
            "Session Token Generated | "
            "Generation Time: %.1f ms | "
            "Algorithm: %s | "
            "Token Length: %d bits | "
            "Preview: %s",
            elapsed_ms,
            result["algorithm"],
            len(result["token"]) * 4,  # hex chars → bits approximation
            token_preview,
        )

        response = TokenResponse(
            success=True,
            token=result["token"],
            algorithm=result["algorithm"],
            generated_at=result["generated_at"],
            expires_in=result["expires_in"],
        )

        logger.info("Response sent")
        return response

    except Exception:
        logger.exception("Token generation failed")
        return JSONResponse(
            status_code=500,
            content=ErrorResponse(
                success=False,
                error="Session token generation failed.",
            ).model_dump(),
        )
