import cv2
import json
import logging
from typing import Dict, Any, Tuple, Optional

from .config import CVEngineConfig
from .fish_detector import FishDetector
from .fish_tracker import FishTracker
from .optical_flow import OpticalFlowAnalyzer
from .bubble_detector import BubbleDetector
from .frame_difference import FrameDifferencer
from .ripple_detector import RippleDetector
from .lighting_analyzer import LightingAnalyzer
from .histogram_analyzer import HistogramAnalyzer
from .edge_detector import EdgeAnalyzer
from .noise_estimator import NoiseEstimator

logger = logging.getLogger("AquariumCV")

class FeatureExtractor:
    """
    Aggregates all independent CV analysis modules to generate a single structured numerical feature vector per frame.
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config
        self.detector = FishDetector(config)
        self.tracker = FishTracker(config)
        self.optical_flow = OpticalFlowAnalyzer(config)
        self.bubble_detector = BubbleDetector(config)
        self.differencer = FrameDifferencer(config)
        self.ripple_detector = RippleDetector(config)
        self.lighting_analyzer = LightingAnalyzer(config)
        self.histogram_analyzer = HistogramAnalyzer(config)
        self.edge_analyzer = EdgeAnalyzer(config)
        self.noise_estimator = NoiseEstimator(config)

    def process_frame(
        self, 
        frame: cv2.typing.MatLike, 
        pipeline_meta: Dict[str, Any]
    ) -> Tuple[Dict[str, Any], Dict[str, Any]]:
        """
        Processes a single frame and returns (feature_vector, internal_maps).
        internal_maps contains visual output maps (optical flow heatmap, edges, diff mask) for rendering.
        """
        # 1. Fish Detection
        detections = self.detector.detect(frame)
        raw_detections = getattr(self.detector, "raw_detections", [])

        # 2. Fish Tracking
        tracked_fish = self.tracker.track(detections)
        logger.info(f"[TRACKING DEBUG] Number of tracked fish returned: {len(tracked_fish)}")

        # 3. Dense Optical Flow
        flow_stats, motion_map = self.optical_flow.analyze(frame)

        # 4. Bubble Detection
        bubbles = self.bubble_detector.detect(frame)

        # 5. Frame Difference
        diff_stats, diff_mask = self.differencer.analyze(frame)

        # 6. Ripple Detection
        ripples = self.ripple_detector.analyze(frame, flow_stats)

        # 7. Lighting Analysis
        lighting = self.lighting_analyzer.analyze(frame)

        # 8. Histogram Analysis
        histograms = self.histogram_analyzer.analyze(frame)

        # 9. Edge Detector
        edge_stats, edge_map = self.edge_analyzer.analyze(frame)

        # 10. Noise Estimator
        noise = self.noise_estimator.estimate(frame)

        # Format detection arrays for JSON output
        fish_detections_json = []
        for f in tracked_fish:
            fish_detections_json.append({
                "id": f.id,
                "bbox": f.bbox,
                "centroid": f.centroid,
                "speed": f.speed,
                "direction": f.direction,
                "heading": f.heading,
                "distance_travelled": f.distance_travelled,
                "confidence": f.confidence
            })

        # Format timestamps nicely: e.g. "00:00:08.533"
        video_ts = pipeline_meta.get("video_timestamp", 0.0)
        minutes = int(video_ts // 60)
        seconds = int(video_ts % 60)
        milliseconds = int((video_ts % 1) * 1000)
        formatted_video_ts = f"{minutes:02d}:{seconds:02d}.{milliseconds:03d}"

        # Combine into aggregate vector
        feature_vector = {
            "frame_number": pipeline_meta.get("frame_number", 0),
            "video_timestamp": formatted_video_ts,
            "capture_timestamp": str(pipeline_meta.get("unix_timestamp", 0.0)),
            "fish": {
                "count": len(tracked_fish),
                "detections": fish_detections_json
            },
            "motion": flow_stats,
            "bubbles": {
                "count": bubbles["count"],
                "average_speed": bubbles["average_speed"],
                "average_rise_velocity": bubbles["average_rise_velocity"]
            },
            "frame_difference": {
                "changed_pixels": diff_stats["changed_pixels"],
                "change_percent": diff_stats["change_percent"]
            },
            "ripples": ripples,
            "lighting": lighting,
            "histogram": {
                "rgb_drift": histograms["rgb_drift"],
                "hsv_drift": histograms["hsv_drift"],
                "mean_bgr": histograms["mean_bgr"]
            },
            "edges": {
                "density": edge_stats["density"],
                "change": edge_stats["change"]
            },
            "noise": {
                "pixel_noise": noise["pixel_noise"],
                "sensor_noise": noise["sensor_noise"]
            }
        }

        # Pack visual layers
        internal_maps = {
            "motion_map": motion_map,
            "diff_mask": diff_mask,
            "edge_map": edge_map,
            "tracked_fish_raw": tracked_fish,
            "bubbles_raw": bubbles,
            "raw_detections": raw_detections
        }

        return feature_vector, internal_maps
