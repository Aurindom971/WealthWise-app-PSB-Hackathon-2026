import cv2
import numpy as np
from typing import Dict, Any, Tuple, List
from .config import CVEngineConfig

# --------------------------------------------------------------------------- #
#  Deterministic per-ID colour palette using the golden-ratio hue trick       #
# --------------------------------------------------------------------------- #
def _color_for_id(track_id: int) -> Tuple[int, int, int]:
    """Return a unique, vivid BGR colour for a given track ID."""
    golden_ratio_conjugate = 0.618033988749895
    hue = ((track_id * golden_ratio_conjugate) % 1.0) * 180  # OpenCV hue 0-180
    hsv = np.uint8([[[int(hue), 200, 230]]])
    bgr = cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)
    return int(bgr[0, 0, 0]), int(bgr[0, 0, 1]), int(bgr[0, 0, 2])


class Visualizer:
    """
    Renders bounding boxes, optical flow heatmaps, bubbles,
    and a live statistics side panel on the frame.

    Trajectory rendering modes (controlled by config.trail_mode):
        "short"  – draw only the most recent `trail_length` positions (default)
        "full"   – draw the entire stored history
        "hidden" – do not draw any trajectory trail
    """
    def __init__(self, config: CVEngineConfig):
        self.config = config

    # ------------------------------------------------------------------ #
    #  Semi-transparent, fading trail renderer                           #
    # ------------------------------------------------------------------ #
    def _draw_trail(
        self,
        canvas: np.ndarray,
        history: List[Tuple[float, float]],
        color: Tuple[int, int, int],
    ) -> np.ndarray:
        """
        Draws a trajectory trail with per-segment fade (oldest → dimmest,
        newest → brightest) using semi-transparent overlay blending.

        Only consecutive positions within the same fish's history are connected;
        there is no risk of cross-fish lines because each call receives a
        single fish's history list.
        """
        n = len(history)
        if n < 2:
            return canvas

        trail_mode = self.config.trail_mode
        if trail_mode == "hidden":
            return canvas

        # Decide how many points to draw
        if trail_mode == "short":
            max_pts = self.config.trail_length
            pts = history[-max_pts:] if n > max_pts else history
        else:  # "full"
            pts = history

        seg_count = len(pts) - 1
        if seg_count < 1:
            return canvas

        thickness = max(1, min(self.config.trail_thickness, 3))
        alpha_min = self.config.trail_opacity_min
        alpha_max = self.config.trail_opacity_max

        # Pre-create an overlay once and draw all segments, then blend.
        # This is much cheaper than blending per segment.
        overlay = canvas.copy()

        for i in range(seg_count):
            # Lerp factor: 0.0 = oldest, 1.0 = newest
            t = i / max(seg_count - 1, 1)
            alpha = alpha_min + (alpha_max - alpha_min) * t

            # Brightness-scale the colour for a glow-fade effect
            brightness = 0.4 + 0.6 * t  # 40 % → 100 %
            seg_color = (
                int(color[0] * brightness),
                int(color[1] * brightness),
                int(color[2] * brightness),
            )

            pt1 = (int(pts[i][0]), int(pts[i][1]))
            pt2 = (int(pts[i + 1][0]), int(pts[i + 1][1]))
            cv2.line(overlay, pt1, pt2, seg_color, thickness, cv2.LINE_AA)

            # Per-segment alpha blend for true semi-transparency
            cv2.addWeighted(overlay, alpha, canvas, 1.0 - alpha, 0, canvas)
            overlay = canvas.copy()  # reset overlay for next segment

        return canvas

    # ------------------------------------------------------------------ #
    #  Main draw entry-point                                             #
    # ------------------------------------------------------------------ #
    def draw(
        self,
        frame: cv2.typing.MatLike,
        feature_vector: Dict[str, Any],
        internal_maps: Dict[str, Any],
        fps: float,
    ) -> cv2.typing.MatLike:
        """
        Overlays detection annotations on the video frame, and appends a sidebar containing stats.
        """
        # Create a copy to avoid mutating the original pipeline frame
        canvas = frame.copy()

        # 1. Overlay Optical Flow Heatmap
        motion_map = internal_maps.get("motion_map")
        if motion_map is not None:
            # Blend original frame and heatmap
            cv2.addWeighted(motion_map, 0.3, canvas, 0.7, 0, canvas)

        # 1.5. Draw Raw YOLO Detections in Red (before filtering)
        raw_detections = internal_maps.get("raw_detections", [])
        for det in raw_detections:
            rx1, ry1, rx2, ry2 = det["bbox"]
            rconf = det["confidence"]
            rcls = det["class_name"]
            # Bounding box in Red
            cv2.rectangle(canvas, (rx1, ry1), (rx2, ry2), (0, 0, 255), 1)
            raw_label = f"{rcls} ({rconf:.2f})"
            cv2.putText(
                canvas, raw_label, (rx1, max(12, ry1 - 3)),
                cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 255), 1, cv2.LINE_AA
            )

        # 2. Draw Fish Bounding Boxes, Labels & Trajectory Trails
        tracked_fish = internal_maps.get("tracked_fish_raw", [])
        for fish in tracked_fish:
            fish_color = _color_for_id(fish.id)
            x1, y1, x2, y2 = fish.bbox

            # -- Trajectory trail (drawn BEFORE boxes so boxes sit on top) --
            canvas = self._draw_trail(canvas, fish.history, fish_color)

            # Bounding box - thicker lines for visibility
            cv2.rectangle(canvas, (x1, y1), (x2, y2), (0, 255, 0), 3)

            # Label: ID, Speed, Heading - larger font
            label = f"ID: {fish.id} | C: {fish.confidence:.2f} | S: {fish.speed:.1f} | D: {fish.direction:.1f}\u00b0"
            # Draw text background for readability
            (tw, th), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.65, 2)
            text_y = max(25, y1 - 12)
            cv2.rectangle(canvas, (x1, text_y - th - 6), (x1 + tw + 8, text_y + 4), (0, 0, 0), -1)
            cv2.putText(
                canvas, label, (x1 + 4, text_y),
                cv2.FONT_HERSHEY_SIMPLEX, 0.65, (0, 255, 0), 2, cv2.LINE_AA
            )

        # 3. Draw Bubbles
        bubbles_raw = internal_maps.get("bubbles_raw", {})
        centers = bubbles_raw.get("centers", [])
        radii = bubbles_raw.get("radii", [])
        for center, rad in zip(centers, radii):
            cx, cy = map(int, center)
            # Draw circle
            cv2.circle(canvas, (cx, cy), int(rad), (255, 255, 0), 2)

        # 4. Draw FPS and frame info directly on the video (top-left corner)
        info_text = f"FPS: {fps:.1f} | Frame: {feature_vector['frame_number']}"
        (tw, th), _ = cv2.getTextSize(info_text, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2)
        cv2.rectangle(canvas, (8, 8), (18 + tw, 18 + th), (0, 0, 0), -1)
        cv2.putText(
            canvas, info_text, (12, 12 + th),
            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2, cv2.LINE_AA
        )

        return canvas
