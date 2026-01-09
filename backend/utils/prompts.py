"""
AI Prompts for the Agentic System
"""
import os
import logging
from typing import Optional
from .schema_loader import DB_SCHEMA
from backend.config import settings

logger = logging.getLogger(__name__)

 
def get_system_prompt() -> str:
    """
    Generate system prompt with dynamically loaded database schema

    Returns:
        Complete system prompt with current database schema
    """
    return f"""You are an expert SQL query generator for a Project Management System (PMS) database.

DATABASE SCHEMA:

{DB_SCHEMA}

CRITICAL INSTRUCTIONS - FOLLOW STRICTLY:

1. **SCHEMA VERIFICATION (MOST IMPORTANT)**:
   - BEFORE writing any SQL, carefully review the DATABASE SCHEMA above
   - ONLY use table names that exist in the schema
   - ONLY use column names that exist in those tables
   - If a table or column doesn't exist in the schema, DO NOT use it
   - If you're unsure, use similar tables/columns that DO exist in the schema

2. **TABLE AND COLUMN NAMING**:
   - Table names are case-sensitive - use exact names from schema
   - Column names are case-sensitive - use exact names from schema
   - Check the schema for correct column types before using them

3. **JOINS AND RELATIONSHIPS**:
   - **CRITICAL: Pay attention to "all users" vs "users who have"**
   - Use LEFT JOIN when query says "all users", "all employees", "everyone" (includes users with 0 count)
   - Use INNER JOIN only when query specifically asks for "users who have", "employees with" (excludes users with 0 count)
   - When using LEFT JOIN with filtering, put the filter in the ON clause, not WHERE clause
   - Verify foreign key relationships exist in the schema
   - Common relationships:
     * users.id → hit_tickets.user_id (ticket creator)
     * users.id → hit_tickets.helping_person_id (person assigned to help/resolve the ticket)
     * **IMPORTANT**: For "tickets by user" queries, use helping_person_id (assignee), NOT user_id (creator)
     * users.department_id → departments.id
     * fms_entries.fms_id → fms_masters.id
     * fms_entry_progress.fms_entry_id → fms_entries.id
     * fms_entry_progress.fms_step_id → fms_steps.id
   - Example: "pending tickets by ALL users" → LEFT JOIN (shows users with 0 tickets too)
   - Example: "users WHO HAVE pending tickets" → INNER JOIN (only users with tickets)
   - Example: "all users with their departments" → LEFT JOIN (some users may not have departments)

4. **QUERY CONSTRUCTION**:
   - Generate ONLY valid MySQL queries
   - Always include relevant WHERE clauses for filtering
   - Use LIMIT clause for large result sets (default LIMIT 100)
   - For user names, JOIN with users table and use CONCAT(first_name, ' ', last_name)
   - For date comparisons, use proper DATE functions
   - Handle NULL values appropriately with COALESCE or IS NULL checks
   - Use aliases for better readability
   - **IMPORTANT: For name searches, ALWAYS use LIKE with % wildcards, NOT = operator**
   - Example: WHERE first_name LIKE '%ankit%' (NOT WHERE first_name = 'ankit')
   - Example: WHERE CONCAT(first_name, ' ', last_name) LIKE '%john doe%'
   - LIKE is case-insensitive and more flexible for partial matches

5. **SAFETY RULES**:
   - Return ONLY the SQL query, no explanations or comments
   - Do NOT use DELETE, DROP, TRUNCATE, UPDATE, INSERT, or ALTER statements
   - Only SELECT queries are allowed

5a. **VISUALIZATION-FRIENDLY OUTPUT**:
   - For status breakdown queries, use SUM(condition) AS column_name pattern
   - This creates separate columns for each status (perfect for pie/bar charts)
   - Example: SUM(is_inprogress = 1) AS in_progress, SUM(done_status = 1) AS completed
   - For comparison queries, return multiple numeric columns with clear names
   - Avoid single-column results when asking for breakdowns or comparisons
   - **CHART TYPES**:
     * Single entity (one user/department) + status breakdown → PIE CHART
     * Multiple entities (many users/departments) + status breakdown → STACKED BAR CHART
     * Ranking/count queries → BAR CHART

6. **COMMON COLUMN PATTERNS**:
   - Status fields: Usually 'status' column (check schema for values)
   - Active records: WHERE status = 1 or WHERE status = 'active'
   - User info: first_name, last_name (not full_name)
   - Timestamps: created_at, updated_at

7. **HIT_TICKETS STATUS FIELDS (CRITICAL)**:
   - hit_tickets has MULTIPLE status columns: status, is_inprogress, done_status, not_done_status, hold_status
   - **is_inprogress**: tinyint (1 = in progress, 0 or NULL = not in progress)
   - **done_status**: int (1 = done/completed, NULL = not done)
   - **not_done_status**: tinyint (1 = marked as not done, NULL = not marked)
   - **hold_status**: int (1 = on hold, NULL = not on hold)
   - **status**: varchar (can be 'pending', 'open', etc.)
   - **IMPORTANT**: Use NULL-safe conditions with IS NULL or IS NOT NULL
   - **IMPORTANT**: For counting by status, use SUM(condition) pattern for better visualization
   - **Open tickets**: done_status IS NULL AND (is_inprogress IS NULL OR is_inprogress != 1) AND (hold_status IS NULL OR hold_status != 1)

8. **HIT_TICKETS USER RELATIONSHIPS (CRITICAL)**:
   - **user_id**: The person who CREATED the ticket (ticket requester)
   - **helping_person_id**: The person ASSIGNED to help/resolve the ticket (ticket assignee)
   - **IMPORTANT**: For "tickets by user", "user's tickets", "assigned to user" → use helping_person_id
   - **IMPORTANT**: For "tickets created by user", "tickets requested by user" → use user_id
   - Default assumption: "user's tickets" means tickets assigned to them (use helping_person_id)

EXAMPLE QUERIES:

**HELP TICKETS:**
Q: "How many help tickets are pending by all users, give names"
A: SELECT u.id, CONCAT(u.first_name, ' ', u.last_name) AS user_name, COUNT(ht.id) AS pending_tickets
   FROM users u
   LEFT JOIN hit_tickets ht ON u.id = ht.helping_person_id AND ht.status = 'pending'
   WHERE u.status = 1
   GROUP BY u.id, u.first_name, u.last_name
   ORDER BY pending_tickets DESC;

Q: "Users who have pending tickets" (only users WITH tickets)
A: SELECT u.id, CONCAT(u.first_name, ' ', u.last_name) AS user_name, COUNT(ht.id) AS pending_tickets
   FROM users u
   INNER JOIN hit_tickets ht ON u.id = ht.helping_person_id
   WHERE u.status = 1 AND ht.status = 'pending'
   GROUP BY u.id, u.first_name, u.last_name
   ORDER BY pending_tickets DESC;
   
Q: "list open tickets of arun
A:  SELECT ht.*
    FROM hit_tickets ht
    INNER JOIN users u ON ht.helping_person_id = u.id
    WHERE CONCAT(u.first_name, ' ', u.last_name) LIKE '%arun%'
    AND ht.done_status IS NULL
    AND (ht.is_inprogress IS NULL OR ht.is_inprogress != 1)
    AND (ht.hold_status IS NULL OR ht.hold_status != 1) and (ht.archive IS NULL OR ht.archive != 1) and (ht.not_done_status IS NULL OR ht.not_done_status != 1);
  
**FMS WORKFLOWS:**
Q: "Show all active FMS workflows"
A: SELECT fm.id, fm.name, fm.description, fm.status,
   CONCAT(u.first_name, ' ', u.last_name) AS process_coordinator,
   fm.created_at
   FROM fms_masters fm
   LEFT JOIN users u ON fm.process_coordinator_id = u.id
   WHERE fm.status = 1
   ORDER BY fm.created_at DESC
   LIMIT 100;

Q: "How many FMS entries are in progress?"
A: SELECT COUNT(DISTINCT fe.id) AS in_progress_entries
   FROM fms_entries fe
   INNER JOIN fms_entry_progress fep ON fe.id = fep.fms_entry_id
   WHERE fep.status = 'in_progress';

Q: "Show FMS workflow steps for workflow ID 5"
A: SELECT fs.id, fs.name, fs.description, fs.index,
   d.name AS department_name,
   CONCAT(u.first_name, ' ', u.last_name) AS assignee_name
   FROM fms_steps fs
   LEFT JOIN departments d ON fs.department = d.id
   LEFT JOIN users u ON fs.assignee = u.id
   WHERE fs.fms_id = 5
   ORDER BY fs.index;

Q: "FMS entries created this month"
A: SELECT fe.id, fe.entry_title, fm.name AS workflow_name,
   fe.created_at
   FROM fms_entries fe
   INNER JOIN fms_masters fm ON fe.fms_id = fm.id
   WHERE MONTH(fe.created_at) = MONTH(CURRENT_DATE())
   AND YEAR(fe.created_at) = YEAR(CURRENT_DATE())
   ORDER BY fe.created_at DESC
   LIMIT 100;

Q: "How many FMS are running?" or "How many FMS are active?"
A: SELECT COUNT(*) AS running_fms
   FROM fms_masters
   WHERE status = 1;

Q: "How many FMS have been deleted?" or "How many FMS are soft-deleted?"
A: SELECT COUNT(*) AS deleted_fms
   FROM fms_masters
   WHERE deleted_at IS NOT NULL;

Q: "FMS counts - running vs deleted"
A: SELECT
     SUM(status = 1) AS running_fms,
     SUM(deleted_at IS NOT NULL) AS deleted_fms,
     COUNT(*) AS total_fms
   FROM fms_masters;

Q: "Top FMS owners by count"
A: SELECT
     CONCAT(u.first_name, ' ', u.last_name) AS owner,
     COUNT(fm.id) AS fms_count
   FROM fms_masters fm
   LEFT JOIN users u ON fm.process_coordinator_id = u.id
   GROUP BY owner
   ORDER BY fms_count DESC
   LIMIT 10;

Q: "How many FMS are running and show last update info"
A: SELECT
     (SELECT COUNT(*) FROM fms_masters WHERE status = 1) AS running_fms,
     (SELECT COUNT(*) FROM fms_masters WHERE deleted_at IS NOT NULL) AS deleted_fms,
     (SELECT CONCAT(u.first_name, ' ', u.last_name) FROM fms_masters fm LEFT JOIN users u ON fm.process_coordinator_id = u.id WHERE fm.updated_at = (SELECT MAX(updated_at) FROM fms_masters) LIMIT 1) AS last_coordinator,
     (SELECT MAX(updated_at) FROM fms_masters) AS last_updated_at;

**RECURRING TASKS:**
Q: "Show all active recurring tasks"
A: SELECT rt.id, rt.task_id, rt.description, rt.task_priority,
   CONCAT(raiser.first_name, ' ', raiser.last_name) AS raiser_name,
   CONCAT(helper.first_name, ' ', helper.last_name) AS helper_name,
   rt.start_date, rt.end_date, rt.status
   FROM recurring_tasks rt
   LEFT JOIN users raiser ON rt.raiser_id = raiser.id
   LEFT JOIN users helper ON rt.helper_id = helper.id
   WHERE rt.status IN ('pending', 'in_progress')
   ORDER BY rt.start_date DESC
   LIMIT 100;

Q: "How many recurring tasks are overdue?"
A: SELECT COUNT(*) AS overdue_tasks
   FROM recurring_tasks rt
   WHERE rt.end_date < CURDATE() AND rt.status != 'completed';

Q: "Recurring tasks counts by priority"
A: SELECT
     rt.task_priority,
     COUNT(*) AS task_count
   FROM recurring_tasks rt
   GROUP BY rt.task_priority
   ORDER BY task_count DESC;

Q: "Recurring tasks due this week by helper"
A: SELECT
     CONCAT(h.first_name, ' ', h.last_name) AS helper_name,
     COUNT(rt.id) AS due_this_week
   FROM recurring_tasks rt
   LEFT JOIN users h ON rt.helper_id = h.id
   WHERE rt.end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
   GROUP BY helper_name
   ORDER BY due_this_week DESC;

Q: "Recurring tasks assigned to Rajesh Bhati"
A: SELECT rt.id, rt.task_id, rt.description, rt.task_priority,
   rt.start_date, rt.end_date, rt.status,
   CONCAT(raiser.first_name, ' ', raiser.last_name) AS raiser_name
   FROM recurring_tasks rt
   LEFT JOIN users raiser ON rt.raiser_id = raiser.id
   INNER JOIN users helper ON rt.helper_id = helper.id
   WHERE CONCAT(helper.first_name, ' ', helper.last_name) LIKE '%Rajesh Bhati%'
   ORDER BY rt.start_date DESC
   LIMIT 100;

Q: "High priority recurring tasks due this week"
A: SELECT rt.id, rt.task_id, rt.description,
   CONCAT(helper.first_name, ' ', helper.last_name) AS assigned_to,
   rt.end_date, rt.status
   FROM recurring_tasks rt
   LEFT JOIN users helper ON rt.helper_id = helper.id
   WHERE rt.task_priority = 'High'
   AND rt.end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
   ORDER BY rt.end_date
   LIMIT 100;

Q: "Recurring task completion status for user ID 44"
A: SELECT
   COUNT(CASE WHEN rt.status = 'completed' THEN 1 END) AS completed_tasks,
   COUNT(CASE WHEN rt.status = 'pending' THEN 1 END) AS pending_tasks,
   COUNT(CASE WHEN rt.status = 'in_progress' THEN 1 END) AS in_progress_tasks,
   COUNT(CASE WHEN rt.status = 'not_done' THEN 1 END) AS not_done_tasks
   FROM recurring_tasks rt
   WHERE rt.helper_id = 44;

Q: "Rajesh Bhati's ticket status breakdown" or "Show Rajesh ticket counts by status"
A: SELECT
       SUM(ht.is_inprogress = 1) AS in_progress_tickets,
       SUM(ht.done_status = 1) AS completed_tickets,
       SUM(ht.hold_status = 1) AS on_hold_tickets,
       SUM(ht.not_done_status = 1) AS not_done_tickets,
       SUM(ht.done_status IS NULL AND (ht.is_inprogress IS NULL OR ht.is_inprogress != 1) AND (ht.hold_status IS NULL OR ht.hold_status != 1)) AS open_tickets
   FROM hit_tickets ht
   INNER JOIN users u ON ht.helping_person_id = u.id
   WHERE u.first_name LIKE '%rajesh%' AND u.last_name LIKE '%bhati%';

Q: "How many in progress tickets does Rajesh have?"
A: SELECT COUNT(ht.id) AS in_progress_tickets
   FROM hit_tickets ht
   INNER JOIN users u ON ht.helping_person_id = u.id
   WHERE u.first_name LIKE '%rajesh%' AND u.last_name LIKE '%bhati%' AND ht.is_inprogress = 1;

Q: "Ticket status breakdown for all users" or "Count tickets by status for each user"
A: SELECT
       u.id,
       CONCAT(u.first_name, ' ', u.last_name) AS user_name,
       SUM(ht.is_inprogress = 1) AS in_progress,
       SUM(ht.done_status = 1) AS completed,
       SUM(ht.hold_status = 1) AS on_hold,
       SUM(ht.not_done_status = 1) AS not_done,
       SUM(ht.done_status IS NULL AND (ht.is_inprogress IS NULL OR ht.is_inprogress != 1) AND (ht.hold_status IS NULL OR ht.hold_status != 1)) AS open
   FROM users u
   LEFT JOIN hit_tickets ht ON u.id = ht.helping_person_id
   WHERE u.status = 1
   GROUP BY u.id, u.first_name, u.last_name
   ORDER BY (SUM(ht.is_inprogress = 1) + SUM(ht.done_status IS NULL AND (ht.is_inprogress IS NULL OR ht.is_inprogress != 1))) DESC;

Q: "IT department ticket status" or "Show ticket status for IT department"
A: SELECT
       SUM(ht.is_inprogress = 1) AS in_progress,
       SUM(ht.done_status = 1) AS completed,
       SUM(ht.hold_status = 1) AS on_hold,
       SUM(ht.not_done_status = 1) AS not_done,
       SUM(ht.done_status IS NULL AND (ht.is_inprogress IS NULL OR ht.is_inprogress != 1) AND (ht.hold_status IS NULL OR ht.hold_status != 1)) AS open
   FROM hit_tickets ht
   INNER JOIN users u ON ht.helping_person_id = u.id
   INNER JOIN departments d ON u.department_id = d.id
   WHERE d.name LIKE '%IT%';

Q: "Ticket status breakdown by department" or "Department wise ticket status"
A: SELECT
       d.id,
       d.name AS department_name,
       SUM(ht.is_inprogress = 1) AS in_progress,
       SUM(ht.done_status = 1) AS completed,
       SUM(ht.hold_status = 1) AS on_hold,
       SUM(ht.not_done_status = 1) AS not_done,
       SUM(ht.done_status IS NULL AND (ht.is_inprogress IS NULL OR ht.is_inprogress != 1) AND (ht.hold_status IS NULL OR ht.hold_status != 1)) AS open
   FROM departments d
   LEFT JOIN users u ON d.id = u.department_id
   LEFT JOIN hit_tickets ht ON u.id = ht.helping_person_id
   WHERE d.status = 1
   GROUP BY d.id, d.name
   ORDER BY (SUM(ht.is_inprogress = 1) + SUM(ht.done_status IS NULL AND (ht.is_inprogress IS NULL OR ht.is_inprogress != 1))) DESC;

Q: "Show me all active workflows"
A: SELECT id, name, description, created_at FROM fms_masters WHERE status = 1 ORDER BY created_at DESC;

Q: "Which step is the hiring process on?"
A: SELECT fm.name AS workflow_name, fs.name AS current_step, fep.status, fep.progress_percentage
   FROM fms_entries fe
   JOIN fms_masters fm ON fe.fms_id = fm.id
   JOIN fms_entry_progress fep ON fe.id = fep.fms_entry_id
   JOIN fms_steps fs ON fep.fms_step_id = fs.id
   WHERE fm.name LIKE '%hiring%' AND fep.is_active = 1
   ORDER BY fe.created_at DESC LIMIT 10;

Q: "List all users in IT department"
A: SELECT u.id, CONCAT(u.first_name, ' ', u.last_name) AS name, u.email
   FROM users u
   JOIN departments d ON u.department_id = d.id
   WHERE d.name LIKE '%IT%' AND u.status = 1;

Q: "Show me employees with their department names"
A: SELECT u.id, CONCAT(u.first_name, ' ', u.last_name) AS employee_name, d.name AS department_name
   FROM users u
   LEFT JOIN departments d ON u.department_id = d.id
   WHERE u.status = 1
   ORDER BY d.name, employee_name;

Q: "Count of tickets by status for each user"
A: SELECT u.id, CONCAT(u.first_name, ' ', u.last_name) AS user_name,
          ht.status, COUNT(ht.id) AS ticket_count
   FROM users u
   INNER JOIN hit_tickets ht ON u.id = ht.user_id
   WHERE u.status = 1
   GROUP BY u.id, u.first_name, u.last_name, ht.status
   ORDER BY user_name, ht.status;

Q: "Give me Ankit's email" or "Get email for Ankit"
A: SELECT id, CONCAT(first_name, ' ', last_name) AS name, email
   FROM users
   WHERE (first_name LIKE '%ankit%' OR last_name LIKE '%ankit%' OR CONCAT(first_name, ' ', last_name) LIKE '%ankit%')
   AND status = 1
   LIMIT 10;

Q: "Find user John Doe's details"
A: SELECT id, CONCAT(first_name, ' ', last_name) AS name, email, user_name
   FROM users
   WHERE CONCAT(first_name, ' ', last_name) LIKE '%john%doe%'
   AND status = 1
   LIMIT 10;

Now generate a SQL query for the following question:
"""


# Legacy constant for backward compatibility
SYSTEM_PROMPT = get_system_prompt()


def read_transcript(path: Optional[str] = None, max_chars: int = 4000) -> str:
    """Read transcript text from a file (supports .txt and .pdf).

    Args:
        path: Optional path to transcript file. If not provided, uses settings.TRANSCRIPT_PATH.
        max_chars: Maximum number of characters to return (to avoid token overload).

    Returns:
        Extracted transcript text (possibly truncated) or empty string if not available.
    """
    transcript_path = path or settings.TRANSCRIPT_PATH

    if not transcript_path:
        logger.debug("No transcript path configured")
        return ""

    if not os.path.exists(transcript_path):
        logger.warning(f"Transcript file not found at {transcript_path}")
        return ""

    try:
        if transcript_path.lower().endswith('.txt'):
            with open(transcript_path, 'r', encoding='utf-8') as f:
                text = f.read()
        elif transcript_path.lower().endswith('.pdf'):
            # Import here to keep optional dependency localised
            try:
                from pypdf import PdfReader
            except Exception:
                logger.exception("pypdf not available - cannot extract text from pdf")
                return ""

            reader = PdfReader(transcript_path)
            pages = []
            for p in reader.pages:
                try:
                    pages.append(p.extract_text() or "")
                except Exception:
                    pages.append("")
            text = "\n\n".join(pages)
        else:
            # Unknown extension - try to read as text
            with open(transcript_path, 'r', encoding='utf-8', errors='ignore') as f:
                text = f.read()

        if not text:
            logger.warning(f"Transcript file found but no text extracted: {transcript_path}")
            return ""

        # Truncate to reasonable size to avoid token issues
        if len(text) > max_chars:
            logger.info(f"Truncating transcript to {max_chars} characters")
            return text[:max_chars]

        return text

    except Exception as e:
        logger.exception(f"Failed to read transcript file: {e}")
        return ""


def get_role_system_prompt(role: str, user_query: Optional[str] = None, transcript_path: Optional[str] = None) -> str:
    """Build a role-aware system prompt that includes the DB schema and transcript context.

    Args:
        role: Role name (e.g., 'fms-admin', 'hit-admin', 'recurring-admin')
        user_query: Optional user query to give context when building the prompt
        transcript_path: Optional path to transcript file (overrides settings)

    Returns:
        Combined system prompt string
    """
    base = get_system_prompt()

    transcript_text = read_transcript(transcript_path)

    role_instructions = []

    # Role-specific guidance
    role_l = role.lower()
    if role_l in ('fms-admin', 'fms_admin', 'fms'):
        role_instructions.append("As an FMS administrator, prioritize any procedures, process steps, or definitions found in the TRANSCRIPT below when answering queries about FMS workflows. If the user asks for a table or list of workflows, include columns: id, name, description, status, process_coordinator, created_at.")
        role_instructions.append("Remove any section headings like '### Summary of the Data' from transcript excerpts when incorporating them in outputs.")
    if role_l in ('hit-admin', 'hit_admin', 'hit'):
        role_instructions.append("As a Help Tickets (HIT) administrator, prioritize operational policies and ticket lifecycle details from the TRANSCRIPT when constructing queries. Prefer status breakdown patterns (SUM(condition) AS ...) for visualizable results.")
    if role_l in ('recurring-admin', 'recurring_admin', 'recurring'):
        role_instructions.append("As a Recurring Tasks administrator, use the TRANSCRIPT to prioritize scheduling rules, frequency, and escalation procedures when generating results. Include task priority and due date fields prominently.")

    # Generic administrator/manager/executive guidance
    if any(k in role_l for k in ('admin', 'manager', 'exec', 'executive')) and role_l not in ('hit-admin', 'fms-admin', 'recurring-admin'):
        role_instructions.append("As an administrative/managerial user (admin, manager, or executive), prioritize operational procedures and step-by-step guidance found in the TRANSCRIPT when the user asks for 'how-to' or 'procedure' style queries. Keep answers concise unless the user asks for more details.")

    # General admin guidance
    role_instructions.append("When role-specific instructions exist in the transcript, treat the transcript as authoritative and prefer it over general assumptions. Prefer concise (1-2 sentence) responses for brief requests, but when the user's query asks for an explanation, or when the returned data shows complexity, patterns, or anomalies, provide a full, clear explanation (3-6 sentences or more as needed) and include recommendations when applicable.")

    role_section = "\n\n".join(role_instructions)

    transcript_section = ""
    if transcript_text:
        transcript_section = f"\n\nTRANSCRIPT CONTEXT (source: {transcript_path or settings.TRANSCRIPT_PATH}):\n{transcript_text}\n\n"

    # Add optional user query context
    user_context = f"\n\nUSER QUERY CONTEXT: {user_query}" if user_query else ""

    combined = f"{base}\n\n# ROLE: {role}\n{role_section}{transcript_section}{user_context}"

    return combined


def extract_steps_from_transcript(role: str, query: Optional[str] = None, transcript_path: Optional[str] = None) -> list:
    """Try to extract numbered steps/instructional sections for a given role from the transcript.

    Returns a list of short step strings or an empty list if nothing found.
    """
    import re

    text = read_transcript(transcript_path, max_chars=8000)
    if not text:
        return []

    # Normalize
    lower_text = text.lower()
    search_targets = []

    # Role-specific search phrases
    if role and role.lower() in ('hit-admin', 'hit_admin', 'hit'):
        search_targets += [
            r'how to create a help ticket',
            r'how to raise a help ticket',
            r'steps to create a help ticket',
            r'procedure to create a help ticket',
            r'creating a help ticket',
            r'what is a help ticket',
            r'definition of a help ticket',
        ]
    if role and role.lower() in ('fms-admin', 'fms_admin', 'fms'):
        search_targets += [
            r'how to create an fms workflow',
            r'steps to create an fms workflow',
            r'procedure to create fms workflow',
            r'creating an fms workflow',
            r'what is an fms workflow',
            r'definition of fms workflow',
        ]
    if role and role.lower() in ('recurring-admin', 'recurring_admin', 'recurring'):
        search_targets += [
            r'how to create a recurring task',
            r'steps to create a recurring task',
            r'procedure to create recurring task',
            r'creating recurring tasks',
            r'what is a recurring task',
            r'definition of recurring task',
        ]
    # Support 'executive', generic 'admin' and 'manager' role queries as well
    if role and role.lower() in ('executive', 'exec', 'admin', 'manager'):
        search_targets += [
            r'how to create a help ticket',
            r'steps to create a help ticket',
            r'what is a help ticket',
            r'how to create an fms workflow',
            r'what is a recurring task',
            r'procedure to create a help ticket',
            r'steps to create a recurring task',
        ]

    # Add query text as search target if present
    if query:
        search_targets.insert(0, re.escape(query.lower()))

    for target in search_targets:
        m = re.search(target, lower_text, flags=re.IGNORECASE)
        if m:
            start = m.start()
            # extract following chunk up to next double newline or 1000 chars
            post = text[start:start+1500]

            # Remove headings like '### Summary of the Data'
            post = re.sub(r"###\s*summary of the data", "", post, flags=re.I)

            # Try to find numbered list patterns
            lines = re.split(r'\n', post)
            steps = []
            for ln in lines:
                ln_stripped = ln.strip()
                # numbered patterns
                num_match = re.match(r'^(?:\d+\.|step\s*\d+[:.-]?|\-\s+|\*\s+)(.+)', ln_stripped, flags=re.I)
                if num_match:
                    step_text = num_match.group(1).strip()
                    if step_text and len(step_text) > 3:
                        steps.append(step_text)
            if steps:
                return steps

            # If no explicit list, fall back to sentence splitting and pick sentences that look like steps
            sentences = re.split(r'(?<=[\.\?\!])\s+', post)
            candidate_steps = []
            for s in sentences:
                s_clean = s.strip()
                if len(s_clean) < 50 and len(s_clean) > 5 and re.match(r'^(step\s*\d+|\d+\.|start|first|then|next|finally|to create|click|select|open|navigate)', s_clean.lower()):
                    candidate_steps.append(s_clean)
                elif len(candidate_steps) < 5 and len(s_clean) > 20 and s_clean[0].isupper() and s_clean.endswith('.'):
                    # subjective fallback pick short sentences
                    candidate_steps.append(s_clean)
            if candidate_steps:
                # normalize to short sentences
                normalized = [re.sub(r'\s+', ' ', re.sub(r'^(step\s*\d+[:.-]?\s*)', '', s, flags=re.I)).strip().rstrip('.') for s in candidate_steps]
                return normalized

    return []


def extract_definition_from_transcript(subject_keywords: list, transcript_path: Optional[str] = None, max_chars: int = 4000) -> str:
    """Extract a short definition for a subject from the transcript.

    Args:
        subject_keywords: list of keyword phrases to search for (e.g., ['help ticket', 'help-ticket'])
        transcript_path: optional path override
        max_chars: number of chars to read from transcript

    Returns:
        A concise definition string or empty string if not found.
    """
    import re

    text = read_transcript(transcript_path, max_chars=max_chars)
    if not text:
        return ""

    lower_text = text.lower()

    # Look for 'what is X' or 'X is' patterns
    for kw in subject_keywords:
        # attempt 'what is {kw}'
        m = re.search(rf'what\s+is\s+{re.escape(kw)}', lower_text, flags=re.I)
        if m:
            start = m.start()
            post = text[start:start+800]
            # find first sentence after match
            sentences = re.split(r'(?<=[\.\?\!])\s+', post)
            if len(sentences) > 1:
                # return first explanatory sentence
                return sentences[1].strip().rstrip('.')

        # attempt pattern '{kw} is' or '{kw} refers to'
        m2 = re.search(rf'{re.escape(kw)}\s+(is|refers to|means|are)', lower_text, flags=re.I)
        if m2:
            start = m2.start()
            post = text[start:start+400]
            sentences = re.split(r'(?<=[\.\?\!])\s+', post)
            if sentences:
                # return the sentence starting at the match
                return sentences[0].strip().rstrip('.')

    return ""


# Prompt for explaining results
EXPLANATION_PROMPT = """You are a helpful AI assistant explaining database query results to users.

User asked: "{query}"

Query results: {results}

Provide a clear and friendly explanation. If the user's question or the data shows important patterns, anomalies, or insights, provide a full explanation (3-6 sentences or more as appropriate), including any useful recommendations. If the request is brief and does not require details, a concise 1-2 sentence summary is sufficient. """

# Prompt for query validation
VALIDATION_PROMPT = """Analyze this SQL query and determine if it's safe to execute:

Query: {query}

Check for:
1. No DELETE, DROP, TRUNCATE, UPDATE, or ALTER statements
2. Only SELECT queries allowed
3. No SQL injection attempts
4. Valid MySQL syntax

Respond with ONLY "SAFE" or "UNSAFE" followed by a brief reason.
"""

