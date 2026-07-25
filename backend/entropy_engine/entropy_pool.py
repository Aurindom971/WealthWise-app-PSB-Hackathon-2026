import time
import threading
from typing import Dict, Any, List
from .config import EntropyConfig

class EntropyPool:
    """
    Accumulates numeric entropy values from normalized features.
    Maintains size, capacity, age, and health metrics.
    Does NOT store raw image/video data.
    """
    def __init__(self, config: EntropyConfig):
        self.config = config
        self.lock = threading.Lock()
        
        # Pool properties
        self.current_entropy_val = 0.0
        self.total_extracted = 0.0
        self.pool_age = 0.0
        self.start_time = time.time()
        self.entropy_history: List[float] = []

    def accumulate(self, entropy_scores: Dict[str, float]) -> None:
        """
        Adds current composite entropy score to the pool.
        """
        with self.lock:
            # Composite score represents normalized entry value
            score = entropy_scores.get("composite", 0.0)
            
            # Map score to discrete pool values. 
            # We scale the contribution to represent gradual accumulation.
            increment = score * 50.0  # arbitrary scale factor to fill the pool gradually
            self.current_entropy_val += increment

            # Cap pool size at maximum configured capacity
            if self.current_entropy_val > self.config.pool_max_capacity:
                self.current_entropy_val = self.config.pool_max_capacity

            self.total_extracted += increment
            self.pool_age = time.time() - self.start_time
            self.entropy_history.append(self.current_entropy_val)
            
            # Cap history array size
            if len(self.entropy_history) > 1000:
                self.entropy_history.pop(0)

    def get_status(self) -> Dict[str, Any]:
        with self.lock:
            fill_pct = (self.current_entropy_val / self.config.pool_max_capacity) * 100.0
            
            # Health is rated based on age and accumulation activity
            health = "Excellent"
            if fill_pct < 10.0:
                health = "Cold"
            elif fill_pct < 40.0:
                health = "Initializing"

            return {
                "current_size": self.current_entropy_val,
                "max_capacity": self.config.pool_max_capacity,
                "fill_percentage": fill_pct,
                "health": health,
                "pool_age_seconds": self.pool_age,
                "total_extracted": self.total_extracted
            }

    def drain(self, amount: float) -> float:
        """
        Drains a specified amount of entropy from the pool.
        Returns the amount actually drained.
        """
        with self.lock:
            drained = min(amount, self.current_entropy_val)
            self.current_entropy_val -= drained
            return drained
