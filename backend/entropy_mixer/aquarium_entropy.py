import time
from typing import Dict, Any
from entropy_engine.entropy_pool import EntropyPool

class AquariumEntropySource:
    """
    Interfaces directly with Phase 4 EntropyPool to pull metrics and historical data.
    """
    def __init__(self, pool: EntropyPool):
        self.pool = pool

    def collect(self) -> Dict[str, Any]:
        """
        Gathers current metrics from the active pool.
        """
        status = self.pool.get_status()
        
        # Pull historical values (take the last 10 points)
        with self.pool.lock:
            history = list(self.pool.entropy_history[-10:])

        return {
            "source": "Phase 4 Aquarium Entropy Pool",
            "timestamp": time.time(),
            "entropy_score": status["current_size"],
            "pool_status": status,
            "pool_health": status["health"],
            "entropy_history_sample": history
        }
