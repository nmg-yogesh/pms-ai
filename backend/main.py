"""
FastAPI Main Application - Agentic AI for PMS System
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging
import time

from backend.config import settings
from backend.routers import agentic, health, conversation, rag
from backend.models.database import test_connection
from backend.utils.schema_loader import DB_SCHEMA
from backend.services.vector_db_service import vector_db_service

# Configure logging
logging.basicConfig(
    level=logging.INFO if settings.DEBUG else logging.WARNING,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    # Startup
    logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    logger.info(f"Environment: {settings.ENVIRONMENT}")
    
    # Test database connection
    if test_connection():
        logger.info("✓ Database connection successful")
    else:
        logger.error("✗ Database connection failed")
    
    # Check OpenAI configuration
    if settings.OPENAI_API_KEY:
        logger.info("✓ OpenAI API key configured")
    else:
        logger.warning("✗ OpenAI API key not configured")

    # Check schema loading
    if DB_SCHEMA and len(DB_SCHEMA) > 100:
        table_count = DB_SCHEMA.count("Table:")
        logger.info(f"✓ Database schema loaded ({table_count} tables)")
    else:
        logger.warning("✗ Database schema not loaded properly")

    # Initialize Vector Database for RAG
    if settings.RAG_ENABLED:
        try:
            if vector_db_service.initialize():
                stats = vector_db_service.get_stats()
                logger.info(f"✓ Vector DB initialized (Schema: {stats.get('schema_count', 0)}, "
                           f"Examples: {stats.get('examples_count', 0)}, "
                           f"Docs: {stats.get('docs_count', 0)})")

                # Auto-index if empty
                if vector_db_service.is_empty():
                    logger.info("Vector DB is empty, running initial indexing...")
                    try:
                        from backend.scripts.index_all import index_all
                        result = index_all(force_reindex=False)
                        if result.get("success"):
                            logger.info(f"✓ Initial indexing complete: {result.get('message')}")
                        else:
                            logger.warning(f"Initial indexing had issues: {result.get('message')}")
                    except Exception as idx_error:
                        logger.warning(f"Auto-indexing failed (run manually): {idx_error}")
            else:
                logger.warning("✗ Vector DB initialization failed")
        except Exception as e:
            logger.warning(f"✗ Vector DB error: {e}")
    else:
        logger.info("ℹ RAG disabled (RAG_ENABLED=False)")

    yield
    
    # Shutdown
    logger.info("Shutting down application")


# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Agentic AI system for PMS - Natural language queries for database",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Request timing middleware
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    """Add processing time to response headers"""
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response


# Exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global exception handler"""
    logger.error(f"Global exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "detail": str(exc) if settings.DEBUG else "An error occurred"
        }
    )


# Include routers
app.include_router(health.router, prefix=settings.API_V1_PREFIX)
app.include_router(agentic.router, prefix=settings.API_V1_PREFIX)
app.include_router(conversation.router, prefix=settings.API_V1_PREFIX)
app.include_router(rag.router, prefix=settings.API_V1_PREFIX)


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": f"Welcome to {settings.APP_NAME}",
        "version": settings.APP_VERSION,
        "docs": "/docs",
        "health": f"{settings.API_V1_PREFIX}/health"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG
    )

