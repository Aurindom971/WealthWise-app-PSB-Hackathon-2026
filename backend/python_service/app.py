"""
Python Token Service – FastAPI Application Entry-Point

Boots the Aquarium Entropy Pipeline once on startup, registers the
API routes, and serves on the configured host:port via Uvicorn.

Usage:
    cd backend
    python -m python_service.app
"""

import sys
import os
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# ── Path setup ──────────────────────────────────────────────────────
_BACKEND_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _BACKEND_ROOT not in sys.path:
    sys.path.insert(0, _BACKEND_ROOT)

from python_service.config import ServiceConfig
from python_service.token_service import AquariumTokenService
from python_service.routes import router, register_service

# ── Configuration ───────────────────────────────────────────────────
service_cfg = ServiceConfig()

# ── Logging ─────────────────────────────────────────────────────────
logging.basicConfig(
    level=getattr(logging, service_cfg.log_level.upper(), logging.INFO),
    format="%(asctime)s [%(levelname)s] %(name)s – %(message)s",
)
logger = logging.getLogger("TokenService.App")

# ── Token Service Singleton ─────────────────────────────────────────
token_service = AquariumTokenService(service_cfg)


# ── Lifespan (startup / shutdown) ───────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manages startup and shutdown of the entropy pipeline."""
    logger.info("Starting Aquarium Token Service …")
    token_service.startup()
    register_service(token_service, service_cfg)
    logger.info(
        "Service listening on http://%s:%d", service_cfg.host, service_cfg.port
    )
    yield
    token_service.shutdown()


# ── FastAPI App ─────────────────────────────────────────────────────
app = FastAPI(
    title="Aquarium Token Service",
    description=(
        "Lightweight REST API that exposes the Aquarium Entropy Engine "
        "(Phases 2-8) as a secure session token generator.  "
        "Designed to be consumed by the Node.js banking backend."
    ),
    version=service_cfg.service_version,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS (allow Node.js backend) ────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Register Routes ─────────────────────────────────────────────────
app.include_router(router)


# ── Direct Execution ────────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "python_service.app:app",
        host=service_cfg.host,
        port=service_cfg.port,
        reload=service_cfg.debug,
        log_level=service_cfg.log_level.lower(),
    )
