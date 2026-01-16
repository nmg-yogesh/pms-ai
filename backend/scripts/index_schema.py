"""
Script to index database schema into ChromaDB vector database
"""
import os
import re
import logging
from typing import Dict, List, Any

# Setup path for imports
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from backend.services.vector_db_service import vector_db_service, SCHEMA_COLLECTION

logger = logging.getLogger(__name__)

# Table categories based on naming patterns
TABLE_CATEGORIES = {
    "tickets": ["hit_tickets", "hit_ticket_comments", "hit_ticket_attachments"],
    "users": ["users", "user_details", "user_roles", "user_permissions"],
    "departments": ["departments", "designations"],
    "workflows": ["fms_masters", "fms_steps", "fms_entries", "fms_entry_progress", "fms_step_checklists"],
    "projects": ["projects", "tasks", "additional_works"],
    "recurring": ["recurring_master_tasks", "recurring_tasks"],
}

# Priority tables that are most commonly queried
PRIORITY_TABLES = [
    "hit_tickets", "users", "departments", "designations",
    "fms_masters", "fms_steps", "fms_entries", "fms_entry_progress",
    "projects", "tasks", "recurring_master_tasks", "recurring_tasks"
]

# Common relationships between tables
TABLE_RELATIONSHIPS = {
    "hit_tickets": ["users", "departments"],
    "users": ["departments", "designations"],
    "fms_entries": ["fms_masters", "users"],
    "fms_entry_progress": ["fms_entries", "fms_steps"],
    "fms_steps": ["fms_masters"],
    "tasks": ["projects", "users"],
    "projects": ["users", "departments"],
    "recurring_tasks": ["recurring_master_tasks", "users"],
}


def get_table_category(table_name: str) -> str:
    """Get category for a table based on its name"""
    for category, tables in TABLE_CATEGORIES.items():
        if table_name in tables:
            return category

    # Try pattern matching
    if "ticket" in table_name.lower():
        return "tickets"
    elif "user" in table_name.lower():
        return "users"
    elif "fms" in table_name.lower():
        return "workflows"
    elif "project" in table_name.lower() or "task" in table_name.lower():
        return "projects"
    elif "recurring" in table_name.lower():
        return "recurring"

    return "general"


def parse_sql_file(sql_file_path: str) -> Dict[str, List[Dict[str, str]]]:
    """
    Parse SQL file to extract table schemas

    Returns:
        Dictionary mapping table names to their column definitions
    """
    schema_dict = {}

    try:
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()

        # Pattern to match CREATE TABLE statements
        table_pattern = r'CREATE TABLE `?(\w+)`?\s*\((.*?)\)\s*ENGINE'

        matches = re.finditer(table_pattern, sql_content, re.DOTALL | re.IGNORECASE)

        for match in matches:
            table_name = match.group(1)
            columns_section = match.group(2)

            columns = parse_columns(columns_section)
            if columns:
                schema_dict[table_name] = columns

        logger.info(f"Parsed {len(schema_dict)} tables from SQL file")
        return schema_dict

    except Exception as e:
        logger.error(f"Error parsing SQL file: {e}")
        return {}


def parse_columns(columns_section: str) -> List[Dict[str, str]]:
    """Parse column definitions from CREATE TABLE statement"""
    columns = []

    lines = columns_section.split('\n')

    for line in lines:
        line = line.strip()

        # Skip non-column lines
        if not line or line.startswith('PRIMARY KEY') or line.startswith('KEY') or \
           line.startswith('UNIQUE') or line.startswith('CONSTRAINT') or line.startswith('FOREIGN'):
            continue

        # Extract column name and type
        col_match = re.match(r'`?(\w+)`?\s+(\w+(?:\([^)]+\))?)', line)

        if col_match:
            col_name = col_match.group(1)
            col_type = col_match.group(2)

            # Extract comment if present
            comment_match = re.search(r"COMMENT\s+'([^']+)'", line)
            comment = comment_match.group(1) if comment_match else ""

            columns.append({
                'name': col_name,
                'type': col_type,
                'comment': comment
            })

    return columns


def create_schema_text(table_name: str, columns: List[Dict[str, str]]) -> str:
    """
    Create a semantic description of a table for embedding

    This creates a rich text description that captures the table's purpose
    """
    lines = [f"Table: {table_name}"]

    # Add semantic description based on table name
    if "ticket" in table_name.lower():
        lines.append("Purpose: Stores help desk tickets and support requests")
    elif "user" in table_name.lower():
        lines.append("Purpose: Stores user account information and profiles")
    elif "department" in table_name.lower():
        lines.append("Purpose: Stores organizational department information")
    elif "fms" in table_name.lower():
        lines.append("Purpose: Stores workflow management system data (FMS)")
    elif "project" in table_name.lower():
        lines.append("Purpose: Stores project management information")
    elif "task" in table_name.lower():
        lines.append("Purpose: Stores task assignments and tracking")
    elif "recurring" in table_name.lower():
        lines.append("Purpose: Stores recurring task schedules and assignments")

    lines.append("\nColumns:")

    for col in columns:
        comment_str = f" -- {col['comment']}" if col['comment'] else ""
        lines.append(f"  - {col['name']} ({col['type']}){comment_str}")

    # Add relationship info if available
    if table_name in TABLE_RELATIONSHIPS:
        lines.append(f"\nRelated tables: {', '.join(TABLE_RELATIONSHIPS[table_name])}")

    return "\n".join(lines)


def index_schema(sql_file_path: str = None, force_reindex: bool = False) -> Dict[str, Any]:
    """
    Index database schema into ChromaDB

    Args:
        sql_file_path: Path to SQL file (defaults to pms.sql in project root)
        force_reindex: If True, clear existing data before indexing

    Returns:
        Dictionary with indexing results
    """
    result = {
        "success": False,
        "tables_indexed": 0,
        "message": ""
    }

    try:
        # Initialize vector DB if needed
        if not vector_db_service.is_initialized():
            vector_db_service.initialize()

        # Check if already indexed
        stats = vector_db_service.get_stats()
        if stats.get("schema_count", 0) > 0 and not force_reindex:
            result["message"] = f"Schema already indexed ({stats['schema_count']} tables). Use force_reindex=True to re-index."
            result["success"] = True
            result["tables_indexed"] = stats["schema_count"]
            return result

        # Clear existing if force reindex
        if force_reindex:
            vector_db_service.clear_collection(SCHEMA_COLLECTION)
            logger.info("Cleared existing schema collection")

        # Determine SQL file path
        if sql_file_path is None:
            current_dir = os.path.dirname(os.path.abspath(__file__))
            project_root = os.path.dirname(os.path.dirname(current_dir))
            sql_file_path = os.path.join(project_root, "pms.sql")

        if not os.path.exists(sql_file_path):
            result["message"] = f"SQL file not found: {sql_file_path}"
            return result

        # Parse SQL file
        schema_dict = parse_sql_file(sql_file_path)

        if not schema_dict:
            result["message"] = "No tables found in SQL file"
            return result

        # Prepare schemas for batch indexing
        schemas_to_index = []

        # Index priority tables first
        for table_name in PRIORITY_TABLES:
            if table_name in schema_dict:
                columns = schema_dict[table_name]
                schema_text = create_schema_text(table_name, columns)

                schemas_to_index.append({
                    "table_name": table_name,
                    "schema_text": schema_text,
                    "columns": [col["name"] for col in columns],
                    "relationships": TABLE_RELATIONSHIPS.get(table_name, []),
                    "category": get_table_category(table_name)
                })

        # Index remaining tables
        for table_name, columns in schema_dict.items():
            if table_name not in PRIORITY_TABLES:
                schema_text = create_schema_text(table_name, columns)

                schemas_to_index.append({
                    "table_name": table_name,
                    "schema_text": schema_text,
                    "columns": [col["name"] for col in columns],
                    "relationships": TABLE_RELATIONSHIPS.get(table_name, []),
                    "category": get_table_category(table_name)
                })

        # Batch index all schemas
        indexed_count = vector_db_service.add_schemas_batch(schemas_to_index)

        result["success"] = True
        result["tables_indexed"] = indexed_count
        result["message"] = f"Successfully indexed {indexed_count} tables"

        logger.info(f"Schema indexing complete: {indexed_count} tables indexed")
        return result

    except Exception as e:
        logger.error(f"Error indexing schema: {e}")
        result["message"] = f"Error: {str(e)}"
        return result


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    result = index_schema(force_reindex=True)
    print(f"Result: {result}")
