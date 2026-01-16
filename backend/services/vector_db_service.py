"""
Vector Database Service using ChromaDB for RAG operations
"""
import os
import logging
from typing import List, Dict, Any, Optional
import chromadb
from chromadb.config import Settings as ChromaSettings

from backend.config import settings
from backend.services.embedding_service import embedding_service

logger = logging.getLogger(__name__)

# Collection names
SCHEMA_COLLECTION = "pms_schema"
EXAMPLES_COLLECTION = "query_examples"
DOCS_COLLECTION = "documentation"


class VectorDBService:
    """Service for ChromaDB vector database operations"""

    def __init__(self):
        self.client: Optional[chromadb.PersistentClient] = None
        self.schema_collection = None
        self.examples_collection = None
        self.docs_collection = None
        self._initialized = False

    def initialize(self) -> bool:
        """
        Initialize ChromaDB client and collections

        Returns:
            True if initialization successful
        """
        try:
            # Ensure data directory exists
            os.makedirs(settings.CHROMA_PERSIST_DIR, exist_ok=True)

            # Initialize persistent client
            self.client = chromadb.PersistentClient(
                path=settings.CHROMA_PERSIST_DIR,
                settings=ChromaSettings(
                    anonymized_telemetry=False,
                    allow_reset=True
                )
            )

            # Get or create collections
            self.schema_collection = self.client.get_or_create_collection(
                name=SCHEMA_COLLECTION,
                metadata={"description": "Database table schemas"}
            )

            self.examples_collection = self.client.get_or_create_collection(
                name=EXAMPLES_COLLECTION,
                metadata={"description": "Query examples"}
            )

            self.docs_collection = self.client.get_or_create_collection(
                name=DOCS_COLLECTION,
                metadata={"description": "Documentation chunks"}
            )

            self._initialized = True
            logger.info(f"ChromaDB initialized at {settings.CHROMA_PERSIST_DIR}")
            return True

        except Exception as e:
            logger.error(f"Failed to initialize ChromaDB: {e}")
            self._initialized = False
            return False

    def is_initialized(self) -> bool:
        """Check if service is initialized"""
        return self._initialized

    def is_empty(self) -> bool:
        """Check if all collections are empty"""
        if not self._initialized:
            return True
        return (
            self.schema_collection.count() == 0 and
            self.examples_collection.count() == 0 and
            self.docs_collection.count() == 0
        )

    def get_stats(self) -> Dict[str, int]:
        """Get collection statistics"""
        if not self._initialized:
            return {"error": "Not initialized"}
        return {
            "schema_count": self.schema_collection.count(),
            "examples_count": self.examples_collection.count(),
            "docs_count": self.docs_collection.count()
        }

    # ==================== Schema Operations ====================

    def add_table_schema(
        self,
        table_name: str,
        schema_text: str,
        columns: List[str],
        relationships: Optional[List[str]] = None,
        category: str = "general"
    ) -> bool:
        """
        Add a table schema to the vector database

        Args:
            table_name: Name of the table
            schema_text: Full schema description for embedding
            columns: List of column names
            relationships: List of related tables
            category: Category (e.g., tickets, users, workflows)
        """
        try:
            embedding = embedding_service.embed_text(schema_text)

            self.schema_collection.add(
                ids=[table_name],
                embeddings=[embedding],
                documents=[schema_text],
                metadatas=[{
                    "table_name": table_name,
                    "columns": ",".join(columns),
                    "relationships": ",".join(relationships) if relationships else "",
                    "category": category
                }]
            )
            logger.info(f"Added schema for table: {table_name}")
            return True

        except Exception as e:
            logger.error(f"Error adding table schema {table_name}: {e}")
            return False

    def add_schemas_batch(self, schemas: List[Dict[str, Any]]) -> int:
        """
        Add multiple table schemas in batch

        Args:
            schemas: List of schema dictionaries with keys:
                - table_name, schema_text, columns, relationships, category

        Returns:
            Number of schemas added successfully
        """
        try:
            if not schemas:
                return 0

            ids = []
            documents = []
            metadatas = []

            for schema in schemas:
                ids.append(schema["table_name"])
                documents.append(schema["schema_text"])
                metadatas.append({
                    "table_name": schema["table_name"],
                    "columns": ",".join(schema.get("columns", [])),
                    "relationships": ",".join(schema.get("relationships", [])),
                    "category": schema.get("category", "general")
                })

            # Generate embeddings in batch
            embeddings = embedding_service.embed_batch(documents)

            # Add to collection
            self.schema_collection.add(
                ids=ids,
                embeddings=embeddings,
                documents=documents,
                metadatas=metadatas
            )

            logger.info(f"Added {len(schemas)} schemas in batch")
            return len(schemas)

        except Exception as e:
            logger.error(f"Error adding schemas batch: {e}")
            return 0

    def search_relevant_schema(
        self,
        query: str,
        top_k: int = None,
        category_filter: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Search for relevant table schemas

        Args:
            query: Natural language query
            top_k: Number of results to return
            category_filter: Optional category to filter by

        Returns:
            List of relevant schema dictionaries
        """
        try:
            if top_k is None:
                top_k = settings.RAG_TOP_K

            # Generate query embedding
            query_embedding = embedding_service.embed_text(query)

            # Build where filter if category specified
            where_filter = None
            if category_filter:
                where_filter = {"category": category_filter}

            # Search collection
            results = self.schema_collection.query(
                query_embeddings=[query_embedding],
                n_results=top_k,
                where=where_filter,
                include=["documents", "metadatas", "distances"]
            )

            # Format results
            formatted_results = []
            if results and results["documents"]:
                for i, doc in enumerate(results["documents"][0]):
                    formatted_results.append({
                        "table_name": results["metadatas"][0][i]["table_name"],
                        "schema_text": doc,
                        "columns": results["metadatas"][0][i]["columns"].split(","),
                        "relationships": results["metadatas"][0][i]["relationships"].split(",") if results["metadatas"][0][i]["relationships"] else [],
                        "category": results["metadatas"][0][i]["category"],
                        "distance": results["distances"][0][i] if results["distances"] else None
                    })

            return formatted_results

        except Exception as e:
            logger.error(f"Error searching schema: {e}")
            return []

    # ==================== Examples Operations ====================

    def add_query_example(
        self,
        example_id: str,
        natural_language: str,
        sql_query: str,
        category: str = "general"
    ) -> bool:
        """
        Add a query example

        Args:
            example_id: Unique identifier for the example
            natural_language: Natural language query
            sql_query: Corresponding SQL query
            category: Category (e.g., tickets, users, workflows)
        """
        try:
            # Create combined text for embedding
            combined_text = f"Query: {natural_language}\nSQL: {sql_query}"
            embedding = embedding_service.embed_text(natural_language)

            self.examples_collection.add(
                ids=[example_id],
                embeddings=[embedding],
                documents=[combined_text],
                metadatas=[{
                    "natural_language": natural_language,
                    "sql_query": sql_query,
                    "category": category
                }]
            )
            logger.info(f"Added query example: {example_id}")
            return True

        except Exception as e:
            logger.error(f"Error adding query example {example_id}: {e}")
            return False

    def add_examples_batch(self, examples: List[Dict[str, Any]]) -> int:
        """
        Add multiple query examples in batch

        Args:
            examples: List of example dictionaries with keys:
                - example_id, natural_language, sql_query, category

        Returns:
            Number of examples added successfully
        """
        try:
            if not examples:
                return 0

            ids = []
            documents = []
            metadatas = []
            nl_texts = []

            for ex in examples:
                ids.append(ex["example_id"])
                combined_text = f"Query: {ex['natural_language']}\nSQL: {ex['sql_query']}"
                documents.append(combined_text)
                nl_texts.append(ex["natural_language"])
                metadatas.append({
                    "natural_language": ex["natural_language"],
                    "sql_query": ex["sql_query"],
                    "category": ex.get("category", "general")
                })

            # Generate embeddings for natural language texts
            embeddings = embedding_service.embed_batch(nl_texts)

            self.examples_collection.add(
                ids=ids,
                embeddings=embeddings,
                documents=documents,
                metadatas=metadatas
            )

            logger.info(f"Added {len(examples)} examples in batch")
            return len(examples)

        except Exception as e:
            logger.error(f"Error adding examples batch: {e}")
            return 0

    def search_similar_examples(
        self,
        query: str,
        top_k: int = None,
        category_filter: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Search for similar query examples

        Args:
            query: Natural language query
            top_k: Number of results to return
            category_filter: Optional category to filter by

        Returns:
            List of similar example dictionaries
        """
        try:
            if top_k is None:
                top_k = settings.RAG_TOP_K

            query_embedding = embedding_service.embed_text(query)

            where_filter = None
            if category_filter:
                where_filter = {"category": category_filter}

            results = self.examples_collection.query(
                query_embeddings=[query_embedding],
                n_results=top_k,
                where=where_filter,
                include=["documents", "metadatas", "distances"]
            )

            formatted_results = []
            if results and results["documents"]:
                for i, doc in enumerate(results["documents"][0]):
                    formatted_results.append({
                        "natural_language": results["metadatas"][0][i]["natural_language"],
                        "sql_query": results["metadatas"][0][i]["sql_query"],
                        "category": results["metadatas"][0][i]["category"],
                        "distance": results["distances"][0][i] if results["distances"] else None
                    })

            return formatted_results

        except Exception as e:
            logger.error(f"Error searching examples: {e}")
            return []

    # ==================== Documentation Operations ====================

    def add_doc_chunk(
        self,
        chunk_id: str,
        content: str,
        source: str = "documentation",
        role: Optional[str] = None
    ) -> bool:
        """
        Add a documentation chunk

        Args:
            chunk_id: Unique identifier for the chunk
            content: Text content
            source: Source of the documentation
            role: Optional role filter (e.g., fms-admin, hit-admin)
        """
        try:
            embedding = embedding_service.embed_text(content)

            self.docs_collection.add(
                ids=[chunk_id],
                embeddings=[embedding],
                documents=[content],
                metadatas=[{
                    "source": source,
                    "role": role or "general"
                }]
            )
            logger.info(f"Added doc chunk: {chunk_id}")
            return True

        except Exception as e:
            logger.error(f"Error adding doc chunk {chunk_id}: {e}")
            return False

    def add_docs_batch(self, docs: List[Dict[str, Any]]) -> int:
        """
        Add multiple documentation chunks in batch

        Args:
            docs: List of doc dictionaries with keys:
                - chunk_id, content, source, role

        Returns:
            Number of docs added successfully
        """
        try:
            if not docs:
                return 0

            ids = []
            documents = []
            metadatas = []

            for doc in docs:
                ids.append(doc["chunk_id"])
                documents.append(doc["content"])
                metadatas.append({
                    "source": doc.get("source", "documentation"),
                    "role": doc.get("role", "general")
                })

            embeddings = embedding_service.embed_batch(documents)

            self.docs_collection.add(
                ids=ids,
                embeddings=embeddings,
                documents=documents,
                metadatas=metadatas
            )

            logger.info(f"Added {len(docs)} doc chunks in batch")
            return len(docs)

        except Exception as e:
            logger.error(f"Error adding docs batch: {e}")
            return 0

    def search_docs(
        self,
        query: str,
        top_k: int = None,
        role_filter: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Search for relevant documentation

        Args:
            query: Search query
            top_k: Number of results to return
            role_filter: Optional role to filter by

        Returns:
            List of relevant documentation chunks
        """
        try:
            if top_k is None:
                top_k = settings.RAG_TOP_K

            query_embedding = embedding_service.embed_text(query)

            where_filter = None
            if role_filter:
                where_filter = {"role": role_filter}

            results = self.docs_collection.query(
                query_embeddings=[query_embedding],
                n_results=top_k,
                where=where_filter,
                include=["documents", "metadatas", "distances"]
            )

            formatted_results = []
            if results and results["documents"]:
                for i, doc in enumerate(results["documents"][0]):
                    formatted_results.append({
                        "content": doc,
                        "source": results["metadatas"][0][i]["source"],
                        "role": results["metadatas"][0][i]["role"],
                        "distance": results["distances"][0][i] if results["distances"] else None
                    })

            return formatted_results

        except Exception as e:
            logger.error(f"Error searching docs: {e}")
            return []

    # ==================== Combined RAG Context ====================

    def get_rag_context(
        self,
        query: str,
        role: Optional[str] = None,
        include_examples: bool = True,
        include_docs: bool = True
    ) -> Dict[str, Any]:
        """
        Get combined RAG context for a query

        Args:
            query: Natural language query
            role: Optional role for filtering
            include_examples: Whether to include similar examples
            include_docs: Whether to include documentation

        Returns:
            Dictionary with relevant_tables, similar_examples, relevant_docs
        """
        try:
            context = {
                "relevant_tables": [],
                "similar_examples": [],
                "relevant_docs": []
            }

            # Get relevant schemas
            context["relevant_tables"] = self.search_relevant_schema(query)

            # Get similar examples if requested
            if include_examples:
                context["similar_examples"] = self.search_similar_examples(query)

            # Get relevant docs if requested
            if include_docs:
                context["relevant_docs"] = self.search_docs(query, role_filter=role)

            return context

        except Exception as e:
            logger.error(f"Error getting RAG context: {e}")
            return {
                "relevant_tables": [],
                "similar_examples": [],
                "relevant_docs": []
            }

    # ==================== Collection Management ====================

    def clear_collection(self, collection_name: str) -> bool:
        """Clear a specific collection"""
        try:
            if collection_name == SCHEMA_COLLECTION:
                self.client.delete_collection(SCHEMA_COLLECTION)
                self.schema_collection = self.client.create_collection(
                    name=SCHEMA_COLLECTION,
                    metadata={"description": "Database table schemas"}
                )
            elif collection_name == EXAMPLES_COLLECTION:
                self.client.delete_collection(EXAMPLES_COLLECTION)
                self.examples_collection = self.client.create_collection(
                    name=EXAMPLES_COLLECTION,
                    metadata={"description": "Query examples"}
                )
            elif collection_name == DOCS_COLLECTION:
                self.client.delete_collection(DOCS_COLLECTION)
                self.docs_collection = self.client.create_collection(
                    name=DOCS_COLLECTION,
                    metadata={"description": "Documentation chunks"}
                )
            else:
                logger.warning(f"Unknown collection: {collection_name}")
                return False

            logger.info(f"Cleared collection: {collection_name}")
            return True

        except Exception as e:
            logger.error(f"Error clearing collection {collection_name}: {e}")
            return False

    def clear_all_collections(self) -> bool:
        """Clear all collections"""
        try:
            self.clear_collection(SCHEMA_COLLECTION)
            self.clear_collection(EXAMPLES_COLLECTION)
            self.clear_collection(DOCS_COLLECTION)
            logger.info("Cleared all collections")
            return True
        except Exception as e:
            logger.error(f"Error clearing all collections: {e}")
            return False


# Create singleton instance
vector_db_service = VectorDBService()
