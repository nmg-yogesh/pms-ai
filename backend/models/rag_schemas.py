"""
Pydantic schemas for RAG (Retrieval-Augmented Generation) system
"""
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field


class TableSchema(BaseModel):
    """Schema for a database table"""
    table_name: str
    schema_text: str
    columns: List[str] = Field(default_factory=list)
    relationships: List[str] = Field(default_factory=list)
    category: str = "general"
    distance: Optional[float] = None


class QueryExample(BaseModel):
    """Schema for a query example"""
    example_id: Optional[str] = None
    natural_language: str
    sql_query: str
    category: str = "general"
    distance: Optional[float] = None


class DocChunk(BaseModel):
    """Schema for a documentation chunk"""
    chunk_id: Optional[str] = None
    content: str
    source: str = "documentation"
    role: str = "general"
    distance: Optional[float] = None


class RAGContext(BaseModel):
    """Combined RAG context for a query"""
    relevant_tables: List[TableSchema] = Field(default_factory=list)
    similar_examples: List[QueryExample] = Field(default_factory=list)
    relevant_docs: List[DocChunk] = Field(default_factory=list)


class RAGStats(BaseModel):
    """Statistics for RAG collections"""
    schema_count: int = 0
    examples_count: int = 0
    docs_count: int = 0
    is_initialized: bool = False


# Request/Response schemas for RAG API endpoints

class IndexSchemaRequest(BaseModel):
    """Request to index database schema"""
    force_reindex: bool = False


class IndexExamplesRequest(BaseModel):
    """Request to index query examples"""
    force_reindex: bool = False


class IndexDocsRequest(BaseModel):
    """Request to index documentation"""
    force_reindex: bool = False


class IndexAllRequest(BaseModel):
    """Request to index all collections"""
    force_reindex: bool = False


class SearchRequest(BaseModel):
    """Request to search vector database"""
    query: str = Field(..., min_length=1, max_length=500)
    collection: str = Field(default="all", description="Collection to search: schema, examples, docs, or all")
    top_k: int = Field(default=5, ge=1, le=20)
    role: Optional[str] = None


class SearchResponse(BaseModel):
    """Response from vector database search"""
    query: str
    results: RAGContext
    total_results: int


class IndexResponse(BaseModel):
    """Response from indexing operation"""
    success: bool
    message: str
    stats: RAGStats
