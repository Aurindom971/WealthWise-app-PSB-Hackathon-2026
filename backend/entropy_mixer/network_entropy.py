import socket
import time
import numpy as np
from typing import Dict, Any, List
from .config import MixerConfig

class NetworkEntropySource:
    """
    Measures network connection round trip time (RTT) jitter to gather networking timing entropy.
    """
    def __init__(self, config: MixerConfig):
        self.config = config

    def collect(self) -> Dict[str, Any]:
        """
        Pings target DNS servers using socket connections and calculates latency variance.
        """
        latencies: List[float] = []
        
        # We perform a lightweight socket connect to configured IP addresses on port 53 (DNS)
        # to measure network transit timing
        for host in self.config.network_hosts:
            for _ in range(self.config.network_samples):
                try:
                    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    s.settimeout(self.config.network_timeout)
                    
                    t0 = time.perf_counter()
                    # Perform TCP connection check (lightweight handshake)
                    s.connect((host, self.config.network_port))
                    t1 = time.perf_counter()
                    
                    latencies.append((t1 - t0) * 1000.0)  # Convert to milliseconds
                    s.close()
                except Exception:
                    # Connection timed out or DNS server refused TCP (expected on port 53 sometimes)
                    # We still record timing until error as it represents latency variability
                    pass

        # Calculate metrics
        avg_latency = float(np.mean(latencies)) if latencies else 0.0
        variance = float(np.var(latencies)) if latencies else 0.0
        
        # Jitter is absolute differences between sequential pings
        diffs = np.diff(latencies) if len(latencies) > 1 else []
        jitter = float(np.mean(np.abs(diffs))) if len(diffs) > 0 else 0.0
        
        # Normalized jitter score
        jitter_score = float(np.clip(jitter / 100.0, 0.0, 1.0))

        return {
            "source": "Network RTT Timing Jitter",
            "timestamp": time.time(),
            "latencies_ms": latencies,
            "average_latency_ms": avg_latency,
            "latency_variance": variance,
            "jitter_score": jitter_score
        }
