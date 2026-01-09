"""
API Routes for Conversation History Management
"""
from fastapi import APIRouter, HTTPException, Query
from typing import Optional
import logging

from backend.models.conversation import (
    ChatSessionCreate,
    ChatSessionResponse,
    ConversationMessageCreate,
    ConversationMessageResponse,
    ConversationHistoryResponse,
    ConversationContextCreate,
    ConversationContextResponse,
    SessionListResponse
)
from backend.services.conversation_service import conversation_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/conversation", tags=["Conversation History"])


@router.post("/sessions", response_model=ChatSessionResponse)
async def create_session(session_data: ChatSessionCreate):
    """
    Create a new chat session
    
    **Example Request:**
    ```json
    {
        "session_id": "session-1234567890",
        "user_id": 1,
        "title": "Help ticket queries"
    }
    ```
    """
    try:
        return await conversation_service.create_session(session_data)
    except Exception as e:
        logger.error(f"Error creating session: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/sessions/{session_id}", response_model=ChatSessionResponse)
async def get_session(session_id: str):
    """Get a chat session by ID"""
    try:
        session = await conversation_service.get_session(session_id)
        if not session:
            raise HTTPException(status_code=404, detail="Session not found")
        return session
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting session: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/sessions", response_model=SessionListResponse)
async def list_sessions(
    user_id: Optional[int] = Query(None, description="Filter by user ID"),
    limit: int = Query(50, ge=1, le=100, description="Maximum number of sessions to return")
):
    """
    List chat sessions
    
    **Query Parameters:**
    - user_id: Optional user ID to filter sessions
    - limit: Maximum number of sessions (1-100, default 50)
    """
    try:
        return await conversation_service.list_sessions(user_id=user_id, limit=limit)
    except Exception as e:
        logger.error(f"Error listing sessions: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/messages", response_model=ConversationMessageResponse)
async def add_message(message_data: ConversationMessageCreate):
    """
    Add a message to a conversation
    
    **Example Request:**
    ```json
    {
        "session_id": "session-1234567890",
        "message_type": "user",
        "content": "Show me all pending tickets",
        "query": "Show me all pending tickets"
    }
    ```
    """
    try:
        return await conversation_service.add_message(message_data)
    except Exception as e:
        logger.error(f"Error adding message: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/history/{session_id}", response_model=ConversationHistoryResponse)
async def get_conversation_history(
    session_id: str,
    limit: int = Query(100, ge=1, le=500, description="Maximum number of messages")
):
    """
    Get full conversation history for a session
    
    **Path Parameters:**
    - session_id: The session ID
    
    **Query Parameters:**
    - limit: Maximum number of messages (1-500, default 100)
    """
    try:
        return await conversation_service.get_conversation_history(session_id, limit=limit)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Error getting conversation history: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/context", response_model=ConversationContextResponse)
async def save_context(context_data: ConversationContextCreate):
    """
    Save or update conversation context
    
    **Example Request:**
    ```json
    {
        "session_id": "session-1234567890",
        "context_key": "last_user_mentioned",
        "context_value": "Rajesh Bhati"
    }
    ```
    """
    try:
        return await conversation_service.save_context(context_data)
    except Exception as e:
        logger.error(f"Error saving context: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/context/{session_id}/{context_key}", response_model=ConversationContextResponse)
async def get_context(session_id: str, context_key: str):
    """Get a specific context value for a session"""
    try:
        context = await conversation_service.get_context(session_id, context_key)
        if not context:
            raise HTTPException(status_code=404, detail="Context not found")
        return context
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting context: {e}")
        raise HTTPException(status_code=500, detail=str(e))

