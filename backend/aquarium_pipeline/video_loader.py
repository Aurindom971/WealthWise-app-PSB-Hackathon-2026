import os
import cv2
from typing import Dict, Any, Tuple, Optional

class VideoLoader:
    """
    Handles loading, validation, metadata extraction, and loop-back reading
    of the video file.
    """
    def __init__(self, video_path: str):
        self.video_path = video_path
        if not os.path.exists(self.video_path):
            # Fallback check for relative paths
            alt_path = os.path.join("assets", "videos", "aquarium.mp4")
            if os.path.exists(alt_path):
                self.video_path = alt_path
            else:
                raise FileNotFoundError(f"Video file not found at: {self.video_path}")

        self.cap = cv2.VideoCapture(self.video_path)
        if not self.cap.isOpened():
            raise IOError(f"Failed to open video file: {self.video_path}")

        self.metadata = self._extract_metadata()

    def _extract_metadata(self) -> Dict[str, Any]:
        width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = self.cap.get(cv2.CAP_PROP_FPS)
        total_frames = int(self.cap.get(cv2.CAP_PROP_FRAME_COUNT))
        
        # Guard against zero division
        duration = total_frames / fps if fps > 0 else 0.0

        return {
            "resolution": (width, height),
            "fps": fps,
            "total_frames": total_frames,
            "duration_seconds": duration,
            "path": self.video_path
        }

    def print_metadata(self) -> None:
        print("=" * 50)
        print("Aquarium Video Metadata:")
        print(f"  File Path:    {self.metadata['path']}")
        print(f"  Resolution:   {self.metadata['resolution'][0]}x{self.metadata['resolution'][1]}")
        print(f"  FPS:          {self.metadata['fps']:.2f}")
        print(f"  Total Frames: {self.metadata['total_frames']}")
        print(f"  Duration:     {self.metadata['duration_seconds']:.2f} seconds")
        print("=" * 50)

    def read_next_frame(self) -> Tuple[bool, Optional[cv2.typing.MatLike], bool]:
        """
        Reads the next frame. If the end is reached, seeks back to the start and returns (True, frame, True).
        Returns (success, frame, looped_flag).
        """
        success, frame = self.cap.read()
        looped = False

        if not success:
            # Loop back to the beginning
            self.cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
            success, frame = self.cap.read()
            looped = True

        return success, frame, looped

    def close(self) -> None:
        if self.cap.isOpened():
            self.cap.release()
