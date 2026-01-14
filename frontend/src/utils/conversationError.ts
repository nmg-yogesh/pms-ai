export const storeConversationError = async (sessionId: string, errorMessage: string) => {
  const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';
  const API_BASE = `${API_URL}/api/v1`;
    console.log('Storing error:', sessionId, errorMessage);
  const response = await fetch(`${API_BASE}/conversation/error`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      session_id: sessionId,
      error_message: errorMessage
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.detail || error.error || 'Failed to store error');
  }

  return await response.json();
};
