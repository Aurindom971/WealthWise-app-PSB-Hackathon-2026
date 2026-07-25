import threading
from collections import deque
from typing import Any, List, Optional

class FrameBuffer:
    """
    A thread-safe rolling buffer of the last N processed frames.
    """
    def __init__(self, max_size: int = 10):
        self.buffer = deque(maxlen=max_size)
        self.lock = threading.Lock()

    def append(self, frame_data: Any) -> None:
        with self.lock:
            self.buffer.append(frame_data)

    def get_all(self) -> List[Any]:
        with self.lock:
            return list(self.buffer)

    def get_latest(self) -> Optional[Any]:
        with self.lock:
            return self.buffer[-1] if self.buffer else None

    def size(self) -> int:
        with self.lock:
            return len(self.buffer)
            
    def maxsize(self) -> int:
        return self.buffer.maxlen
