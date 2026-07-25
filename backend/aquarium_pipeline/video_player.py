import time
import cv2
import threading
import logging
from typing import Dict, Any, Tuple, Optional

from .config import PipelineConfig
from .video_loader import VideoLoader
from .frame_buffer import FrameBuffer
from .frame_queue import FrameQueue

# Configure Logger
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(threadName)s: %(message)s"
)
logger = logging.getLogger("AquariumPipeline")

class VideoPlayer:
    """
    Orchestrates ingestion, resizing, metadata injection, buffering, and queueing
    within a background thread running at the native video FPS.
    """
    def __init__(self, config: PipelineConfig):
        self.config = config
        self.loader = VideoLoader(config.video_path)
        self.buffer = FrameBuffer(config.buffer_size)
        self.queue = FrameQueue(config.queue_size)

        self._stop_event = threading.Event()
        self._thread: Optional[threading.Thread] = None

        # Stats / State
        self.loop_count = 0
        self.playback_status = "Stopped"
        self.start_time: float = 0.0
        self.total_processed_frames = 0
        
        # Native details
        self.native_fps = self.loader.metadata["fps"]
        self.frame_interval = 1.0 / self.native_fps if self.native_fps > 0 else 1.0 / 60.0

    def start(self) -> None:
        if self._thread is not None and self._thread.is_alive():
            logger.warning("Playback thread is already running.")
            return

        self._stop_event.clear()
        self.start_time = time.time()
        self.playback_status = "Playing"
        self._thread = threading.Thread(
            target=self._run_loop, 
            name="VideoPlayerThread", 
            daemon=True
        )
        self._thread.start()
        logger.info("Video player pipeline thread started.")

    def stop(self) -> None:
        self.playback_status = "Stopped"
        self._stop_event.set()
        if self._thread is not None:
            self._thread.join(timeout=2.0)
            self._thread = None
        logger.info("Video player pipeline thread stopped.")

    def _run_loop(self) -> None:
        frame_idx_in_video = 0
        
        # FPS Calculation
        fps_start_time = time.time()
        fps_frame_count = 0
        current_fps = self.native_fps

        while not self._stop_event.is_set():
            loop_start = time.time()

            success, frame, looped = self.loader.read_next_frame()
            if not success:
                logger.error("Failed to read frame and could not loop back.")
                self.playback_status = "Error"
                break

            if looped:
                self.loop_count += 1
                frame_idx_in_video = 0
                logger.info(f"Video ended; automatically looping back. Loop count: {self.loop_count}")

            # Resize frame
            if (frame.shape[1], frame.shape[0]) != (self.config.target_width, self.config.target_height):
                frame = cv2.resize(frame, (self.config.target_width, self.config.target_height))

            self.total_processed_frames += 1
            frame_idx_in_video += 1

            # Times
            unix_ts = time.time()
            elapsed_time = unix_ts - self.start_time
            video_ts = frame_idx_in_video / self.native_fps if self.native_fps > 0 else 0.0

            # Package metadata
            metadata = {
                "frame_number": self.total_processed_frames,
                "video_frame_index": frame_idx_in_video,
                "video_timestamp": video_ts,
                "unix_timestamp": unix_ts,
                "elapsed_time": elapsed_time,
                "loop_count": self.loop_count,
            }

            frame_package = (frame, metadata)

            # Store in rolling buffer
            self.buffer.append(frame_package)

            # Put in thread-safe queue. If full, discard oldest or wait. 
            # We'll drop/skip in the queue or non-block put to prevent block.
            # To avoid memory build up or blocking the feed thread, we'll try non-blocking put.
            success_put = self.queue.put(frame_package, block=False)
            if not success_put:
                # If queue is full, we consume one element to maintain latest frames
                self.queue.get(block=False)
                self.queue.put(frame_package, block=False)

            # Manage FPS calculation and logging
            fps_frame_count += 1
            now = time.time()
            if now - fps_start_time >= 1.0:
                current_fps = fps_frame_count / (now - fps_start_time)
                logger.info(
                    f"Status: {self.playback_status} | Loop: {self.loop_count} | "
                    f"Frame: {self.total_processed_frames} | Live FPS: {current_fps:.2f} | "
                    f"Queue: {self.queue.size()}/{self.config.queue_size} | "
                    f"Buffer: {self.buffer.size()}/{self.config.buffer_size}"
                )
                fps_frame_count = 0
                fps_start_time = now

            # Sleep to match video speed
            elapsed_processing = time.time() - loop_start
            sleep_time = self.frame_interval - elapsed_processing
            if sleep_time > 0:
                time.sleep(sleep_time)

    def get_next_frame(self, timeout: Optional[float] = 1.0) -> Optional[Tuple[cv2.typing.MatLike, Dict[str, Any]]]:
        """
        Retrieves the next frame and its metadata from the frame queue.
        Returns Tuple[frame_image, metadata_dict] or None on timeout/empty.
        """
        return self.queue.get(block=True, timeout=timeout)
        
    def close(self) -> None:
        self.stop()
        self.loader.close()
