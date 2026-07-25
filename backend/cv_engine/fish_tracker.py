import time
import logging
from typing import List, Dict, Any, Tuple
from .config import CVEngineConfig
from .utils import calculate_distance, calculate_angle

logger = logging.getLogger("AquariumCV")

class TrackedFish:
    def __init__(self, track_id: int, centroid: Tuple[float, float], bbox: List[int], confidence: float, max_history: int = 20):
        self.id = track_id
        self.centroid = centroid
        self.bbox = bbox
        self.confidence = confidence
        self.history: List[Tuple[float, float]] = [centroid]
        self.max_history = max_history  # 0 = unlimited (full trail)
        
        # Track statistics
        self.speed = 0.0
        self.direction = 0.0
        self.heading = "Stationary"
        self.distance_travelled = 0.0
        self.last_seen = time.time()
        self.lost_frames = 0
        self.lost_since: float = 0.0  # Timestamp when track was first lost

    def update(self, centroid: Tuple[float, float], bbox: List[int], confidence: float):
        prev_centroid = self.centroid
        self.centroid = centroid
        self.bbox = bbox
        self.confidence = confidence
        self.history.append(centroid)
        # Trim history based on configured max (0 = unlimited for full trail mode)
        if self.max_history > 0 and len(self.history) > self.max_history:
            self.history.pop(0)

        # Calculate metrics
        dist = calculate_distance(prev_centroid, centroid)
        self.distance_travelled += dist
        self.speed = dist  # Speed is pixels per frame
        self.direction = calculate_angle(prev_centroid, centroid)
        self.heading = self._get_heading_string(self.direction)
        
        self.last_seen = time.time()
        self.lost_frames = 0
        self.lost_since = 0.0

    def _get_heading_string(self, angle: float) -> str:
        if self.speed < 1.0:
            return "Stationary"
        # Determine 8-way directional heading
        if 22.5 <= angle < 67.5:
            return "South-East"
        elif 67.5 <= angle < 112.5:
            return "South"
        elif 112.5 <= angle < 157.5:
            return "South-West"
        elif 157.5 <= angle < 202.5:
            return "West"
        elif 202.5 <= angle < 247.5:
            return "North-West"
        elif 247.5 <= angle < 292.5:
            return "North"
        elif 292.5 <= angle < 337.5:
            return "North-East"
        else:
            return "East"

class FishTracker:
    """
    Manages fish tracking objects based on ByteTrack tracking IDs.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.tracked_fish: Dict[int, TrackedFish] = {}
        self.total_lost_tracks = 0
        self.total_recovered_tracks = 0

    def track(self, detections: List[Dict[str, Any]]) -> List[TrackedFish]:
        """
        Processes detections with existing ByteTrack tracking IDs.
        """
        t0 = time.time()
        
        current_frame_ids = set()
        lost_this_frame = 0
        recovered_this_frame = 0

        # Update or create tracks based on ByteTrack ID
        for det in detections:
            track_id = det["id"]
            current_frame_ids.add(track_id)
            det_center = (det["center_x"], det["center_y"])

            if track_id in self.tracked_fish:
                fish = self.tracked_fish[track_id]
                # If it was previously lost, count as recovered
                if fish.lost_frames > 0:
                    recovered_this_frame += 1
                    self.total_recovered_tracks += 1
                fish.update(det_center, det["bbox"], det["confidence"])
            else:
                # New track — determine history cap based on trail mode
                max_hist = self.config.trail_length if self.config.trail_mode == "short" else 0
                self.tracked_fish[track_id] = TrackedFish(
                    track_id, det_center, det["bbox"], det["confidence"],
                    max_history=max_hist
                )

        # Handle tracks not detected in this frame
        now = time.time()
        for track_id, fish in self.tracked_fish.items():
            if track_id not in current_frame_ids:
                if fish.lost_frames == 0:
                    lost_this_frame += 1
                    self.total_lost_tracks += 1
                    fish.lost_since = now  # Record when the track was first lost
                fish.lost_frames += 1

        # Clean up tracks lost for too long (time-based + frame-based fallback)
        timeout = self.config.trail_lost_timeout
        lost_ids = [
            tid for tid, fish in self.tracked_fish.items()
            if fish.lost_frames > self.config.max_lost_frames
            or (fish.lost_since > 0 and (now - fish.lost_since) > timeout)
        ]
        for tid in lost_ids:
            del self.tracked_fish[tid]

        t1 = time.time()
        tracking_time = t1 - t0
        tracking_fps = 1.0 / max(0.001, tracking_time)

        # Log required telemetry
        logger.info(
            f"[TRACKING TELEMETRY] Tracking FPS: {tracking_fps:.2f} | "
            f"Lost Tracks (Frame): {lost_this_frame} | "
            f"Recovered Tracks (Frame): {recovered_this_frame} | "
            f"Total Lost Tracks: {self.total_lost_tracks} | "
            f"Total Recovered Tracks: {self.total_recovered_tracks}"
        )

        # Return only active (not currently lost) tracks
        return [fish for fish in self.tracked_fish.values() if fish.lost_frames == 0]
