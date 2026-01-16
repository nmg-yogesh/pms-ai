"""
Embedding Service for generating vector embeddings using OpenAI
"""
import logging
from typing import List, Optional
from openai import OpenAI
from backend.config import settings

logger = logging.getLogger(__name__)

# Initialize OpenAI client
client = OpenAI(api_key=settings.OPENAI_API_KEY)


class EmbeddingService:
    """Service for generating embeddings using OpenAI API"""

    def __init__(self):
        self.model = settings.EMBEDDING_MODEL
        self.dimensions = settings.EMBEDDING_DIMENSIONS
        # Check if dimensions parameter is supported (OpenAI client >= 1.10.0)
        self._supports_dimensions = self._check_dimensions_support()

    def _check_dimensions_support(self) -> bool:
        """Check if the OpenAI client supports the dimensions parameter"""
        try:
            import openai
            version = openai.__version__
            major, minor = map(int, version.split('.')[:2])
            # dimensions parameter was added in openai >= 1.10.0
            return major >= 1 and minor >= 10
        except Exception:
            return False

    def _create_embedding(self, input_data):
        """Create embedding with or without dimensions based on API support"""
        if self._supports_dimensions and self.model.startswith("text-embedding-3"):
            return client.embeddings.create(
                model=self.model,
                input=input_data,
                dimensions=self.dimensions
            )
        else:
            # Fallback for older API versions or models that don't support dimensions
            return client.embeddings.create(
                model=self.model,
                input=input_data
            )

    def embed_text(self, text: str) -> List[float]:
        """
        Generate embedding for a single text

        Args:
            text: Text to embed

        Returns:
            List of floats representing the embedding vector
        """
        try:
            # Clean and truncate text if needed
            text = text.strip()
            if not text:
                logger.warning("Empty text provided for embedding")
                return [0.0] * self.dimensions

            response = self._create_embedding(text)
            return response.data[0].embedding

        except Exception as e:
            logger.error(f"Error generating embedding: {e}")
            raise Exception(f"Failed to generate embedding: {str(e)}")

    def embed_batch(self, texts: List[str], batch_size: int = 100) -> List[List[float]]:
        """
        Generate embeddings for multiple texts

        Args:
            texts: List of texts to embed
            batch_size: Number of texts to process in each API call

        Returns:
            List of embedding vectors
        """
        try:
            if not texts:
                return []

            # Clean texts
            cleaned_texts = [t.strip() for t in texts if t.strip()]
            if not cleaned_texts:
                return []

            all_embeddings = []

            # Process in batches to avoid API limits
            for i in range(0, len(cleaned_texts), batch_size):
                batch = cleaned_texts[i:i + batch_size]

                response = self._create_embedding(batch)

                # Extract embeddings in order
                batch_embeddings = [item.embedding for item in response.data]
                all_embeddings.extend(batch_embeddings)

                logger.info(f"Embedded batch {i // batch_size + 1}, {len(batch)} texts")

            return all_embeddings

        except Exception as e:
            logger.error(f"Error generating batch embeddings: {e}")
            raise Exception(f"Failed to generate batch embeddings: {str(e)}")

    def get_embedding_dimension(self) -> int:
        """Get the dimension of embeddings"""
        return self.dimensions


# Create singleton instance
embedding_service = EmbeddingService()
