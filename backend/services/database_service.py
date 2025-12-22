"""
Database Service for executing queries
"""
import logging
import time
from typing import List, Dict, Any, Tuple
from sqlalchemy import text
from backend.models.database import engine

logger = logging.getLogger(__name__)


class DatabaseService:
    """Service for database operations"""
    
    async def execute_query(self, sql_query: str) -> Tuple[List[Dict[str, Any]], float]:
        """
        Execute SQL query and return results
        
        Args:
            sql_query: SQL query to execute
            
        Returns:
            Tuple of (results, execution_time_ms)
        """
        start_time = time.time()
        
        try:
            logger.info(f"Executing query: {sql_query}")
            
            with engine.connect() as conn:
                result = conn.execute(text(sql_query))
                
                # Convert to list of dictionaries
                columns = result.keys()
                rows = result.fetchall()
                
                results = [dict(zip(columns, row)) for row in rows]
                
                execution_time_ms = (time.time() - start_time) * 1000
                
                logger.info(f"Query executed successfully. Rows: {len(results)}, Time: {execution_time_ms:.2f}ms")
                
                return results, execution_time_ms
                
        except Exception as e:
            execution_time_ms = (time.time() - start_time) * 1000
            logger.error(f"Query execution failed: {e}")
            raise Exception(f"Database query failed: {str(e)}")
    
    async def get_table_info(self, table_name: str) -> List[Dict[str, Any]]:
        """Get schema information for a table"""
        query = f"DESCRIBE {table_name}"
        try:
            results, _ = await self.execute_query(query)
            return results
        except Exception as e:
            logger.error(f"Failed to get table info for {table_name}: {e}")
            return []
    
    async def test_connection(self) -> bool:
        """Test database connection"""
        try:
            query = "SELECT 1 as test"
            results, _ = await self.execute_query(query)
            return len(results) > 0
        except Exception as e:
            logger.error(f"Database connection test failed: {e}")
            return False


# Create singleton instance
database_service = DatabaseService()

