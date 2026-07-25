import time
from typing import Dict, Any, List

class ConditioningMonitor:
    """
    Audits latency metrics, success indicators, and average processing times.
    """
    def __init__(self):
        self.operation_count = 0
        self.failure_count = 0
        self.latencies: List[float] = []

    def log_success(self, duration_ms: float) -> None:
        self.operation_count += 1
        self.latencies.append(duration_ms)
        if len(self.latencies) > 1000:
            self.latencies.pop(0)

    def log_failure(self) -> None:
        self.failure_count += 1

    def get_stats(self) -> Dict[str, Any]:
        avg_time = sum(self.latencies) / len(self.latencies) if self.latencies else 0.0
        return {
            "total_operations": self.operation_count,
            "failure_count": self.failure_count,
            "average_processing_time_ms": avg_time,
            "success_rate": (self.operation_count / (self.operation_count + self.failure_count)) * 100.0 if (self.operation_count + self.failure_count) > 0 else 100.0
        }
