"""
RAG (Retrieval-Augmented Generation) API Router
Provides endpoints for managing the vector database and RAG system
"""
import logging
from fastapi import APIRouter, HTTPException, BackgroundTasks
from typing import Optional

from backend.services.vector_db_service import vector_db_service
from backend.models.rag_schemas import (
    IndexSchemaRequest,
    IndexExamplesRequest,
    IndexDocsRequest,
    IndexAllRequest,
    SearchRequest,
    SearchResponse,
    IndexResponse,
    RAGStats,
    RAGContext
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/rag", tags=["RAG"])


@router.get("/stats", response_model=RAGStats)
async def get_rag_stats():
    """
    Get statistics about the RAG vector database collections
    """
    try:
        if not vector_db_service.is_initialized():
            return RAGStats(
                schema_count=0,
                examples_count=0,
                docs_count=0,
                is_initialized=False
            )

        stats = vector_db_service.get_stats()
        return RAGStats(
            schema_count=stats.get("schema_count", 0),
            examples_count=stats.get("examples_count", 0),
            docs_count=stats.get("docs_count", 0),
            is_initialized=True
        )
    except Exception as e:
        logger.error(f"Error getting RAG stats: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/index/schema", response_model=IndexResponse)
async def index_schema(request: IndexSchemaRequest, background_tasks: BackgroundTasks):
    """
    Index database schema into the vector database
    """
    try:
        from backend.scripts.index_schema import index_schema as run_index_schema

        # Initialize if needed
        if not vector_db_service.is_initialized():
            vector_db_service.initialize()

        # Run indexing
        result = run_index_schema(force_reindex=request.force_reindex)

        stats = vector_db_service.get_stats()

        return IndexResponse(
            success=result.get("success", False),
            message=result.get("message", ""),
            stats=RAGStats(
                schema_count=stats.get("schema_count", 0),
                examples_count=stats.get("examples_count", 0),
                docs_count=stats.get("docs_count", 0),
                is_initialized=True
            )
        )
    except Exception as e:
        logger.error(f"Error indexing schema: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/index/examples", response_model=IndexResponse)
async def index_examples(request: IndexExamplesRequest):
    """
    Index query examples into the vector database
    """
    try:
        from backend.scripts.index_examples import index_examples as run_index_examples

        # Initialize if needed
        if not vector_db_service.is_initialized():
            vector_db_service.initialize()

        # Run indexing
        result = run_index_examples(force_reindex=request.force_reindex)

        stats = vector_db_service.get_stats()

        return IndexResponse(
            success=result.get("success", False),
            message=result.get("message", ""),
            stats=RAGStats(
                schema_count=stats.get("schema_count", 0),
                examples_count=stats.get("examples_count", 0),
                docs_count=stats.get("docs_count", 0),
                is_initialized=True
            )
        )
    except Exception as e:
        logger.error(f"Error indexing examples: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/index/docs", response_model=IndexResponse)
async def index_docs(request: IndexDocsRequest):
    """
    Index documentation into the vector database
    """
    try:
        from backend.scripts.index_docs import index_docs as run_index_docs

        # Initialize if needed
        if not vector_db_service.is_initialized():
            vector_db_service.initialize()

        # Run indexing
        result = run_index_docs(force_reindex=request.force_reindex)

        stats = vector_db_service.get_stats()

        return IndexResponse(
            success=result.get("success", False),
            message=result.get("message", ""),
            stats=RAGStats(
                schema_count=stats.get("schema_count", 0),
                examples_count=stats.get("examples_count", 0),
                docs_count=stats.get("docs_count", 0),
                is_initialized=True
            )
        )
    except Exception as e:
        logger.error(f"Error indexing docs: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/index/all", response_model=IndexResponse)
async def index_all(request: IndexAllRequest):
    """
    Index all collections (schema, examples, docs) into the vector database
    """
    try:
        from backend.scripts.index_all import index_all as run_index_all

        # Initialize if needed
        if not vector_db_service.is_initialized():
            vector_db_service.initialize()

        # Run full indexing
        result = run_index_all(force_reindex=request.force_reindex)

        stats = vector_db_service.get_stats()

        return IndexResponse(
            success=result.get("success", False),
            message=result.get("message", ""),
            stats=RAGStats(
                schema_count=stats.get("schema_count", 0),
                examples_count=stats.get("examples_count", 0),
                docs_count=stats.get("docs_count", 0),
                is_initialized=True
            )
        )
    except Exception as e:
        logger.error(f"Error indexing all: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/search", response_model=SearchResponse)
async def search_vector_db(request: SearchRequest):
    """
    Search the vector database for relevant context

    This endpoint is useful for debugging and testing the RAG system.
    """
    try:
        if not vector_db_service.is_initialized():
            raise HTTPException(status_code=400, detail="Vector DB not initialized")

        results = RAGContext(
            relevant_tables=[],
            similar_examples=[],
            relevant_docs=[]
        )

        total_results = 0

        # Search based on collection parameter
        if request.collection in ("all", "schema"):
            schema_results = vector_db_service.search_relevant_schema(
                query=request.query,
                top_k=request.top_k
            )
            results.relevant_tables = schema_results
            total_results += len(schema_results)

        if request.collection in ("all", "examples"):
            example_results = vector_db_service.search_similar_examples(
                query=request.query,
                top_k=request.top_k
            )
            results.similar_examples = example_results
            total_results += len(example_results)

        if request.collection in ("all", "docs"):
            doc_results = vector_db_service.search_docs(
                query=request.query,
                top_k=request.top_k,
                role_filter=request.role
            )
            results.relevant_docs = doc_results
            total_results += len(doc_results)

        return SearchResponse(
            query=request.query,
            results=results,
            total_results=total_results
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error searching vector DB: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/clear/{collection}")
async def clear_collection(collection: str):
    """
    Clear a specific collection in the vector database

    Args:
        collection: One of 'schema', 'examples', 'docs', or 'all'
    """
    try:
        if not vector_db_service.is_initialized():
            raise HTTPException(status_code=400, detail="Vector DB not initialized")

        valid_collections = ["schema", "examples", "docs", "all"]
        if collection not in valid_collections:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid collection. Must be one of: {valid_collections}"
            )

        if collection == "all":
            success = vector_db_service.clear_all_collections()
        else:
            # Map friendly names to internal collection names
            collection_map = {
                "schema": "pms_schema",
                "examples": "query_examples",
                "docs": "documentation"
            }
            success = vector_db_service.clear_collection(collection_map[collection])

        if success:
            stats = vector_db_service.get_stats()
            return {
                "success": True,
                "message": f"Cleared collection: {collection}",
                "stats": stats
            }
        else:
            raise HTTPException(status_code=500, detail="Failed to clear collection")

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error clearing collection: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/initialize")
async def initialize_vector_db():
    """
    Initialize the vector database

    This is called automatically on startup, but can be called manually if needed.
    """
    try:
        if vector_db_service.is_initialized():
            stats = vector_db_service.get_stats()
            return {
                "success": True,
                "message": "Vector DB already initialized",
                "stats": stats
            }

        success = vector_db_service.initialize()

        if success:
            stats = vector_db_service.get_stats()
            return {
                "success": True,
                "message": "Vector DB initialized successfully",
                "stats": stats
            }
        else:
            raise HTTPException(status_code=500, detail="Failed to initialize vector DB")

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error initializing vector DB: {e}")
        raise HTTPException(status_code=500, detail=str(e))
