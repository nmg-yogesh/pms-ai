"""
Script to index query examples into ChromaDB vector database
"""
import os
import logging
from typing import Dict, List, Any

# Setup path for imports
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from backend.services.vector_db_service import vector_db_service, EXAMPLES_COLLECTION

logger = logging.getLogger(__name__)

# Query examples with natural language and SQL pairs
# These serve as few-shot examples for the LLM
QUERY_EXAMPLES = [
    # Hit Tickets examples
    {
        "category": "tickets",
        "natural_language": "How many help tickets are pending by all users",
        "sql_query": """SELECT
            CONCAT(u.first_name, ' ', u.last_name) AS user_name,
            COUNT(CASE WHEN h.done_status IS NULL AND h.is_inprogress = 0 THEN 1 END) AS pending_tickets
        FROM users u
        LEFT JOIN hit_tickets h ON u.id = h.helping_person_id
        GROUP BY u.id, u.first_name, u.last_name
        ORDER BY pending_tickets DESC
        LIMIT 100"""
    },
    {
        "category": "tickets",
        "natural_language": "Show me high priority tickets",
        "sql_query": """SELECT
            h.hitticket_id,
            h.subject,
            CONCAT(u.first_name, ' ', u.last_name) AS assigned_to,
            h.taskPriority,
            h.created_at
        FROM hit_tickets h
        LEFT JOIN users u ON h.helping_person_id = u.id
        WHERE h.taskPriority = 'high'
        ORDER BY h.created_at DESC
        LIMIT 100"""
    },
    {
        "category": "tickets",
        "natural_language": "Which tickets are overdue",
        "sql_query": """SELECT
            h.hitticket_id,
            h.subject,
            CONCAT(u.first_name, ' ', u.last_name) AS assigned_to,
            h.due_date,
            DATEDIFF(CURDATE(), h.due_date) AS days_overdue
        FROM hit_tickets h
        LEFT JOIN users u ON h.helping_person_id = u.id
        WHERE h.due_date < CURDATE() AND h.done_status IS NULL
        ORDER BY h.due_date ASC
        LIMIT 100"""
    },
    {
        "category": "tickets",
        "natural_language": "List all completed tickets from last week",
        "sql_query": """SELECT
            h.hitticket_id,
            h.subject,
            CONCAT(u.first_name, ' ', u.last_name) AS completed_by,
            h.updated_at AS completed_date
        FROM hit_tickets h
        LEFT JOIN users u ON h.helping_person_id = u.id
        WHERE h.done_status = 1
        AND h.updated_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
        ORDER BY h.updated_at DESC
        LIMIT 100"""
    },
    {
        "category": "tickets",
        "natural_language": "Who has the most pending help tickets",
        "sql_query": """SELECT
            CONCAT(u.first_name, ' ', u.last_name) AS user_name,
            COUNT(*) AS pending_count
        FROM hit_tickets h
        JOIN users u ON h.helping_person_id = u.id
        WHERE h.done_status IS NULL AND h.is_inprogress = 0
        GROUP BY u.id, u.first_name, u.last_name
        ORDER BY pending_count DESC
        LIMIT 10"""
    },
    {
        "category": "tickets",
        "natural_language": "Ticket status breakdown for a user",
        "sql_query": """SELECT
            CONCAT(u.first_name, ' ', u.last_name) AS user_name,
            SUM(CASE WHEN h.is_inprogress = 1 THEN 1 ELSE 0 END) AS in_progress,
            SUM(CASE WHEN h.done_status = 1 THEN 1 ELSE 0 END) AS completed,
            SUM(CASE WHEN h.hold_status = 1 THEN 1 ELSE 0 END) AS on_hold,
            SUM(CASE WHEN h.done_status IS NULL AND h.is_inprogress = 0 AND h.hold_status IS NULL THEN 1 ELSE 0 END) AS pending
        FROM users u
        LEFT JOIN hit_tickets h ON u.id = h.helping_person_id
        WHERE u.first_name LIKE '%name%'
        GROUP BY u.id, u.first_name, u.last_name"""
    },

    # FMS Workflow examples
    {
        "category": "workflows",
        "natural_language": "Show me all active FMS workflows",
        "sql_query": """SELECT
            fm.id,
            fm.name AS workflow_name,
            fm.created_at,
            CONCAT(u.first_name, ' ', u.last_name) AS created_by
        FROM fms_masters fm
        LEFT JOIN users u ON fm.created_by = u.id
        WHERE fm.deleted_at IS NULL
        ORDER BY fm.created_at DESC
        LIMIT 100"""
    },
    {
        "category": "workflows",
        "natural_language": "How many FMS entries are in progress",
        "sql_query": """SELECT
            COUNT(*) AS entries_in_progress
        FROM fms_entries fe
        WHERE fe.status = 'in_progress' AND fe.deleted_at IS NULL"""
    },
    {
        "category": "workflows",
        "natural_language": "Show FMS workflow steps for a workflow",
        "sql_query": """SELECT
            fs.id,
            fs.name AS step_name,
            fs.step_order,
            fs.description
        FROM fms_steps fs
        WHERE fs.fms_master_id = 5
        ORDER BY fs.step_order ASC"""
    },
    {
        "category": "workflows",
        "natural_language": "FMS entries created this month",
        "sql_query": """SELECT
            fe.id,
            fm.name AS workflow_name,
            fe.created_at,
            CONCAT(u.first_name, ' ', u.last_name) AS created_by
        FROM fms_entries fe
        JOIN fms_masters fm ON fe.fms_id = fm.id
        LEFT JOIN users u ON fe.created_by = u.id
        WHERE MONTH(fe.created_at) = MONTH(CURDATE())
        AND YEAR(fe.created_at) = YEAR(CURDATE())
        ORDER BY fe.created_at DESC
        LIMIT 100"""
    },
    {
        "category": "workflows",
        "natural_language": "Top FMS owners by count",
        "sql_query": """SELECT
            CONCAT(u.first_name, ' ', u.last_name) AS owner_name,
            COUNT(*) AS workflow_count
        FROM fms_masters fm
        JOIN users u ON fm.created_by = u.id
        WHERE fm.deleted_at IS NULL
        GROUP BY u.id, u.first_name, u.last_name
        ORDER BY workflow_count DESC
        LIMIT 10"""
    },

    # Recurring Tasks examples
    {
        "category": "recurring",
        "natural_language": "Show all active recurring tasks",
        "sql_query": """SELECT
            rmt.id,
            rmt.title,
            rmt.frequency,
            CONCAT(u.first_name, ' ', u.last_name) AS assigned_to,
            rmt.created_at
        FROM recurring_master_tasks rmt
        LEFT JOIN users u ON rmt.assigned_to = u.id
        WHERE rmt.status = 1 AND rmt.deleted_at IS NULL
        ORDER BY rmt.created_at DESC
        LIMIT 100"""
    },
    {
        "category": "recurring",
        "natural_language": "Recurring tasks assigned to a specific user",
        "sql_query": """SELECT
            rmt.id,
            rmt.title,
            rmt.frequency,
            rmt.priority,
            rmt.due_date
        FROM recurring_master_tasks rmt
        JOIN users u ON rmt.assigned_to = u.id
        WHERE CONCAT(u.first_name, ' ', u.last_name) LIKE '%name%'
        AND rmt.deleted_at IS NULL
        ORDER BY rmt.due_date ASC
        LIMIT 100"""
    },
    {
        "category": "recurring",
        "natural_language": "High priority recurring tasks due this week",
        "sql_query": """SELECT
            rmt.id,
            rmt.title,
            CONCAT(u.first_name, ' ', u.last_name) AS assigned_to,
            rmt.due_date
        FROM recurring_master_tasks rmt
        LEFT JOIN users u ON rmt.assigned_to = u.id
        WHERE rmt.priority = 'high'
        AND rmt.due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
        AND rmt.deleted_at IS NULL
        ORDER BY rmt.due_date ASC
        LIMIT 100"""
    },
    {
        "category": "recurring",
        "natural_language": "List all overdue recurring tasks",
        "sql_query": """SELECT
            rmt.id,
            rmt.title,
            CONCAT(u.first_name, ' ', u.last_name) AS assigned_to,
            rmt.due_date,
            DATEDIFF(CURDATE(), rmt.due_date) AS days_overdue
        FROM recurring_master_tasks rmt
        LEFT JOIN users u ON rmt.assigned_to = u.id
        WHERE rmt.due_date < CURDATE()
        AND rmt.status = 1
        AND rmt.deleted_at IS NULL
        ORDER BY rmt.due_date ASC
        LIMIT 100"""
    },

    # Users examples
    {
        "category": "users",
        "natural_language": "List all users in IT department",
        "sql_query": """SELECT
            u.id,
            CONCAT(u.first_name, ' ', u.last_name) AS user_name,
            u.email,
            d.name AS department
        FROM users u
        JOIN departments d ON u.department_id = d.id
        WHERE d.name LIKE '%IT%'
        ORDER BY u.first_name ASC
        LIMIT 100"""
    },
    {
        "category": "users",
        "natural_language": "Who is the team lead of Sales",
        "sql_query": """SELECT
            CONCAT(u.first_name, ' ', u.last_name) AS user_name,
            u.email,
            des.name AS designation,
            d.name AS department
        FROM users u
        JOIN departments d ON u.department_id = d.id
        LEFT JOIN designations des ON u.designation_id = des.id
        WHERE d.name LIKE '%Sales%'
        AND (des.name LIKE '%lead%' OR des.name LIKE '%manager%')
        LIMIT 10"""
    },
    {
        "category": "users",
        "natural_language": "Show me inactive users",
        "sql_query": """SELECT
            u.id,
            CONCAT(u.first_name, ' ', u.last_name) AS user_name,
            u.email,
            u.updated_at AS last_active
        FROM users u
        WHERE u.status = 0
        ORDER BY u.updated_at DESC
        LIMIT 100"""
    },
    {
        "category": "users",
        "natural_language": "How many users are in each department",
        "sql_query": """SELECT
            d.name AS department,
            COUNT(u.id) AS user_count
        FROM departments d
        LEFT JOIN users u ON d.id = u.department_id
        WHERE d.status = 1
        GROUP BY d.id, d.name
        ORDER BY user_count DESC"""
    },

    # General examples
    {
        "category": "general",
        "natural_language": "Show me department-wise user count",
        "sql_query": """SELECT
            d.name AS department,
            COUNT(u.id) AS user_count
        FROM departments d
        LEFT JOIN users u ON d.id = u.department_id
        GROUP BY d.id, d.name
        ORDER BY user_count DESC"""
    },
    {
        "category": "general",
        "natural_language": "What are the most common ticket priorities",
        "sql_query": """SELECT
            taskPriority AS priority,
            COUNT(*) AS ticket_count
        FROM hit_tickets
        GROUP BY taskPriority
        ORDER BY ticket_count DESC"""
    },
    {
        "category": "general",
        "natural_language": "List all active departments",
        "sql_query": """SELECT
            id,
            name AS department_name,
            created_at
        FROM departments
        WHERE status = 1
        ORDER BY name ASC"""
    },
]


def index_examples(force_reindex: bool = False) -> Dict[str, Any]:
    """
    Index query examples into ChromaDB

    Args:
        force_reindex: If True, clear existing data before indexing

    Returns:
        Dictionary with indexing results
    """
    result = {
        "success": False,
        "examples_indexed": 0,
        "message": ""
    }

    try:
        # Initialize vector DB if needed
        if not vector_db_service.is_initialized():
            vector_db_service.initialize()

        # Check if already indexed
        stats = vector_db_service.get_stats()
        if stats.get("examples_count", 0) > 0 and not force_reindex:
            result["message"] = f"Examples already indexed ({stats['examples_count']} examples). Use force_reindex=True to re-index."
            result["success"] = True
            result["examples_indexed"] = stats["examples_count"]
            return result

        # Clear existing if force reindex
        if force_reindex:
            vector_db_service.clear_collection(EXAMPLES_COLLECTION)
            logger.info("Cleared existing examples collection")

        # Prepare examples for batch indexing
        examples_to_index = []

        for i, example in enumerate(QUERY_EXAMPLES):
            examples_to_index.append({
                "example_id": f"example_{i}_{example['category']}",
                "natural_language": example["natural_language"],
                "sql_query": example["sql_query"],
                "category": example["category"]
            })

        # Batch index all examples
        indexed_count = vector_db_service.add_examples_batch(examples_to_index)

        result["success"] = True
        result["examples_indexed"] = indexed_count
        result["message"] = f"Successfully indexed {indexed_count} examples"

        logger.info(f"Examples indexing complete: {indexed_count} examples indexed")
        return result

    except Exception as e:
        logger.error(f"Error indexing examples: {e}")
        result["message"] = f"Error: {str(e)}"
        return result


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    result = index_examples(force_reindex=True)
    print(f"Result: {result}")
