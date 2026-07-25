import time
import logging
from typing import Callable
from .config import CSPRNGConfig
from .seed_manager import SeedManager
from .chacha20_csprng import ChaCha20Csprng

logger = logging.getLogger("AquariumCSPRNG")

class ReseedManager:
    """
    Manages automatic background reseeding of the CSPRNG.
    Uses a callback to request new seed material from the Phase 6 Conditioner.
    """
    def __init__(
        self, 
        config: CSPRNGConfig, 
        seed_manager: SeedManager, 
        csprng: ChaCha20Csprng,
        get_fresh_seed_callback: Callable[[], str]
    ):
        self.config = config
        self.seed_manager = seed_manager
        self.csprng = csprng
        self.get_fresh_seed_callback = get_fresh_seed_callback
        
        self.reseed_count = 0
        self.last_reseed_time = time.time()

    def check_and_reseed(self) -> bool:
        """
        Determines if the reseed interval has elapsed and executes reseed.
        Returns True if a reseed occurred.
        """
        now = time.time()
        if now - self.last_reseed_time >= self.config.reseed_interval:
            logger.info("Reseed interval reached. Initiating automatic CSPRNG reseed...")
            try:
                # 1. Grab new digest from Callback
                fresh_hex = self.get_fresh_seed_callback()
                
                # 2. Update Seed Manager
                self.seed_manager.load_seed(fresh_hex)
                
                # 3. Trigger CSPRNG internal reseed
                self.csprng.reseed()
                
                self.reseed_count += 1
                self.last_reseed_time = now
                logger.info(f"CSPRNG successfully reseeded. Reseed Count: {self.reseed_count}")
                return True
            except Exception as e:
                logger.error(f"Failed to execute automatic reseed: {e}")
                
        return False
