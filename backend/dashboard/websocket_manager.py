import asyncio
import logging
from typing import Set
from fastapi import WebSocket

logger = logging.getLogger("DashboardWS")


class WebSocketManager:
    """
    Manages active WebSocket connections for live updates.
    """

    def __init__(self):
        self.active_connections: Set[WebSocket] = set()

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.add(websocket)
        logger.info(
            f"Client connected. Active connections: {len(self.active_connections)}"
        )

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            logger.info(
                f"Client disconnected. Active connections: {len(self.active_connections)}"
            )

    async def broadcast(self, data: dict):
        if not self.active_connections:
            return

        disconnected_sockets = set()
        for connection in self.active_connections:
            try:
                await connection.send_json(data)
            except Exception as e:
                logger.warning(f"Error broadcasting to client: {e}")
                disconnected_sockets.add(connection)

        for connection in disconnected_sockets:
            self.disconnect(connection)
