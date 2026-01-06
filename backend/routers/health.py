"""
Health check and system status routes
"""
from fastapi import APIRouter
from datetime import datetime
import logging

from backend.models.schemas import HealthCheckResponse
from backend.config import settings
from backend.services.database_service import database_service

logger = logging.getLogger(__name__)

router = APIRouter(tags=["Health"])


@router.get("/health", response_model=HealthCheckResponse)
@router.get("/health/", response_model=HealthCheckResponse, include_in_schema=False)
async def health_check():
    """
    Check system health and status

    **Response:**
    ```json
    {
        "status": "healthy",
        "version": "1.0.0",
        "database_connected": true,
        "openai_configured": true,
        "timestamp": "2025-12-15T10:30:00"
    }
    ```
    """
    try:
        # Test database connection
        db_connected = await database_service.test_connection()

        # Check if OpenAI is configured
        openai_configured = bool(settings.OPENAI_API_KEY and settings.OPENAI_API_KEY != "")

        status = "healthy" if (db_connected and openai_configured) else "degraded"

        return HealthCheckResponse(
            status=status,
            version=settings.APP_VERSION,
            database_connected=db_connected,
            openai_configured=openai_configured,
            timestamp=datetime.now()
        )

    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return HealthCheckResponse(
            status="unhealthy",
            version=settings.APP_VERSION,
            database_connected=False,
            openai_configured=False,
            timestamp=datetime.now()
        )


@router.get("/ping")
async def ping():
    """Simple ping endpoint"""
    return {"message": "pong", "timestamp": datetime.now()}

