"""
Database connection and session management
"""
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import QueuePool
from typing import Generator
import logging

from backend.config import settings

logger = logging.getLogger(__name__)

# Create database engine
engine = create_engine(
    settings.DATABASE_URL,
    poolclass=QueuePool,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_pre_ping=True,  # Verify connections before using
    echo=settings.DEBUG,  # Log SQL queries in debug mode
)

# Create session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()


def get_db() -> Generator:
    """
    Dependency function to get database session
    
    Usage:
        @app.get("/items")
        def read_items(db: Session = Depends(get_db)):
            ...
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def test_connection() -> bool:
    """Test database connection"""
    try:
        with engine.connect() as conn:
            result = conn.execute(text("SELECT 1"))
            logger.info("Database connection successful")
            return True
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return False


def execute_raw_query(query: str, params: dict = None):
    """
    Execute raw SQL query
    
    Args:
        query: SQL query string
        params: Query parameters (optional)
        
    Returns:
        Query results as list of dictionaries
    """
    try:
        with engine.connect() as conn:
            if params:
                result = conn.execute(text(query), params)
            else:
                result = conn.execute(text(query))
            
            # Convert to list of dictionaries
            columns = result.keys()
            rows = result.fetchall()
            
            return [dict(zip(columns, row)) for row in rows]
            
    except Exception as e:
        logger.error(f"Query execution failed: {e}")
        raise


def get_table_schema(table_name: str) -> list:
    """Get schema information for a table"""
    query = f"DESCRIBE {table_name}"
    try:
        return execute_raw_query(query)
    except Exception as e:
        logger.error(f"Failed to get schema for {table_name}: {e}")
        return []


def get_all_tables() -> list:
    """Get list of all tables in database"""
    query = "SHOW TABLES"
    try:
        result = execute_raw_query(query)
        # Extract table names from result
        return [list(row.values())[0] for row in result]
    except Exception as e:
        logger.error(f"Failed to get tables: {e}")
        return []

