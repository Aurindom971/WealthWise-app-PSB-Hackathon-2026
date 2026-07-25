from dataclasses import dataclass


@dataclass
class DashboardConfig:
    # Websocket Server port
    port: int = 8000
    host: str = "0.0.0.0"

    # Dashboard Refresh Interval in seconds (e.g. 0.05 for 20 FPS)
    refresh_rate: float = 0.05

    # Video display settings
    video_width: int = 640
    video_height: int = 360

    # UI Theme
    theme: str = "dark"

    # Enabled panels
    show_video: bool = True
    show_cv_stats: bool = True
    show_pipeline: bool = True
    show_security: bool = True
