"""
OpenAI Service for AI-powered query generation and explanation
"""
import logging
import re
from typing import Optional, Tuple, List
from openai import OpenAI
from backend.config import settings
from backend.utils.prompts import get_system_prompt, EXPLANATION_PROMPT, VALIDATION_PROMPT
from backend.utils.schema_loader import load_schema_from_sql, parse_sql_schema

logger = logging.getLogger(__name__)

# Initialize OpenAI client
client = OpenAI(api_key=settings.OPENAI_API_KEY)

# Cache parsed schema for validation
_parsed_schema_cache = None


class OpenAIService:
    """Service for interacting with OpenAI API"""

    def __init__(self):
        self.model = settings.OPENAI_MODEL
        self.temperature = settings.OPENAI_TEMPERATURE
        self.max_tokens = settings.OPENAI_MAX_TOKENS
        self._load_schema_cache()

    def _load_schema_cache(self):
        """Load and cache parsed schema for validation"""
        global _parsed_schema_cache
        if _parsed_schema_cache is None:
            try:
                sql_content = load_schema_from_sql()
                # Extract table names from formatted schema
                _parsed_schema_cache = self._extract_schema_info(sql_content)
                logger.info(f"Cached schema with {len(_parsed_schema_cache)} tables")
            except Exception as e:
                logger.error(f"Failed to cache schema: {e}")
                _parsed_schema_cache = {}

    def _extract_schema_info(self, schema_text: str) -> dict:
        """Extract table and column names from schema text"""
        schema_info = {}
        current_table = None

        for line in schema_text.split('\n'):
            line = line.strip()
            if line.startswith('Table:'):
                current_table = line.replace('Table:', '').strip()
                schema_info[current_table] = []
            elif line.startswith('-') and current_table:
                # Extract column name (format: "- column_name (type)")
                col_match = re.match(r'-\s+(\w+)\s+\(', line)
                if col_match:
                    schema_info[current_table].append(col_match.group(1))

        return schema_info

    def _validate_sql_against_schema(self, sql_query: str) -> Tuple[bool, str]:
        """
        Validate SQL query against known schema

        Args:
            sql_query: SQL query to validate

        Returns:
            Tuple of (is_valid, error_message)
        """
        if not _parsed_schema_cache:
            return True, "Schema cache not available"

        try:
            # Extract table names from SQL
            table_pattern = r'FROM\s+`?(\w+)`?|JOIN\s+`?(\w+)`?'
            tables_in_query = re.findall(table_pattern, sql_query, re.IGNORECASE)
            tables_in_query = [t[0] or t[1] for t in tables_in_query]

            # Check if tables exist in schema
            invalid_tables = []
            for table in tables_in_query:
                if table and table not in _parsed_schema_cache:
                    invalid_tables.append(table)

            if invalid_tables:
                available_tables = list(_parsed_schema_cache.keys())[:10]
                return False, f"Invalid table(s): {', '.join(invalid_tables)}. Available tables include: {', '.join(available_tables)}"

            # Extract column references (basic check)
            # This is a simple check - could be enhanced
            for table in tables_in_query:
                if table in _parsed_schema_cache:
                    # Look for table.column patterns
                    col_pattern = rf'{table}\.(\w+)'
                    columns_in_query = re.findall(col_pattern, sql_query, re.IGNORECASE)

                    invalid_columns = []
                    for col in columns_in_query:
                        if col not in _parsed_schema_cache[table]:
                            invalid_columns.append(f"{table}.{col}")

                    if invalid_columns:
                        available_cols = _parsed_schema_cache[table][:10]
                        return False, f"Invalid column(s): {', '.join(invalid_columns)}. Available columns in {table}: {', '.join(available_cols)}"

            return True, "Schema validation passed"

        except Exception as e:
            logger.warning(f"Schema validation error: {e}")
            return True, f"Validation skipped: {str(e)}"

    async def generate_sql_query(self, user_query: str, retry_count: int = 0) -> str:
        """
        Generate SQL query from natural language with schema validation

        Args:
            user_query: Natural language query from user
            retry_count: Number of retry attempts (internal use)

        Returns:
            Generated SQL query string
        """
        try:
            logger.info(f"Generating SQL for query: {user_query} (attempt {retry_count + 1})")

            # Get the system prompt with current database schema
            system_prompt = get_system_prompt()

            # Add schema validation reminder for retries
            if retry_count > 0:
                user_query_enhanced = f"{user_query}\n\nIMPORTANT: Previous attempt failed schema validation. Please carefully verify all table and column names exist in the DATABASE SCHEMA above before generating the query."
            else:
                user_query_enhanced = user_query

            response = client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_query_enhanced}
                ],
                temperature=self.temperature if retry_count == 0 else 0.1,  # Lower temperature on retry
                max_tokens=self.max_tokens
            )

            sql_query = response.choices[0].message.content.strip()

            # Remove markdown code blocks if present
            if sql_query.startswith("```sql"):
                sql_query = sql_query.replace("```sql", "").replace("```", "").strip()
            elif sql_query.startswith("```"):
                sql_query = sql_query.replace("```", "").strip()

            logger.info(f"Generated SQL: {sql_query}")

            # Validate against schema
            is_valid, validation_msg = self._validate_sql_against_schema(sql_query)

            if not is_valid:
                logger.warning(f"Schema validation failed: {validation_msg}")

                # Retry once with enhanced prompt
                if retry_count < 1:
                    logger.info("Retrying SQL generation with schema validation feedback")
                    return await self.generate_sql_query(user_query, retry_count + 1)
                else:
                    # Return the query anyway but log the issue
                    logger.error(f"SQL generation failed schema validation after retry: {validation_msg}")
                    # Don't raise exception, let the database validation catch it
            else:
                logger.info(f"Schema validation passed: {validation_msg}")

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
            # Basic validation checks - use word boundaries to avoid false positives
            # This prevents flagging 'created_at', 'created_by', 'CONCAT', etc.
            query_upper = sql_query.upper()

            # Check for dangerous SQL statements (as complete words, not substrings)
            dangerous_patterns = [
                r'\bDELETE\s+FROM\b',      # DELETE FROM
                r'\bDROP\s+TABLE\b',       # DROP TABLE
                r'\bDROP\s+DATABASE\b',    # DROP DATABASE
                r'\bTRUNCATE\s+TABLE\b',   # TRUNCATE TABLE
                r'\bUPDATE\s+\w+\s+SET\b', # UPDATE ... SET
                r'\bALTER\s+TABLE\b',      # ALTER TABLE
                r'\bINSERT\s+INTO\b',      # INSERT INTO
                r'\bCREATE\s+TABLE\b',     # CREATE TABLE
                r'\bCREATE\s+DATABASE\b',  # CREATE DATABASE
                r'\bCREATE\s+INDEX\b',     # CREATE INDEX
            ]

            for pattern in dangerous_patterns:
                if re.search(pattern, query_upper):
                    keyword = pattern.replace(r'\b', '').replace(r'\s+', ' ').replace(r'\w+', '...')
                    return False, f"Query contains dangerous operation: {keyword}"

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
    
    async def explain_results(self, user_query: str, results: list, sql_query: str = None) -> str:
        """
        Generate human-friendly explanation of query results with analysis

        Args:
            user_query: Original user query
            results: Query results
            sql_query: The SQL query that was executed (optional)

        Returns:
            Explanation string with insights and analysis
        """
        try:
            logger.info(f"Generating explanation for {len(results)} results")

            # Limit results for explanation to avoid token limits
            limited_results = results[:10] if len(results) > 10 else results

            # Enhanced prompt with analysis request
            enhanced_prompt = f"""You are a helpful AI assistant analyzing database query results.

User asked: "{user_query}"

Query results: {limited_results}
Total results count: {len(results)}

Please provide:
1. A clear, concise summary of what the data shows (2-3 sentences)
2. Key insights or patterns in the data
3. Any notable findings or anomalies
4. Actionable recommendations if applicable

Make it easy to understand for non-technical users. Use a friendly, conversational tone.
If there are no results, explain that clearly and suggest why that might be."""

            response = client.chat.completions.create(
                model=self.model,
                messages=[{"role": "user", "content": enhanced_prompt}],
                temperature=0.7,
                max_tokens=500
            )

            explanation = response.choices[0].message.content.strip()

            # Add result count if there are more results
            if len(results) > 10:
                explanation += f"\n\n📊 Note: Showing analysis of first 10 results out of {len(results)} total records."

            return explanation
            
        except Exception as e:
            logger.error(f"Error generating explanation: {e}")
            return "Results retrieved successfully, but explanation generation failed."


# Create singleton instance
openai_service = OpenAIService()

