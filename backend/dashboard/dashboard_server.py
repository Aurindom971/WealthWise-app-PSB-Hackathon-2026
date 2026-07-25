import sys
import os
import asyncio
import uvicorn
import logging
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dashboard.config import DashboardConfig
from dashboard.websocket_manager import WebSocketManager
from dashboard.data_provider import DataProvider

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger("DashboardServer")

app = FastAPI(title="Aquarium Entropy Monitoring Dashboard API")

# Enable CORS for frontend clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ws_manager = WebSocketManager()
data_provider = DataProvider()
config = DashboardConfig()


@app.on_event("startup")
def startup_event():
    logger.info("Starting up data provider pipeline...")
    data_provider.start()


@app.get("/health")
def health_check():
    return {"status": "healthy", "pipeline_active": data_provider.running}


@app.post("/generate-session-token")
def generate_session_token():
    if not data_provider.session_gen:
        return {"error": "CSPRNG is still initializing/seeding. Please wait."}
    
    # Generate secure token
    token, _ = data_provider.session_gen.generate()
    return {"session_token": token.token}


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await ws_manager.connect(websocket)
    try:
        while True:
            # Broadcast latest pipeline snapshot
            snapshot = data_provider.get_latest_snapshot()
            if snapshot:
                await websocket.send_json(snapshot)
            await asyncio.sleep(config.refresh_rate)
    except WebSocketDisconnect:
        ws_manager.disconnect(websocket)
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        ws_manager.disconnect(websocket)


async def broadcast_loop():
    while True:
        snapshot = data_provider.get_latest_snapshot()
        if snapshot:
            await ws_manager.broadcast(snapshot)
        await asyncio.sleep(config.refresh_rate)





def main():
    logger.info(f"Starting FastAPI Dashboard Server on {config.host}:{config.port}...")
    uvicorn.run(
        "dashboard.dashboard_server:app",
        host=config.host,
        port=config.port,
        log_level="info",
    )


if __name__ == "__main__":
    main()
