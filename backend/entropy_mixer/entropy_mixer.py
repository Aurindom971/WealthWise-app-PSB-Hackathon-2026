import time
from typing import Dict, Any

from .config import MixerConfig
from .aquarium_entropy import AquariumEntropySource
from .os_entropy import OsEntropySource
from .cpu_entropy import CpuTimingEntropySource
from .hardware_rng import HardwareRngSource
from .network_entropy import NetworkEntropySource
from entropy_engine.entropy_pool import EntropyPool

class EntropyMixer:
    """
    Coordinates gathering and assembling entropy payloads from 5 distinct sources.
    Does NOT perform cryptographic mixing/hashing.
    """
    def __init__(self, config: MixerConfig, pool: EntropyPool):
        self.config = config
        self.aquarium_src = AquariumEntropySource(pool)
        self.os_src = OsEntropySource(config)
        self.cpu_src = CpuTimingEntropySource(config)
        self.hw_src = HardwareRngSource(config)
        self.net_src = NetworkEntropySource(config)

    def collect_all_entropy(self) -> Dict[str, Any]:
        """
        Gathers individual source structures and wraps them into a single unified entropy blob.
        """
        aq_payload = self.aquarium_src.collect()
        os_payload = self.os_src.collect()
        cpu_payload = self.cpu_src.collect()
        hw_payload = self.hw_src.collect()
        net_payload = self.net_src.collect()

        timestamp = time.time()

        # Count active/available sources
        source_count = 4  # Aquarium, OS, CPU, Network always active
        if hw_payload.get("available", False):
            source_count += 1

        combined_entropy_blob = {
            "aquarium_entropy": aq_payload,
            "os_entropy": os_payload,
            "cpu_entropy": cpu_payload,
            "hardware_entropy": hw_payload,
            "network_entropy": net_payload,
            "timestamp": str(timestamp),
            "source_count": source_count
        }

        return combined_entropy_blob
