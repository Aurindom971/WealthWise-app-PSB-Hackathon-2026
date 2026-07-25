import threading
import time
import logging
from typing import Dict, Any

from .config import SessionTokenConfig

logger = logging.getLogger("SessionTokenEngine.HealthMonitor")


class TokenHealthMonitor:
    """
    Tracks health statistics for the session token generation engine.

    All counters are thread-safe and can be queried concurrently.
    """

    def __init__(self, config: SessionTokenConfig) -> None:
        self._config = config
        self._lock = threading.Lock()

        # ── Counters ────────────────────────────────────────────────
        self._total_generated: int = 0
        self._total_errors: int = 0
        self._total_generation_time_ms: float = 0.0

        # ── Timestamps ──────────────────────────────────────────────
        self._start_time: float = time.time()
        self._last_generation_time: float = 0.0

    # ── Recording Methods ───────────────────────────────────────────

    def record_generation(self, duration_ms: float) -> None:
        """
        Record a successful token generation event.

        Args:
            duration_ms: Time taken to generate the token, in milliseconds.
        """
        with self._lock:
            self._total_generated += 1
            self._total_generation_time_ms += duration_ms
            self._last_generation_time = time.time()

    def record_error(self) -> None:
        """Record a token generation failure."""
        with self._lock:
            self._total_errors += 1

    # ── Stats Snapshot ──────────────────────────────────────────────

    def get_health_stats(self) -> Dict[str, Any]:
        """
        Returns a structured snapshot of the generator health.
        """
        with self._lock:
            now = time.time()
            uptime = now - self._start_time

            # Generation rate (tokens / second)
            gen_rate = (
                self._total_generated / uptime if uptime > 0 else 0.0
            )

            # Average generation time (ms)
            avg_gen_time = (
                self._total_generation_time_ms / self._total_generated
                if self._total_generated > 0
                else 0.0
            )

            # Health status evaluation
            health = self._evaluate_health()

            last_gen_display = (
                time.ctime(self._last_generation_time)
                if self._last_generation_time > 0
                else "Never"
            )

            return {
                "total_tokens_generated": self._total_generated,
                "generation_rate_tps": gen_rate,
                "average_generation_time_ms": avg_gen_time,
                "current_encoding": self._config.default_encoding,
                "generator_status": "Active",
                "generator_health": health,
                "total_errors": self._total_errors,
                "last_generation_timestamp": last_gen_display,
                "uptime_seconds": uptime,
            }

    # ── Internal ────────────────────────────────────────────────────

    def _evaluate_health(self) -> str:
        """
        Evaluate generator health based on error rate and activity.
        Must be called while holding ``self._lock``.
        """
        if self._total_generated == 0:
            return "Idle"

        error_rate = self._total_errors / self._total_generated
        if error_rate > 0.10:
            return "Critical"
        if error_rate > 0.01:
            return "Degraded"

        # Check for stale generator (no generation in last 30s)
        if self._last_generation_time > 0:
            staleness = time.time() - self._last_generation_time
            if staleness > 30.0:
                return "Warning (Stale)"

        return "Excellent"
