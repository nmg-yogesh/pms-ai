"""
API Routes for Agentic AI functionality
"""
from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any
import logging

from backend.models.schemas import (
    AgenticQueryRequest,
    AgenticQueryResponse,
    ErrorResponse
)
from backend.services.agentic_service import agentic_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/agentic", tags=["Agentic AI"])


@router.post("/query", response_model=AgenticQueryResponse)
async def process_agentic_query(request: AgenticQueryRequest):
    """
    Process a natural language query using AI
    
    **Example Request:**
    ```json
    {
        "query": "How many help tickets are pending by all users, give names",
        "user_id": 1,
        "include_explanation": true,
        "speak_response": false
    }
    ```
    
    **Example Response:**
    ```json
    {
        "success": true,
        "query": "How many help tickets are pending by all users, give names",
        "sql_query": "SELECT u.id, CONCAT(u.first_name, ' ', u.last_name) AS user_name...",
        "results": [...],
        "explanation": "There are 5 users with pending help tickets...",
        "result_count": 5,
        "execution_time_ms": 45.2,
        "error": null
    }
    ```
    """
    try:
        logger.info(f"Received query request: {request.query}")
        response = await agentic_service.process_query(request)
        return response
        
    except Exception as e:
        logger.error(f"Error in query endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/examples", response_model=Dict[str, Any])
async def get_example_queries():
    """
    Get example queries for different categories
    
    **Response:**
    ```json
    {
        "hit_tickets": ["How many help tickets are pending?", ...],
        "fms_workflows": ["Show me all active workflows", ...],
        "users": ["List all users in IT department", ...],
        "general": ["Show me department-wise user count", ...]
    }
    ```
    """
    try:
        examples = await agentic_service.get_example_queries()
        return examples
        
    except Exception as e:
        logger.error(f"Error getting examples: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/validate-query")
async def validate_sql_query(sql_query: str):
    """
    Validate if a SQL query is safe to execute
    
    **Parameters:**
    - sql_query: SQL query string to validate
    
    **Response:**
    ```json
    {
        "is_safe": true,
        "reason": "Query is safe to execute"
    }
    ```
    """
    try:
        from backend.services.openai_service import openai_service
        
        is_safe, reason = await openai_service.validate_query(sql_query)
        
        return {
            "is_safe": is_safe,
            "reason": reason,
            "query": sql_query
        }
        
    except Exception as e:
        logger.error(f"Error validating query: {e}")
        raise HTTPException(status_code=500, detail=str(e))

