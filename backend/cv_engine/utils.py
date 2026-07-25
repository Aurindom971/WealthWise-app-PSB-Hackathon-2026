import math
from typing import Tuple

def calculate_distance(p1: Tuple[float, float], p2: Tuple[float, float]) -> float:
    """Calculates Euclidean distance between two points."""
    return math.sqrt((p1[0] - p2[0]) ** 2 + (p1[1] - p2[1]) ** 2)

def calculate_angle(p1: Tuple[float, float], p2: Tuple[float, float]) -> float:
    """Calculates directional angle/heading in degrees from p1 to p2."""
    dx = p2[0] - p1[0]
    dy = p2[1] - p1[1]
    angle_rad = math.atan2(dy, dx)
    angle_deg = math.degrees(angle_rad)
    return (angle_deg + 360) % 360  # Normalize to 0-360 degrees
