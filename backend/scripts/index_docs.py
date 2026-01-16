"""
Script to index documentation into ChromaDB vector database
"""
import os
import logging
from typing import Dict, List, Any

# Setup path for imports
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from backend.services.vector_db_service import vector_db_service, DOCS_COLLECTION
from backend.config import settings

logger = logging.getLogger(__name__)

# System documentation chunks - business rules, guidelines, and instructions
SYSTEM_DOCS = [
    {
        "source": "system_rules",
        "role": "general",
        "content": """SQL Query Generation Rules:
1. Only generate SELECT queries - never DELETE, DROP, UPDATE, INSERT, or ALTER
2. Always use proper table aliases for readability
3. Use LEFT JOIN when query says "all users" or "everyone" to include users with 0 counts
4. Use INNER JOIN when query specifically asks for "users who have" or "with"
5. For user names, use CONCAT(first_name, ' ', last_name)
6. Always add LIMIT clause (default 100) to prevent large result sets
7. Handle NULL values appropriately with COALESCE or IS NULL checks"""
    },
    {
        "source": "system_rules",
        "role": "general",
        "content": """Hit Tickets Status Fields:
- is_inprogress: tinyint (1 = in progress, 0 = not in progress)
- done_status: int (1 = completed, NULL = not done)
- not_done_status: tinyint (1 = marked as not done, NULL = not marked)
- hold_status: int (1 = on hold, NULL = not on hold)
- status: varchar (can be 'pending', 'open', etc.)

Important: For ticket assignments:
- user_id: The person who CREATED the ticket
- helping_person_id: The person ASSIGNED to resolve the ticket

For "tickets by user" queries, typically use helping_person_id (assignee)."""
    },
    {
        "source": "system_rules",
        "role": "general",
        "content": """Visualization Guidelines:
For status breakdown queries, use SUM(condition) pattern for chart-friendly output:
- SUM(is_inprogress = 1) AS in_progress
- SUM(done_status = 1) AS completed
- SUM(hold_status = 1) AS on_hold

Chart type selection:
- Single entity + status breakdown → PIE CHART
- Multiple entities + status breakdown → STACKED BAR CHART
- Ranking/count queries → BAR CHART
- Time series data → LINE CHART"""
    },
    {
        "source": "system_rules",
        "role": "general",
        "content": """Name Search Guidelines:
ALWAYS use LIKE with % wildcards for name searches, NOT = operator:
- WHERE first_name LIKE '%ankit%' (correct)
- WHERE first_name = 'ankit' (incorrect - too strict)
- WHERE CONCAT(first_name, ' ', last_name) LIKE '%john doe%' (for full name)

LIKE is case-insensitive and allows partial matches."""
    },
    {
        "source": "relationships",
        "role": "general",
        "content": """Common Table Relationships:
- users.id → hit_tickets.user_id (ticket creator)
- users.id → hit_tickets.helping_person_id (ticket assignee)
- users.department_id → departments.id (user's department)
- users.designation_id → designations.id (user's job title)
- fms_entries.fms_id → fms_masters.id (entry belongs to workflow)
- fms_entry_progress.fms_entry_id → fms_entries.id (progress for entry)
- fms_entry_progress.fms_step_id → fms_steps.id (progress for step)
- fms_steps.fms_master_id → fms_masters.id (step belongs to workflow)
- tasks.project_id → projects.id (task belongs to project)
- tasks.assigned_to → users.id (task assignee)
- recurring_tasks.recurring_master_task_id → recurring_master_tasks.id"""
    },
    {
        "source": "best_practices",
        "role": "general",
        "content": """Date Handling Best Practices:
- Use CURDATE() for current date comparisons
- Use DATE_SUB(CURDATE(), INTERVAL X DAY) for past dates
- Use DATE_ADD(CURDATE(), INTERVAL X DAY) for future dates
- Use MONTH() and YEAR() for monthly comparisons
- Use DATEDIFF() to calculate days between dates
- Use DATE() to extract date from datetime fields"""
    },
    {
        "source": "best_practices",
        "role": "general",
        "content": """Aggregation Best Practices:
- Always GROUP BY all non-aggregated columns
- Use COUNT(*) for row counts, COUNT(column) for non-null counts
- Use COALESCE(column, 0) when counting might return NULL
- Order aggregate results by the aggregate column DESC for rankings
- Use HAVING for filtering aggregated results, WHERE for row filtering"""
    },

    # FMS Admin specific docs
    {
        "source": "fms_admin",
        "role": "fms-admin",
        "content": """FMS (Flow Management System) Administration:
FMS is a workflow management system with the following structure:
1. FMS Masters: Define workflow templates with name and description
2. FMS Steps: Sequential steps within a workflow, ordered by step_order
3. FMS Entries: Instances of workflows being executed
4. FMS Entry Progress: Tracks progress of each entry through steps

Key tables:
- fms_masters: id, name, description, created_by, deleted_at
- fms_steps: id, fms_master_id, name, step_order, description
- fms_entries: id, fms_id, status, created_by, deleted_at
- fms_entry_progress: id, fms_entry_id, fms_step_id, status, completed_at"""
    },

    # HIT Admin specific docs
    {
        "source": "hit_admin",
        "role": "hit-admin",
        "content": """HIT (Help IT) Ticket System Administration:
HIT is a help desk ticketing system for IT support requests.

Key fields in hit_tickets:
- hitticket_id: Unique ticket identifier
- subject: Ticket title/subject
- description: Detailed description
- user_id: Creator of the ticket
- helping_person_id: Person assigned to resolve
- taskPriority: Priority level (high, medium, low)
- due_date: Expected resolution date
- is_inprogress, done_status, hold_status: Status flags

Common queries:
- Pending tickets: WHERE done_status IS NULL AND is_inprogress = 0
- In progress: WHERE is_inprogress = 1
- Completed: WHERE done_status = 1
- On hold: WHERE hold_status = 1"""
    },

    # Recurring Tasks specific docs
    {
        "source": "recurring_tasks",
        "role": "general",
        "content": """Recurring Tasks System:
Recurring tasks are scheduled tasks that repeat on a defined frequency.

Key tables:
- recurring_master_tasks: Template for recurring tasks
  - id, title, description, frequency (daily/weekly/monthly)
  - assigned_to, priority, due_date, status
- recurring_tasks: Individual instances of recurring tasks
  - id, recurring_master_task_id, due_date, status

Frequency types: daily, weekly, monthly, yearly
Priority levels: high, medium, low
Status: 1 = active, 0 = inactive"""
    },
]


def try_parse_transcript(transcript_path: str) -> List[Dict[str, Any]]:
    """
    Try to parse transcript PDF for additional documentation

    Args:
        transcript_path: Path to transcript PDF

    Returns:
        List of document chunks from transcript
    """
    docs = []

    try:
        if not os.path.exists(transcript_path):
            logger.info(f"Transcript not found at {transcript_path}, skipping")
            return docs

        from pypdf import PdfReader

        reader = PdfReader(transcript_path)
        full_text = ""

        for page in reader.pages:
            full_text += page.extract_text() + "\n"

        # Split into chunks of ~1000 characters
        chunk_size = 1000
        overlap = 100

        for i in range(0, len(full_text), chunk_size - overlap):
            chunk = full_text[i:i + chunk_size].strip()
            if len(chunk) > 100:  # Skip very short chunks
                docs.append({
                    "source": "transcript",
                    "role": "general",
                    "content": chunk
                })

        logger.info(f"Parsed {len(docs)} chunks from transcript")

    except ImportError:
        logger.warning("pypdf not installed, skipping transcript parsing")
    except Exception as e:
        logger.error(f"Error parsing transcript: {e}")

    return docs


def index_docs(force_reindex: bool = False) -> Dict[str, Any]:
    """
    Index documentation into ChromaDB

    Args:
        force_reindex: If True, clear existing data before indexing

    Returns:
        Dictionary with indexing results
    """
    result = {
        "success": False,
        "docs_indexed": 0,
        "message": ""
    }

    try:
        # Initialize vector DB if needed
        if not vector_db_service.is_initialized():
            vector_db_service.initialize()

        # Check if already indexed
        stats = vector_db_service.get_stats()
        if stats.get("docs_count", 0) > 0 and not force_reindex:
            result["message"] = f"Docs already indexed ({stats['docs_count']} chunks). Use force_reindex=True to re-index."
            result["success"] = True
            result["docs_indexed"] = stats["docs_count"]
            return result

        # Clear existing if force reindex
        if force_reindex:
            vector_db_service.clear_collection(DOCS_COLLECTION)
            logger.info("Cleared existing docs collection")

        # Collect all docs
        all_docs = []

        # Add system docs
        for i, doc in enumerate(SYSTEM_DOCS):
            all_docs.append({
                "chunk_id": f"sys_doc_{i}_{doc['source']}",
                "content": doc["content"],
                "source": doc["source"],
                "role": doc["role"]
            })

        # Try to add transcript docs
        transcript_docs = try_parse_transcript(settings.TRANSCRIPT_PATH)
        for i, doc in enumerate(transcript_docs):
            all_docs.append({
                "chunk_id": f"transcript_{i}",
                "content": doc["content"],
                "source": doc["source"],
                "role": doc["role"]
            })

        # Batch index all docs
        indexed_count = vector_db_service.add_docs_batch(all_docs)

        result["success"] = True
        result["docs_indexed"] = indexed_count
        result["message"] = f"Successfully indexed {indexed_count} documentation chunks"

        logger.info(f"Docs indexing complete: {indexed_count} chunks indexed")
        return result

    except Exception as e:
        logger.error(f"Error indexing docs: {e}")
        result["message"] = f"Error: {str(e)}"
        return result


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    result = index_docs(force_reindex=True)
    print(f"Result: {result}")
