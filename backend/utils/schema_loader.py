"""
Utility to load and parse database schema from pms.sql file
"""
import os
import re
import logging
from typing import Dict, List, Optional

logger = logging.getLogger(__name__)

# Cache for schema to avoid re-reading file
_schema_cache: Optional[str] = None


def load_schema_from_sql(sql_file_path: str = "pms.sql") -> str:
    """
    Load and parse database schema from SQL file
    
    Args:
        sql_file_path: Path to the SQL file (relative to project root)
        
    Returns:
        Formatted schema string for AI prompts
    """
    global _schema_cache
    
    # Return cached schema if available
    if _schema_cache is not None:
        return _schema_cache
    
    try:
        # Get the project root directory
        current_dir = os.path.dirname(os.path.abspath(__file__))
        project_root = os.path.dirname(os.path.dirname(current_dir))
        full_path = os.path.join(project_root, sql_file_path)
        
        logger.info(f"Loading schema from: {full_path}")
        
        if not os.path.exists(full_path):
            logger.warning(f"Schema file not found: {full_path}")
            return get_fallback_schema()
        
        with open(full_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Parse the SQL file to extract table structures
        schema_dict = parse_sql_schema(sql_content)
        
        # Format schema for AI prompt
        formatted_schema = format_schema_for_prompt(schema_dict)
        
        # Cache the schema
        _schema_cache = formatted_schema
        
        logger.info(f"Successfully loaded schema with {len(schema_dict)} tables")
        return formatted_schema
        
    except Exception as e:
        logger.error(f"Error loading schema: {e}")
        return get_fallback_schema()


def parse_sql_schema(sql_content: str) -> Dict[str, List[Dict[str, str]]]:
    """
    Parse SQL CREATE TABLE statements to extract schema information
    
    Args:
        sql_content: Raw SQL file content
        
    Returns:
        Dictionary mapping table names to their column definitions
    """
    schema_dict = {}
    
    # Pattern to match CREATE TABLE statements
    table_pattern = r'CREATE TABLE `?(\w+)`?\s*\((.*?)\)\s*ENGINE'
    
    # Find all CREATE TABLE statements
    matches = re.finditer(table_pattern, sql_content, re.DOTALL | re.IGNORECASE)
    
    for match in matches:
        table_name = match.group(1)
        columns_section = match.group(2)
        
        # Parse columns
        columns = parse_columns(columns_section)
        
        if columns:
            schema_dict[table_name] = columns
    
    return schema_dict


def parse_columns(columns_section: str) -> List[Dict[str, str]]:
    """
    Parse column definitions from CREATE TABLE statement
    
    Args:
        columns_section: The columns section of CREATE TABLE
        
    Returns:
        List of column definitions
    """
    columns = []
    
    # Split by lines and process each column definition
    lines = columns_section.split('\n')
    
    for line in lines:
        line = line.strip()
        
        # Skip empty lines, PRIMARY KEY, KEY, CONSTRAINT, etc.
        if not line or line.startswith('PRIMARY KEY') or line.startswith('KEY') or \
           line.startswith('UNIQUE') or line.startswith('CONSTRAINT') or line.startswith('FOREIGN'):
            continue
        
        # Extract column name and type
        # Pattern: `column_name` type [constraints] [COMMENT 'comment']
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


def format_schema_for_prompt(schema_dict: Dict[str, List[Dict[str, str]]]) -> str:
    """
    Format parsed schema into a readable string for AI prompts

    Args:
        schema_dict: Parsed schema dictionary

    Returns:
        Formatted schema string
    """
    formatted_lines = []

    # Add relationship information at the top
    formatted_lines.append("=== COMMON TABLE RELATIONSHIPS ===")
    formatted_lines.append("users.id → hit_tickets.user_id (one-to-many)")
    formatted_lines.append("users.department_id → departments.id (many-to-one)")
    formatted_lines.append("users.designation_id → designations.id (many-to-one)")
    formatted_lines.append("fms_entries.fms_id → fms_masters.id (many-to-one)")
    formatted_lines.append("fms_entry_progress.fms_entry_id → fms_entries.id (many-to-one)")
    formatted_lines.append("fms_entry_progress.fms_step_id → fms_steps.id (many-to-one)")
    formatted_lines.append("projects.created_by → users.id (many-to-one)")
    formatted_lines.append("tasks.project_id → projects.id (many-to-one)")
    formatted_lines.append("tasks.assigned_to → users.id (many-to-one)")
    formatted_lines.append("")
    formatted_lines.append("=== DATABASE TABLES ===")
    formatted_lines.append("")

    # Priority tables to show first
    priority_tables = [
        'hit_tickets', 'users', 'departments', 'designations',
        'fms_masters', 'fms_steps', 'fms_entries', 'fms_entry_progress',
        'projects', 'tasks', 'additional_works'
    ]

    # Add priority tables first
    for table_name in priority_tables:
        if table_name in schema_dict:
            formatted_lines.append(format_table(table_name, schema_dict[table_name]))

    # Add remaining tables (limit to avoid token overflow)
    remaining_count = 0
    for table_name, columns in schema_dict.items():
        if table_name not in priority_tables and remaining_count < 20:
            formatted_lines.append(format_table(table_name, columns))
            remaining_count += 1

    return "\n\n".join(formatted_lines)


def format_table(table_name: str, columns: List[Dict[str, str]]) -> str:
    """Format a single table's schema"""
    lines = [f"Table: {table_name}"]
    
    for col in columns:
        comment_str = f" -- {col['comment']}" if col['comment'] else ""
        lines.append(f"  - {col['name']} ({col['type']}){comment_str}")
    
    return "\n".join(lines)


def get_fallback_schema() -> str:
    """Return a basic fallback schema if file loading fails"""
    return """
Table: hit_tickets
  - id (int) -- Primary key
  - hitticket_id (varchar) -- Unique ticket identifier
  - user_id (int) -- User who created the ticket
  - status (varchar) -- Ticket status
  - taskPriority (varchar) -- Priority level

Table: users
  - id (bigint) -- Primary key
  - user_name (varchar) -- Username
  - email (varchar) -- Email address
  - first_name (varchar) -- First name
  - last_name (varchar) -- Last name
  - department_id (bigint) -- Department ID

Table: departments
  - id (bigint) -- Primary key
  - name (text) -- Department name
  - status (tinyint) -- Active status
"""


# Load schema on module import
DB_SCHEMA = load_schema_from_sql()

