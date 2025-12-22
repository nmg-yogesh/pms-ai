"""
OpenAI Service for AI-powered query generation and explanation
"""
import logging
from typing import Optional, Tuple
from openai import OpenAI
from backend.config import settings
from backend.utils.prompts import SYSTEM_PROMPT, EXPLANATION_PROMPT, VALIDATION_PROMPT

logger = logging.getLogger(__name__)

# Initialize OpenAI client
client = OpenAI(api_key=settings.OPENAI_API_KEY)


class OpenAIService:
    """Service for interacting with OpenAI API"""
    
    def __init__(self):
        self.model = settings.OPENAI_MODEL
        self.temperature = settings.OPENAI_TEMPERATURE
        self.max_tokens = settings.OPENAI_MAX_TOKENS
    
    async def generate_sql_query(self, user_query: str) -> str:
        """
        Generate SQL query from natural language
        
        Args:
            user_query: Natural language query from user
            
        Returns:
            Generated SQL query string
        """
        try:
            logger.info(f"Generating SQL for query: {user_query}")
            
            response = client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": user_query}
                ],
                temperature=self.temperature,
                max_tokens=self.max_tokens
            )
            
            sql_query = response.choices[0].message.content.strip()
            
            # Remove markdown code blocks if present
            if sql_query.startswith("```sql"):
                sql_query = sql_query.replace("```sql", "").replace("```", "").strip()
            elif sql_query.startswith("```"):
                sql_query = sql_query.replace("```", "").strip()
            
            logger.info(f"Generated SQL: {sql_query}")
            return sql_query
            
        except Exception as e:
            logger.error(f"Error generating SQL query: {e}")
            raise Exception(f"Failed to generate SQL query: {str(e)}")
    
    async def validate_query(self, sql_query: str) -> Tuple[bool, str]:
        """
        Validate if SQL query is safe to execute
        
        Args:
            sql_query: SQL query to validate
            
        Returns:
            Tuple of (is_safe, reason)
        """
        try:
            # Basic validation checks
            dangerous_keywords = ['DELETE', 'DROP', 'TRUNCATE', 'UPDATE', 'ALTER', 'INSERT', 'CREATE']
            query_upper = sql_query.upper()
            
            for keyword in dangerous_keywords:
                if keyword in query_upper:
                    return False, f"Query contains dangerous keyword: {keyword}"
            
            # Additional AI-based validation
            prompt = VALIDATION_PROMPT.format(query=sql_query)
            
            response = client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.1,
                max_tokens=100
            )
            
            validation_result = response.choices[0].message.content.strip()
            
            is_safe = validation_result.startswith("SAFE")
            reason = validation_result.replace("SAFE", "").replace("UNSAFE", "").strip()
            
            return is_safe, reason
            
        except Exception as e:
            logger.error(f"Error validating query: {e}")
            return False, f"Validation error: {str(e)}"
    
    async def explain_results(self, user_query: str, results: list) -> str:
        """
        Generate human-friendly explanation of query results
        
        Args:
            user_query: Original user query
            results: Query results
            
        Returns:
            Explanation string
        """
        try:
            logger.info(f"Generating explanation for {len(results)} results")
            
            # Limit results for explanation to avoid token limits
            limited_results = results[:10] if len(results) > 10 else results
            
            prompt = EXPLANATION_PROMPT.format(
                query=user_query,
                results=limited_results
            )
            
            response = client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.7,
                max_tokens=300
            )
            
            explanation = response.choices[0].message.content.strip()
            
            # Add result count if there are more results
            if len(results) > 10:
                explanation += f"\n\n(Showing 10 of {len(results)} total results)"
            
            return explanation
            
        except Exception as e:
            logger.error(f"Error generating explanation: {e}")
            return "Results retrieved successfully, but explanation generation failed."


# Create singleton instance
openai_service = OpenAIService()

