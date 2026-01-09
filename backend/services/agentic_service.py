"""
Main Agentic AI Service - Orchestrates the entire query flow
"""
import logging
from typing import Dict, Any, Optional
from backend.services.openai_service import openai_service
from backend.services.database_service import database_service
from backend.services.visualization_service import visualization_service
from backend.services.conversation_service import conversation_service
from backend.models.schemas import AgenticQueryRequest, AgenticQueryResponse
from backend.utils.prompt_validator import is_meaningful_prompt

from backend.models.conversation import (
    ChatSessionCreate,
    ConversationMessageCreate,
    MessageType
)

logger = logging.getLogger(__name__)


class AgenticService:
    """Main service for handling agentic AI queries"""

    async def process_query(self, request: AgenticQueryRequest, session_id: Optional[str] = None) -> AgenticQueryResponse:
        """
        Process a natural language query end-to-end
        
        Args:
            request: AgenticQueryRequest with user query
            
        Returns:
            AgenticQueryResponse with results and explanation
        """
        try:
            logger.info(f"Processing query: {request.query}")

            # ✅ STEP 0: Validate user input (BLOCK GARBAGE HERE)
            is_valid, reason = is_meaningful_prompt(request.query)

            if not is_valid:
                logger.warning(f"Invalid prompt blocked: {reason}")

                return AgenticQueryResponse(
                success=False,
                query=request.query,
                sql_query=None,
                results=[],
                explanation=None,
                result_count=0,
                execution_time_ms=0,
                error=f"Invalid input: {reason}"
                )
            
            # Step 1: Generate SQL query from natural language (role-aware when provided)
            sql_query = await openai_service.generate_sql_query(request.query, role=request.role)
            
            # Step 2: Validate the generated query
            is_safe, validation_reason = await openai_service.validate_query(sql_query)
            
            if not is_safe:
                logger.warning(f"Unsafe query detected: {validation_reason}")
                return AgenticQueryResponse(
                    success=False,
                    query=request.query,
                    sql_query=sql_query,
                    results=[],
                    explanation=None,
                    result_count=0,
                    execution_time_ms=0,
                    error=f"Query validation failed: {validation_reason}"
                )
            
            # Step 3: Execute the query
            results, execution_time_ms = await database_service.execute_query(sql_query)

            # Step 4: Analyze results for visualization 
            chart_config = None
            if results and len(results) > 0:
                logger.info(f"Analyzing visualization for {len(results)} results")
                chart_config = visualization_service.analyze_and_suggest_chart(
                    request.query,
                    results,
                    sql_query
                )

            # Step 5: Analyze results and generate explanation if requested
            explanation = None
            if request.include_explanation:
                explanation = await openai_service.explain_results(
                    request.query,
                    results,
                    sql_query
                )

            # Step 6: Save to conversation history if session_id provided
            if session_id:
                try:
                    # Save user message
                    await conversation_service.add_message(ConversationMessageCreate(
                        session_id=session_id,
                        message_type=MessageType.USER,
                        content=request.query,
                        query=request.query
                    ))

                    # Save assistant response
                    await conversation_service.add_message(ConversationMessageCreate(
                        session_id=session_id,
                        message_type=MessageType.ASSISTANT,
                        content=explanation or f"Found {len(results)} results",
                        query=request.query,
                        sql_query=sql_query,
                        result_count=len(results),
                        execution_time_ms=execution_time_ms,
                        chart_config=chart_config.model_dump() if chart_config else None
                    ))
                except Exception as conv_error:
                    logger.warning(f"Failed to save conversation history: {conv_error}")

            # Step 7: Return response
            return AgenticQueryResponse(
                success=True,
                query=request.query,
                sql_query=sql_query,
                results=results,
                explanation=explanation,
                result_count=len(results),
                execution_time_ms=execution_time_ms,
                error=None,
                chart_config=chart_config
            )
            
        except Exception as e:
            logger.error(f"Error processing query: {e}")
            return AgenticQueryResponse(
                success=False,
                query=request.query,
                sql_query=None,
                results=[],
                explanation=None,
                result_count=0,
                execution_time_ms=0,
                error=str(e)
            )
    
    async def get_example_queries(self) -> Dict[str, list]:
        """Get example queries for different categories"""
        return {
            "hit_tickets": [
                "How many help tickets are pending by all users, give names",
                "Show me high priority tickets",
                "Which tickets are overdue?",
                "List all completed tickets from last week",
                "Who has the most pending help tickets?"
            ],
            "fms_workflows": [
                "Show me all active FMS workflows",
                "How many FMS entries are in progress?",
                "How many FMS are running?",
                "How many FMS have been deleted?",
                "Show total FMS counts (running vs deleted)",
                "Show FMS workflow steps for workflow ID 5",
                "FMS entries created this month",
                "Which FMS workflows have the highest efficiency?",
                "Show all FMS entry progress for entry ID 10",
                "List all FMS step checklists for step ID 3",
                "Top FMS owners by count"
            ],
            "recurring_tasks": [
                "Show all active recurring tasks",
                "Recurring tasks assigned to Rajesh Bhati",
                "High priority recurring tasks due this week",
                "Recurring task completion status for user ID 44",
                "Show recurring master tasks created this month",
                "List all overdue recurring tasks",
                "Recurring tasks by frequency (daily, weekly, monthly)"
            ],
            "users": [
                "List all users in IT department",
                "Who is the team lead of Sales?",
                "Show me inactive users",
                "How many users are in each department?",
                "List all users with their designations"
            ],
            "general": [
                "Show me department-wise user count",
                "What are the most common ticket priorities?",
                "List all active departments"
            ]
        }


# Create singleton instance
agentic_service = AgenticService()

