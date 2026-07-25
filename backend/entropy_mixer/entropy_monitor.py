import time
from typing import Dict, Any
from .config import MixerConfig

class EntropyMixerMonitor:
    """
    Checks source health, timing decay, and logs availability metrics.
    """
    def __init__(self, config: MixerConfig):
        self.config = config

    def audit_sources(self, combined_blob: Dict[str, Any]) -> Dict[str, Any]:
        """
        Processes aggregated payloads to extract quality statistics and alerts.
        """
        now = time.time()
        
        # Verify freshness by tracking capture time deltas
        aq_age = now - combined_blob["aquarium_entropy"]["timestamp"]
        os_age = now - combined_blob["os_entropy"]["timestamp"]
        cpu_age = now - combined_blob["cpu_entropy"]["timestamp"]
        net_age = now - combined_blob["network_entropy"]["timestamp"]

        source_status = {
            "Aquarium": "Healthy" if aq_age < self.config.max_entropy_age_seconds else "Stale",
            "OS": "Healthy" if os_age < self.config.max_entropy_age_seconds else "Stale",
            "CPU": "Healthy" if cpu_age < self.config.max_entropy_age_seconds else "Stale",
            "HardwareRNG": "Healthy" if combined_blob["hardware_entropy"].get("available", False) else "Unavailable",
            "Network": "Healthy" if net_age < self.config.max_entropy_age_seconds else "Stale"
        }

        # Determine overall grade
        healthy_count = sum(1 for status in source_status.values() if status == "Healthy")
        
        overall = "Excellent"
        if healthy_count < 3:
            overall = "Degraded"
        elif healthy_count == 3:
            overall = "Good"

        return {
            "source_status": source_status,
            "overall_health": overall,
            "active_sources": healthy_count,
            "audit_timestamp": now
        }
