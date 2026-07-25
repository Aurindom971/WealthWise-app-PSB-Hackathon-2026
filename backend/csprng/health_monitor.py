import time
from typing import Dict, Any
from .config import CSPRNGConfig
from .seed_manager import SeedManager
from .random_generator import RandomByteGenerator
from .reseed_manager import ReseedManager

class CsprngHealthMonitor:
    """
    Monitors generator health, reseed latency, output rates, and state age.
    """
    def __init__(
        self, 
        config: CSPRNGConfig, 
        seed_manager: SeedManager, 
        generator: RandomByteGenerator,
        reseed_manager: ReseedManager
    ):
        self.config = config
        self.seed_manager = seed_manager
        self.generator = generator
        self.reseed_mgr = reseed_manager
        self.start_time = time.time()

    def get_stats(self) -> Dict[str, Any]:
        """
        Gathers performance counters and computes status.
        """
        now = time.time()
        age = now - self.reseed_mgr.last_reseed_time
        
        # Generation rate
        run_time = now - self.start_time
        gen_rate = self.generator.bytes_generated_count / run_time if run_time > 0 else 0.0

        # Health evaluation
        health = "Excellent"
        if age > (self.config.reseed_interval * 2.0):
            health = "Warning (Stale Seed)"
        elif age > (self.config.reseed_interval * 5.0):
            health = "Critical (Reseed Failure)"

        return {
            "generator_status": "Active",
            "seed_age_seconds": age,
            "last_reseed_time": self.reseed_mgr.last_reseed_time,
            "reseed_count": self.reseed_mgr.reseed_count,
            "bytes_generated": self.generator.bytes_generated_count,
            "generation_rate_bps": gen_rate,
            "generator_health": health
        }
class CsprngMonitor:
    # Alias to keep config happy
    pass
