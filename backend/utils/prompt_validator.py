import re

MIN_LENGTH = 10

ALLOWED_KEYWORDS = [
    "user", "users", "employee", "staff", "person",
    "email", "mail", "phone", "mobile", "contact",
    "name", "id",
    "ticket", "tickets",
    "fms",
    "task", "tasks",
    "department", "designation",
    "show", "list", "count", "find", "get",
    "pending", "active", "completed",
    "who", "how", "which", "of"
]

def is_meaningful_prompt(text: str):
    if not text:
        return False, "Query is empty."

    text = text.strip()

    # Too short
    if len(text) < MIN_LENGTH:
        return False, "Query is too short."

    # Must contain alphabets
    if not re.search(r"[a-zA-Z]", text):
        return False, "Query must contain readable text."

    # Reject excessive symbols
    symbol_ratio = len(re.findall(r"[^a-zA-Z0-9\s]", text)) / len(text)
    if symbol_ratio > 0.25:
        return False, "Too many special characters."

    # Reject excessive digits
    digit_ratio = len(re.findall(r"\d", text)) / len(text)
    if digit_ratio > 0.4:
        return False, "Too many numbers."

    # Split into words
    words = re.findall(r"[a-zA-Z]+", text.lower())

    # Must have at least 3 real words
    if len(words) < 3:
        return False, "Not enough meaningful words."

    # Detect keyboard smashing (low vowel ratio)
    total_letters = sum(len(w) for w in words)
    vowel_count = len(re.findall(r"[aeiou]", "".join(words)))
    if total_letters > 0 and vowel_count / total_letters < 0.2:
        return False, "Looks like random typing."

    # Domain keyword check (VERY IMPORTANT)
    if not any(keyword in words for keyword in ALLOWED_KEYWORDS):
        return False, "Query not related to supported domain."

    return True, "Query is meaningful."
