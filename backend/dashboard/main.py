import sys
import os
import threading
import time
import uvicorn

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dashboard.config import DashboardConfig

def run_uvicorn():
    config = DashboardConfig()
    uvicorn.run(
        "dashboard.dashboard_server:app",
        host=config.host,
        port=config.port,
        log_level="warning",  # Keep terminal output clean for print logging
    )

if __name__ == "__main__":
    print("Starting background FastAPI server on port 8000...")
    server_thread = threading.Thread(target=run_uvicorn, daemon=True)
    server_thread.start()
    
    # Allow FastAPI startup_event to fire and initialize the pipeline
    time.sleep(2.0)
    
    print("Launching Desktop Monitoring Window...")
    from dashboard.desktop_monitor import main
    main()
