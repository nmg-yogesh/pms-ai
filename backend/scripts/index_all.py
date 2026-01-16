"""
Script to index all collections into ChromaDB
"""
import os
import logging
from typing import Dict, Any

# Setup path for imports
import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from backend.services.vector_db_service import vector_db_service
from backend.scripts.index_schema import index_schema
from backend.scripts.index_examples import index_examples
from backend.scripts.index_docs import index_docs

logger = logging.getLogger(__name__)


def index_all(force_reindex: bool = False) -> Dict[str, Any]:
    """
    Index all collections (schema, examples, docs) into ChromaDB

    Args:
        force_reindex: If True, clear existing data before indexing

    Returns:
        Dictionary with indexing results for each collection
    """
    result = {
        "success": False,
        "schema": {},
        "examples": {},
        "docs": {},
        "message": ""
    }

    try:
        # Initialize vector DB
        if not vector_db_service.is_initialized():
            if not vector_db_service.initialize():
                result["message"] = "Failed to initialize vector database"
                return result

        logger.info("Starting full indexing...")

        # Index schema
        logger.info("Indexing database schema...")
        result["schema"] = index_schema(force_reindex=force_reindex)

        # Index examples
        logger.info("Indexing query examples...")
        result["examples"] = index_examples(force_reindex=force_reindex)

        # Index docs
        logger.info("Indexing documentation...")
        result["docs"] = index_docs(force_reindex=force_reindex)

        # Get final stats
        stats = vector_db_service.get_stats()

        result["success"] = True
        result["message"] = (
            f"Indexing complete. "
            f"Schema: {stats.get('schema_count', 0)} tables, "
            f"Examples: {stats.get('examples_count', 0)}, "
            f"Docs: {stats.get('docs_count', 0)} chunks"
        )

        logger.info(result["message"])
        return result

    except Exception as e:
        logger.error(f"Error during full indexing: {e}")
        result["message"] = f"Error: {str(e)}"
        return result


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    result = index_all(force_reindex=True)
    print(f"\n{'='*50}")
    print("INDEXING RESULTS")
    print(f"{'='*50}")
    print(f"Success: {result['success']}")
    print(f"Message: {result['message']}")
    print(f"\nSchema: {result['schema']}")
    print(f"Examples: {result['examples']}")
    print(f"Docs: {result['docs']}")
