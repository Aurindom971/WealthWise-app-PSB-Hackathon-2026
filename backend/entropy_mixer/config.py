from dataclasses import dataclass, field
from typing import List

@dataclass
class MixerConfig:
    # CPU Timing Configuration
    cpu_samples_count: int = 100
    
    # OS Entropy Configuration
    os_entropy_bytes: int = 64
    
    # Network Timing Config
    # Lightweight, using DNS servers which respond quickly
    network_hosts: List[str] = field(default_factory=lambda: [
        "8.8.8.8",      # Google DNS
        "1.1.1.1",      # Cloudflare DNS
        "9.9.9.9"       # Quad9 DNS
    ])
    network_port: int = 53
    network_timeout: float = 0.5
    network_samples: int = 3
    
    # Monitor alert thresholds
    max_entropy_age_seconds: float = 2.0
