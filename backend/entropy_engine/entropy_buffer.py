import threading
from collections import deque
from typing import Dict, Any, List

class EntropyBuffer:
    """
    A thread-safe rolling buffer that stores past entropy collection payloads.
    Does NOT store raw image/video data.
    """
    def __init__(self, max_size: int = 500):
        self.buffer = deque(maxlen=max_size)
        self.lock = threading.Lock()

    def append(self, entry: Dict[str, Any]) -> None:
        with self.lock:
            # Entry must not contain raw frames/images
            entry_copy = {k: v for k, v in entry.items() if k != "frame_image"}
            self.buffer.append(entry_copy)

    def get_history(self) -> List[Dict[str, Any]]:
        with self.lock:
            return list(self.buffer)

    def size(self) -> int:
        with self.lock:
            return len(self.buffer)
