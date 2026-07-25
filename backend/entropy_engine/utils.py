import math
from typing import List

def normalize_value(value: float, min_val: float, max_val: float) -> float:
    """Normalizes a raw value between 0.0 and 1.0 using min-max scaling."""
    if max_val - min_val == 0:
        return 0.0
    val = (value - min_val) / (max_val - min_val)
    return max(0.0, min(1.0, val))

def calculate_shannon_entropy(probabilities: List[float]) -> float:
    """Calculates Shannon entropy for a given set of probabilities."""
    entropy = 0.0
    total = sum(probabilities)
    if total == 0:
        return 0.0
        
    for p in probabilities:
        if p > 0:
            norm_p = p / total
            entropy -= norm_p * math.log2(norm_p)
    return entropy
