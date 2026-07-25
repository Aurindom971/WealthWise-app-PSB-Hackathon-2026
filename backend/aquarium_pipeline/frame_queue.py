import queue
from typing import Any, Optional

class FrameQueue:
    """
    Thread-safe queue wrapper for feeding downstream CV processes.
    """
    def __init__(self, max_size: int = 30):
        self.queue = queue.Queue(maxsize=max_size)

    def put(self, item: Any, block: bool = True, timeout: Optional[float] = None) -> bool:
        try:
            self.queue.put(item, block=block, timeout=timeout)
            return True
        except queue.Full:
            return False

    def get(self, block: bool = True, timeout: Optional[float] = None) -> Any:
        try:
            return self.queue.get(block=block, timeout=timeout)
        except queue.Empty:
            return None

    def size(self) -> int:
        return self.queue.qsize()

    def is_full(self) -> bool:
        return self.queue.full()

    def clear(self) -> None:
        with self.queue.mutex:
            self.queue.queue.clear()
