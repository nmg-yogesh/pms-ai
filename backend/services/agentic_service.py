"""
Main Agentic AI Service - Orchestrates the entire query flow
"""
import logging
from typing import Dict, Any
from backend.services.openai_service import openai_service
from backend.services.database_service import database_service
from backend.models.schemas import AgenticQueryRequest, AgenticQueryResponse

logger = logging.getLogger(__name__)


class AgenticService:
    """Main service for handling agentic AI queries"""
    
    async def process_query(self, request: AgenticQueryRequest) -> AgenticQueryResponse:
        """
        Process a natural language query end-to-end
        
        Args:
            request: AgenticQueryRequest with user query
            
        Returns:
            AgenticQueryResponse with results and explanation
        """
        try:
            logger.info(f"Processing query: {request.query}")
            
            # Step 1: Generate SQL query from natural language
            sql_query = await openai_service.generate_sql_query(request.query)
            
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
            
            # Step 4: Generate explanation if requested
            explanation = None
            if request.include_explanation:
                explanation = await openai_service.explain_results(request.query, results)
            
            # Step 5: Return response
            return AgenticQueryResponse(
                success=True,
                query=request.query,
                sql_query=sql_query,
                results=results,
                explanation=explanation,
                result_count=len(results),
                execution_time_ms=execution_time_ms,
                error=None
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
                "Show me all active workflows",
                "What's the current step in the hiring process?",
                "How many purchase orders are pending?",
                "List all workflows created this month",
                "Which workflows have the highest efficiency?"
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

