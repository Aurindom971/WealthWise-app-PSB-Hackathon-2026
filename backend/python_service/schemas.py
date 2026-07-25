"""
Python Token Service – Pydantic Response Schemas
"""

from pydantic import BaseModel, Field


# ── POST /generate-session-token ────────────────────────────────────


class TokenResponse(BaseModel):
    """Successful token generation response."""

    success: bool = Field(True, description="Whether token generation succeeded")
    token: str = Field(..., description="The generated session token")
    algorithm: str = Field(..., description="Algorithm used for generation")
    generated_at: str = Field(
        ..., description="UTC ISO-8601 timestamp of generation"
    )
    expires_in: int = Field(
        ..., description="Token validity in seconds"
    )


class ErrorResponse(BaseModel):
    """Error response for failed token generation."""

    success: bool = Field(False, description="Always false on error")
    error: str = Field(..., description="Human-readable error message")


# ── GET /health ─────────────────────────────────────────────────────


class HealthResponse(BaseModel):
    """Health-check response."""

    status: str = Field(..., description="Service health status")
    service: str = Field(..., description="Service name")
    version: str = Field(..., description="Service version")
