"""
Conversation Service - Manages chat sessions and conversation history
"""
import logging
from typing import List, Optional, Dict, Any, Tuple
from datetime import datetime
from sqlalchemy import text
from backend.models.database import engine
from backend.models.conversation import (
    ChatSessionCreate,
    ChatSessionResponse,
    ConversationMessageCreate,
    ConversationMessageResponse,
    ConversationHistoryResponse,
    ConversationContextCreate,
    ConversationContextResponse,
    SessionListResponse,
    MessageType,
    ConversationErrorCreate,
    ConversationErrorResponse
)
import json

logger = logging.getLogger(__name__)


class ConversationService:
    """Service for managing conversation history and chat sessions"""
    
    async def create_session(self, session_data: ChatSessionCreate) -> ChatSessionResponse:
        """Create a new chat session"""
        try:
            with engine.connect() as conn:
                query = text("""
                    INSERT INTO chat_sessions (id, user_id, title, message_count, is_active)
                    VALUES (:id, :user_id, :title, 0, 1)
                    ON DUPLICATE KEY UPDATE 
                        title = :title,
                        updated_at = CURRENT_TIMESTAMP
                """)
                
                conn.execute(query, {
                    "id": session_data.session_id,
                    "user_id": session_data.user_id,
                    "title": session_data.title
                })
                conn.commit()
                
                return await self.get_session(session_data.session_id)
                
        except Exception as e:
            logger.error(f"Error creating session: {e}")
            raise
    
    async def get_session(self, session_id: str) -> Optional[ChatSessionResponse]:
        """Get a chat session by ID"""
        try:
            with engine.connect() as conn:
                query = text("""
                    SELECT id, user_id, title, created_at, updated_at, message_count, is_active
                    FROM chat_sessions
                    WHERE id = :session_id
                """)
                
                result = conn.execute(query, {"session_id": session_id})
                row = result.fetchone()
                
                if row:
                    return ChatSessionResponse(
                        id=row[0],
                        user_id=row[1],
                        title=row[2],
                        created_at=row[3],
                        updated_at=row[4],
                        message_count=row[5],
                        is_active=bool(row[6])
                    )
                return None
                
        except Exception as e:
            logger.error(f"Error getting session: {e}")
            raise
    
    async def list_sessions(self, user_id: Optional[int] = None, limit: int = 50) -> SessionListResponse:
        """List chat sessions for a user"""
        try:
            with engine.connect() as conn:
                if user_id:
                    query = text("""
                        SELECT id, user_id, title, created_at, updated_at, message_count, is_active
                        FROM chat_sessions
                        WHERE user_id = :user_id AND is_active = 1
                        ORDER BY updated_at DESC
                        LIMIT :limit
                    """)
                    result = conn.execute(query, {"user_id": user_id, "limit": limit})
                else:
                    query = text("""
                        SELECT id, user_id, title, created_at, updated_at, message_count, is_active
                        FROM chat_sessions
                        WHERE is_active = 1
                        ORDER BY updated_at DESC
                        LIMIT :limit
                    """)
                    result = conn.execute(query, {"limit": limit})
                
                rows = result.fetchall()
                sessions = [
                    ChatSessionResponse(
                        id=row[0],
                        user_id=row[1],
                        title=row[2],
                        created_at=row[3],
                        updated_at=row[4],
                        message_count=row[5],
                        is_active=bool(row[6])
                    )
                    for row in rows
                ]
                
                return SessionListResponse(sessions=sessions, total_count=len(sessions))

        except Exception as e:
            logger.error(f"Error listing sessions: {e}")
            raise
        
        
    async def store_error(self, message_data: ConversationErrorCreate) -> ConversationErrorResponse:
        """Store an error message in the conversation"""
        try:
            with engine.connect() as conn:
                query = text("""
                    INSERT INTO conversation_errors
                    (session_id, error_message)
                    VALUES (:session_id, :error_message)
                """)
                result = conn.execute(query, {
                    "session_id": message_data.session_id,
                    "error_message": message_data.error_message
                })
                conn.commit()
                return ConversationErrorResponse(error=message_data.error_message, id=result.lastrowid)
        except Exception as e:
            logger.error(f"Error storing error: {e}")
            raise
       

    async def add_message(self, message_data: ConversationMessageCreate) -> ConversationMessageResponse:
        """Add a message to a conversation"""
        try:
            with engine.connect() as conn:
                # Convert chart_config and metadata to JSON strings
                chart_config_json = json.dumps(message_data.chart_config) if message_data.chart_config else None
                metadata_json = json.dumps(message_data.metadata) if message_data.metadata else None

                query = text("""
                    INSERT INTO conversation_messages
                    (session_id, message_type, content, query, sql_query, result_count,
                     execution_time_ms, chart_config, metadata)
                    VALUES (:session_id, :message_type, :content, :query, :sql_query,
                            :result_count, :execution_time_ms, :chart_config, :metadata)
                """)

                result = conn.execute(query, {
                    "session_id": message_data.session_id,
                    "message_type": message_data.message_type.value,
                    "content": message_data.content,
                    "query": message_data.query,
                    "sql_query": message_data.sql_query,
                    "result_count": message_data.result_count,
                    "execution_time_ms": message_data.execution_time_ms,
                    "chart_config": chart_config_json,
                    "metadata": metadata_json
                })

                message_id = result.lastrowid

                # Update session message count
                update_query = text("""
                    UPDATE chat_sessions
                    SET message_count = message_count + 1,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = :session_id
                """)
                conn.execute(update_query, {"session_id": message_data.session_id})

                conn.commit()

                # Fetch and return the created message
                return await self.get_message(message_id)

        except Exception as e:
            logger.error(f"Error adding message: {e}")
            raise

    async def get_message(self, message_id: int) -> Optional[ConversationMessageResponse]:
        """Get a message by ID"""
        try:
            with engine.connect() as conn:
                query = text("""
                    SELECT id, session_id, message_type, content, query, sql_query,
                           result_count, execution_time_ms, chart_config, metadata, created_at
                    FROM conversation_messages
                    WHERE id = :message_id
                """)

                result = conn.execute(query, {"message_id": message_id})
                row = result.fetchone()

                if row:
                    return ConversationMessageResponse(
                        id=row[0],
                        session_id=row[1],
                        message_type=MessageType(row[2]),
                        content=row[3],
                        query=row[4],
                        sql_query=row[5],
                        result_count=row[6],
                        execution_time_ms=row[7],
                        chart_config=json.loads(row[8]) if row[8] else None,
                        metadata=json.loads(row[9]) if row[9] else None,
                        created_at=row[10]
                    )
                return None

        except Exception as e:
            logger.error(f"Error getting message: {e}")
            raise

    async def get_conversation_history(self, session_id: str, limit: int = 100) -> ConversationHistoryResponse:
        """Get full conversation history for a session"""
        try:
            session = await self.get_session(session_id)
            if not session:
                raise ValueError(f"Session {session_id} not found")

            with engine.connect() as conn:
                query = text("""
                    SELECT id, session_id, message_type, content, query, sql_query,
                           result_count, execution_time_ms, chart_config, metadata, created_at
                    FROM conversation_messages
                    WHERE session_id = :session_id
                    ORDER BY created_at ASC
                    LIMIT :limit
                """)

                result = conn.execute(query, {"session_id": session_id, "limit": limit})
                rows = result.fetchall()

                messages = [
                    ConversationMessageResponse(
                        id=row[0],
                        session_id=row[1],
                        message_type=MessageType(row[2]),
                        content=row[3],
                        query=row[4],
                        sql_query=row[5],
                        result_count=row[6],
                        execution_time_ms=row[7],
                        chart_config=json.loads(row[8]) if row[8] else None,
                        metadata=json.loads(row[9]) if row[9] else None,
                        created_at=row[10]
                    )
                    for row in rows
                ]

                return ConversationHistoryResponse(session=session, messages=messages)

        except Exception as e:
            logger.error(f"Error getting conversation history: {e}")
            raise

    async def save_context(self, context_data: ConversationContextCreate) -> ConversationContextResponse:
        """Save or update conversation context"""
        try:
            with engine.connect() as conn:
                query = text("""
                    INSERT INTO conversation_context (session_id, context_key, context_value)
                    VALUES (:session_id, :context_key, :context_value)
                    ON DUPLICATE KEY UPDATE
                        context_value = :context_value,
                        updated_at = CURRENT_TIMESTAMP
                """)

                conn.execute(query, {
                    "session_id": context_data.session_id,
                    "context_key": context_data.context_key,
                    "context_value": context_data.context_value
                })
                conn.commit()

                # Fetch the context
                return await self.get_context(context_data.session_id, context_data.context_key)

        except Exception as e:
            logger.error(f"Error saving context: {e}")
            raise

    async def get_context(self, session_id: str, context_key: str) -> Optional[ConversationContextResponse]:
        """Get a specific context value"""
        try:
            with engine.connect() as conn:
                query = text("""
                    SELECT id, session_id, context_key, context_value, created_at, updated_at
                    FROM conversation_context
                    WHERE session_id = :session_id AND context_key = :context_key
                """)

                result = conn.execute(query, {"session_id": session_id, "context_key": context_key})
                row = result.fetchone()

                if row:
                    return ConversationContextResponse(
                        id=row[0],
                        session_id=row[1],
                        context_key=row[2],
                        context_value=row[3],
                        created_at=row[4],
                        updated_at=row[5]
                    )
                return None

        except Exception as e:
            logger.error(f"Error getting context: {e}")
            raise

    async def get_all_context(self, session_id: str) -> Dict[str, str]:
        """Get all context for a session as a dictionary"""
        try:
            with engine.connect() as conn:
                query = text("""
                    SELECT context_key, context_value
                    FROM conversation_context
                    WHERE session_id = :session_id
                """)

                result = conn.execute(query, {"session_id": session_id})
                rows = result.fetchall()

                return {row[0]: row[1] for row in rows}

        except Exception as e:
            logger.error(f"Error getting all context: {e}")
            raise


# Create singleton instance
conversation_service = ConversationService()

