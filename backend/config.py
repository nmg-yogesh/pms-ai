"""
Configuration settings for the Agentic AI FastAPI application
All sensitive credentials are loaded from environment variables (.env file)
"""
from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import List
from pathlib import Path

# Get the directory where this config file is located
BASE_DIR = Path(__file__).resolve().parent
ENV_FILE = BASE_DIR / ".env"


class Settings(BaseSettings):
    """Application settings - all values loaded from environment variables"""

    # Application
    APP_NAME: str = "PMS Agentic AI"
    APP_VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    # Database - NO HARDCODED CREDENTIALS
    # Pydantic will automatically load from .env file
    DATABASE_URL: str
    DB_POOL_SIZE: int = 10
    DB_MAX_OVERFLOW: int = 20

    # OpenAI - NO HARDCODED API KEY
    # Pydantic will automatically load from .env file
    OPENAI_API_KEY: str
    OPENAI_MODEL: str = "gpt-4o-mini"
    OPENAI_TEMPERATURE: float = 0.3
    OPENAI_MAX_TOKENS: int = 2000

    # Security - NO HARDCODED SECRET KEY
    # Pydantic will automatically load from .env file
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS - Parse from comma-separated string in .env
    CORS_ORIGINS: str = "http://localhost:3000,http://localhost:3001,http://localhost:5173,http://localhost:8080"

    # API Settings
    API_V1_PREFIX: str = "/api/v1"
    MAX_QUERY_LENGTH: int = 500

    @property
    def cors_origins_list(self) -> List[str]:
        """Convert CORS_ORIGINS string to list"""
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]

    class Config:
        env_file = str(ENV_FILE)
        case_sensitive = True
        env_file_encoding = 'utf-8'


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance"""
    return Settings()


# Create settings instance
settings = get_settings()

