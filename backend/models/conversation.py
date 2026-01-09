"""
Conversation and Chat Session Models
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


class MessageType(str, Enum):
    """Message type enumeration"""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"
    ERROR = "error"


class ChatSessionCreate(BaseModel):
    """Schema for creating a new chat session"""
    session_id: str = Field(..., description="Unique session identifier")
    user_id: Optional[int] = Field(None, description="User ID who owns this session")
    title: str = Field(..., max_length=255, description="Session title")


class ChatSessionResponse(BaseModel):
    """Schema for chat session response"""
    id: str = Field(..., description="Session ID")
    user_id: Optional[int] = Field(None, description="User ID")
    title: str = Field(..., description="Session title")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    message_count: int = Field(0, description="Number of messages in session")
    is_active: bool = Field(True, description="Whether session is active")


class ConversationMessageCreate(BaseModel):
    """Schema for creating a conversation message"""
    session_id: str = Field(..., description="Session ID")
    message_type: MessageType = Field(..., description="Type of message")
    content: str = Field(..., description="Message content")
    query: Optional[str] = Field(None, description="Original user query")
    sql_query: Optional[str] = Field(None, description="Generated SQL query")
    result_count: Optional[int] = Field(None, description="Number of results")
    execution_time_ms: Optional[float] = Field(None, description="Execution time")
    chart_config: Optional[Dict[str, Any]] = Field(None, description="Chart configuration")
    metadata: Optional[Dict[str, Any]] = Field(None, description="Additional metadata")


class ConversationMessageResponse(BaseModel):
    """Schema for conversation message response"""
    id: int = Field(..., description="Message ID")
    session_id: str = Field(..., description="Session ID")
    message_type: MessageType = Field(..., description="Message type")
    content: str = Field(..., description="Message content")
    query: Optional[str] = Field(None, description="Original query")
    sql_query: Optional[str] = Field(None, description="SQL query")
    result_count: Optional[int] = Field(None, description="Result count")
    execution_time_ms: Optional[float] = Field(None, description="Execution time")
    chart_config: Optional[Dict[str, Any]] = Field(None, description="Chart config")
    metadata: Optional[Dict[str, Any]] = Field(None, description="Metadata")
    created_at: datetime = Field(..., description="Creation timestamp")


class ConversationHistoryResponse(BaseModel):
    """Schema for conversation history response"""
    session: ChatSessionResponse
    messages: List[ConversationMessageResponse]


class ConversationContextCreate(BaseModel):
    """Schema for creating conversation context"""
    session_id: str = Field(..., description="Session ID")
    context_key: str = Field(..., max_length=100, description="Context key")
    context_value: str = Field(..., description="Context value")


class ConversationContextResponse(BaseModel):
    """Schema for conversation context response"""
    id: int = Field(..., description="Context ID")
    session_id: str = Field(..., description="Session ID")
    context_key: str = Field(..., description="Context key")
    context_value: str = Field(..., description="Context value")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Update timestamp")


class SessionListResponse(BaseModel):
    """Schema for listing chat sessions"""
    sessions: List[ChatSessionResponse]
    total_count: int = Field(..., description="Total number of sessions")

