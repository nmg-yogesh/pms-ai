"""
Pydantic schemas for request/response validation
"""
from pydantic import BaseModel, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class QueryType(str, Enum):
    """Types of queries supported"""
    HIT_TICKET = "hit_ticket"
    FMS_WORKFLOW = "fms_workflow"
    USER = "user"
    DEPARTMENT = "department"
    GENERAL = "general"


class AgenticQueryRequest(BaseModel):
    """Request schema for agentic query"""
    query: str = Field(..., min_length=1, max_length=500, description="Natural language query")
    user_id: Optional[int] = Field(None, description="User ID making the query")
    include_explanation: bool = Field(True, description="Include AI explanation of results")
    speak_response: bool = Field(False, description="Generate TTS response")
    
    @validator('query')
    def validate_query(cls, v):
        """Validate query is not empty or just whitespace"""
        if not v or not v.strip():
            raise ValueError("Query cannot be empty")
        return v.strip()


class SQLQueryResponse(BaseModel):
    """Response schema for SQL query"""
    sql_query: str = Field(..., description="Generated SQL query")
    is_safe: bool = Field(..., description="Whether query is safe to execute")
    query_type: Optional[QueryType] = Field(None, description="Type of query detected")


class AgenticQueryResponse(BaseModel):
    """Response schema for agentic query"""
    success: bool = Field(..., description="Whether query was successful")
    query: str = Field(..., description="Original user query")
    sql_query: Optional[str] = Field(None, description="Generated SQL query")
    results: List[Dict[str, Any]] = Field(default_factory=list, description="Query results")
    explanation: Optional[str] = Field(None, description="AI-generated explanation")
    result_count: int = Field(0, description="Number of results returned")
    execution_time_ms: float = Field(0, description="Query execution time in milliseconds")
    error: Optional[str] = Field(None, description="Error message if query failed")
    
    class Config:
        json_schema_extra = {
            "example": {
                "success": True,
                "query": "How many pending help tickets are there?",
                "sql_query": "SELECT COUNT(*) as count FROM hit_tickets WHERE status = 'pending'",
                "results": [{"count": 15}],
                "explanation": "There are currently 15 pending help tickets in the system.",
                "result_count": 1,
                "execution_time_ms": 45.2,
                "error": None
            }
        }


class QueryHistoryItem(BaseModel):
    """Schema for query history"""
    id: int
    user_id: Optional[int]
    query: str
    sql_query: Optional[str]
    success: bool
    result_count: int
    execution_time_ms: float
    created_at: datetime


class HealthCheckResponse(BaseModel):
    """Health check response"""
    status: str
    version: str
    database_connected: bool
    openai_configured: bool
    timestamp: datetime


class ErrorResponse(BaseModel):
    """Error response schema"""
    error: str
    detail: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.now)

