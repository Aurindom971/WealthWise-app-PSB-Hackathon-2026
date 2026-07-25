import time
import numpy as np
from typing import Dict, Any, List
from .config import MixerConfig

class CpuTimingEntropySource:
    """
    Measures scheduling and execution variability by capturing high-resolution CPU timing variations.
    """
    def __init__(self, config: MixerConfig):
        self.config = config

    def collect(self) -> Dict[str, Any]:
        """
        Gathers high-resolution samples of execution timing loops and calculates latency jitter.
        """
        samples: List[float] = []
        
        # Measure scheduling/execution timing variations
        # We loop and capture high resolution diffs (nanosecond-level)
        for _ in range(self.config.cpu_samples_count):
            t0 = time.perf_counter_ns()
            
            # Tiny busy execution to test CPU cache/thread scheduling variation
            # Basic mathematical operation
            _ = sum(i * i for i in range(50))
            
            t1 = time.perf_counter_ns()
            samples.append(float(t1 - t0))

        # Calculate variance and average jitter
        timing_diffs = np.diff(samples)
        variance = float(np.var(samples))
        avg_jitter = float(np.mean(np.abs(timing_diffs))) if len(timing_diffs) > 0 else 0.0

        # Scale jitter score (normalized)
        # Nanosecond variance can be large, we clip it
        jitter_score = float(np.clip(avg_jitter / 1000.0, 0.0, 1.0))

        return {
            "source": "CPU Timing Jitter",
            "timestamp": time.time(),
            "timing_samples": samples[:20],  # Keep representation payload small
            "timing_variance": variance,
            "average_jitter_ns": avg_jitter,
            "jitter_score": jitter_score
        }
