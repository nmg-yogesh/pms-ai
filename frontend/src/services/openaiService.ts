/**
 * PMS Agentic AI Service
 * Handles all communication with the enhanced backend API
 */

const API_URL = process.env.NODE_ENV === 'production'
  ? 'https://processhq-gpt-demo.newmediaguru.co'
  :   process.env.REACT_APP_API_URL || 'http://localhost:8000';
const API_BASE = `${API_URL}/api/v1`;

export interface AgenticQueryRequest {
  query: string;
  user_id?: number;
  include_explanation?: boolean;
  speak_response?: boolean;
}

export interface ChartConfig {
  chart_type: 'bar' | 'stacked_bar' | 'pie' | 'line' | 'doughnut';
  x_axis?: string;
  y_axis?: string[];
  title?: string;
  description?: string;
  stacked_keys?: string[];
  colors?: Record<string, string>;
}

export interface AgenticQueryResponse {
  success: boolean;
  query: string;
  sql_query: string | null;
  results: Record<string, any>[];
  explanation: string | null;
  result_count: number;
  execution_time_ms: number;
  error: string | null;
  chart_config?: ChartConfig | null;
}

export interface ExampleQueriesResponse {
  hit_tickets: string[];
  fms_workflows: string[];
  recurring_tasks: string[];
  users: string[];
  general: string[];
}

export interface ChatSession {
  id: string;
  user_id?: number;
  title: string;
  created_at: string;
  updated_at: string;
  message_count: number;
  is_active: boolean;
}

export interface ConversationMessage {
  id: number;
  session_id: string;
  message_type: 'user' | 'assistant' | 'system' | 'error';
  content: string;
  query?: string;
  sql_query?: string;
  result_count?: number;
  execution_time_ms?: number;
  chart_config?: ChartConfig;
  metadata?: Record<string, any>;
  created_at: string;
}

export interface ConversationHistory {
  session: ChatSession;
  messages: ConversationMessage[];
}

/**
 * Process a natural language query using the backend agentic AI
 * This single API call handles:
 * 1. Natural language to SQL conversion
 * 2. Query validation
 * 3. Database execution
 * 4. Result analysis
 * 5. Natural language explanation
 */
export const processAgenticQuery = async (
  query: string,
  userId?: number,
  includeExplanation: boolean = true,
  sessionId?: string
): Promise<AgenticQueryResponse> => {
  const requestBody: AgenticQueryRequest = {
    query,
    user_id: userId,
    include_explanation: includeExplanation,
    speak_response: false
  };

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };

  // Add session ID header if provided
  if (sessionId) {
    headers['X-Session-Id'] = sessionId;
  }

  const response = await fetch(`${API_BASE}/agentic/query`, {
    method: 'POST',
    headers,
    body: JSON.stringify(requestBody),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.detail || error.error || 'Failed to process query');
  }

  const data: AgenticQueryResponse = await response.json();
  return data;
};

/**
 * Get example queries from the backend
 */
export const getExampleQueries = async (): Promise<ExampleQueriesResponse> => {
  const response = await fetch(`${API_BASE}/agentic/examples`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error('Failed to fetch example queries');
  }

  return await response.json();
};

/**
 * Check backend health status
 */
export const checkHealth = async (): Promise<{
  status: string;
  version: string;
  database_connected: boolean;
  openai_configured: boolean;
  timestamp: string;
}> => {
  const response = await fetch(`${API_BASE}/health`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error('Health check failed');
  }

  return await response.json();
};

/**
 * Create a new chat session
 */
export const createChatSession = async (
  sessionId: string,
  title: string,
  userId?: number
): Promise<ChatSession> => {
  const response = await fetch(`${API_BASE}/conversation/sessions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      session_id: sessionId,
      title,
      user_id: userId,
    }),
  });

  if (!response.ok) {
    throw new Error('Failed to create chat session');
  }

  return await response.json();
};

/**
 * Get conversation history for a session
 */
export const getConversationHistory = async (
  sessionId: string,
  limit: number = 100
): Promise<ConversationHistory> => {
  const response = await fetch(
    `${API_BASE}/conversation/history/${sessionId}?limit=${limit}`,
    {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    }
  );

  if (!response.ok) {
    throw new Error('Failed to fetch conversation history');
  }

  return await response.json();
};

/**
 * List all chat sessions
 */
export const listChatSessions = async (
  userId?: number,
  limit: number = 50
): Promise<{ sessions: ChatSession[]; total_count: number }> => {
  const params = new URLSearchParams();
  if (userId) params.append('user_id', userId.toString());
  params.append('limit', limit.toString());

  const response = await fetch(`${API_BASE}/conversation/sessions?${params}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error('Failed to list chat sessions');
  }

  return await response.json();
};
