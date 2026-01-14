import { useState, useEffect } from 'react';
import { Message, DBConfig } from './types';
import {
  ConfigPanel,
  Header,
  MessageList,
  InputArea,
  ChatHistory,
  ChatSession
} from './components';
import { useAutoScroll } from './hooks';
// import { speakText } from './utils/speechUtils';
import {
  processAgenticQuery,
  checkHealth,
  createChatSession,
  getConversationHistory,
  listChatSessions
} from './services/openaiService';
import { storeConversationError } from './utils/conversationError';

export default function AIDBAssistant() {
  const [input, setInput] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(false);
  const [dbConfig, setDbConfig] = useState<DBConfig>({
    host: '',
    user: '',
    password: '',
    database: ''
  });
  const [showConfig, setShowConfig] = useState(false); // Changed to false - no config needed
  const [isListening, setIsListening] = useState(false);
  const [backendStatus, setBackendStatus] = useState<{
    connected: boolean;
    message: string;
  }>({ connected: false, message: 'Checking backend...' });
  const [showHistory, setShowHistory] = useState(false);
  const [chatSessions, setChatSessions] = useState<ChatSession[]>([]);
  const [currentSessionId, setCurrentSessionId] = useState<string>('default');
  const [historyLoading, setHistoryLoading] = useState<boolean>(true);

  // Normalize backend session objects into UI-friendly shape
  const normalizeSession = (s: any) => ({
    id: s.id,
    title: s.title || s.name || 'Untitled',
    // Prefer updated_at, fallback to created_at, otherwise now
    timestamp: s.updated_at ? new Date(s.updated_at) : s.created_at ? new Date(s.created_at) : new Date(),
    messageCount: s.message_count ?? s.messageCount ?? 0
  });

  const messagesEndRef = useAutoScroll(messages);

  // Check backend health on mount
  useEffect(() => {
    const checkBackendHealth = async () => {
      try {
        const health = await checkHealth();
        if (health.status === 'healthy' && health.database_connected && health.openai_configured) {
          setBackendStatus({
            connected: true,
            message: `Connected`
          });
        } else {
          setBackendStatus({
            connected: false,
            message: 'Backend not fully configured'
          });
        }
      } catch (error) {
        setBackendStatus({
          connected: false,
          message: 'Backend not available. Please start the backend server.'
        });
      }
    };

    checkBackendHealth();
  }, []);

  // Load existing chat sessions and history
  useEffect(() => {
    const loadSessions = async () => {
      setHistoryLoading(true);
      try {
        const res = await listChatSessions();
        if (res.sessions && res.sessions.length > 0) {
          // Do NOT auto-load the first session's history.
          // Show a fresh "new chat" until the user selects an existing session.
          const mappedSessions = res.sessions.map(normalizeSession);
          setChatSessions(mappedSessions);
          setMessages([]); // keep UI on a new chat
          setCurrentSessionId('default');
        } else {
          // create a default session if none exist and select it
          const id = `session-${Date.now()}`;
          try {
            const created = await createChatSession(id, 'New chat');
            setChatSessions([normalizeSession(created)]);
            setCurrentSessionId(created.id);
            setMessages([]);
          } catch (e) {
            console.error('Failed to create default session', e);
            setCurrentSessionId('default');
          }
        }
      } catch (err) {
        console.error('Failed to list chat sessions', err);
      } finally {
        setHistoryLoading(false);
      }
    };

    loadSessions();
  }, []);

  // Handle speech recognition
  const handleSpeechTranscript = (transcript: string) => {
    setInput(transcript);
    setIsListening(false);
  };

  const toggleListening = () => {
    if (!('webkitSpeechRecognition' in window)) {
      alert('Speech recognition not supported in this browser');
      return;
    }

    if (isListening) {
      setIsListening(false);
    } else {
      const recognition = new window.webkitSpeechRecognition();
      recognition.continuous = false;
      recognition.interimResults = false;

      recognition.onresult = (event: any) => {
        const transcript = event.results[0][0].transcript;
        handleSpeechTranscript(transcript);
      };

      recognition.onerror = () => setIsListening(false);
      recognition.onend = () => setIsListening(false);
      recognition.start();
      setIsListening(true);
    }
  };

  const processQuery = async () => {
    if (!input.trim()) return;

    const userMessage: Message = {
      type: 'user',
      content: input,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, userMessage]);
    setLoading(true);
    const currentInput = input;
    setInput('');

    // Update chat session (ensure session exists)
    await updateChatSession(currentInput);

    try {
      // Use the unified backend API that handles everything:
      // 1. Natural language to SQL conversion
      // 2. Query validation
      // 3. Database execution
      // 4. Result analysis
      // 5. Natural language explanation
      const response = await processAgenticQuery(currentInput, undefined, true, currentSessionId);

      if (!response.success) {
        const errorMessage: Message = {
          type: 'error',
          content: response.error || 'Failed to process query',
          timestamp: new Date()
        };
        await storeConversationError(currentSessionId, response.error || 'Failed to process query');
        
        setMessages(prev => [...prev, errorMessage]);
        setLoading(false);
        return;
      }

      // Create AI response message with all the data
      const aiMessage: Message = {
        type: 'ai',
        content: response.explanation || 'Query executed successfully',
        sqlQuery: response.sql_query || undefined,
        data: response.results || [],
        timestamp: new Date(),
        executionTime: response.execution_time_ms,
        resultCount: response.result_count,
        chartConfig: response.chart_config || undefined
      };

      setMessages(prev => [...prev, aiMessage]);

      // Speak the explanation if available
      // if (response.explanation) {
      //   speakText(response.explanation);
      // }

    } catch (error) {
      const errorMessage: Message = {
        type: 'error',
        content: `Sorry, I encountered an error: ${error instanceof Error ? error.message : 'Unknown error'}. Please make sure the backend server is running.`,
        timestamp: new Date()
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  const updateChatSession = async (query: string) => {
    const exists = chatSessions.find(s => s.id === currentSessionId);
    if (exists) {
      setChatSessions(prev => prev.map(s =>
        s.id === currentSessionId
          ? { ...s, title: query.slice(0, 50), messageCount: (s as any).messageCount ? (s as any).messageCount + 1 : 1, timestamp: new Date() }
          : s
      ));
      return;
    }

    // Create session on the backend if it does not exist
    try {
      const created = await createChatSession(currentSessionId || `session-${Date.now()}`, query.slice(0, 50));
      setChatSessions(prev => [normalizeSession(created), ...prev]);
    } catch (e) {
      // Fallback to local session if backend fails
      const local = normalizeSession({ id: currentSessionId || `session-${Date.now()}`, title: query.slice(0, 50), created_at: new Date().toISOString(), updated_at: new Date().toISOString(), message_count: 1, is_active: true });
      setChatSessions(prev => [...prev, local as any]);
    }
  };

  const handleNewChat = async () => {
    const newId = `session-${Date.now()}`;
    setMessages([]);
    setShowHistory(false);

    try {
      const created = await createChatSession(newId, 'New chat');
      setChatSessions(prev => [normalizeSession(created), ...prev]);
      setCurrentSessionId(created.id);
    } catch (e) {
      // Fallback locally
      setChatSessions(prev => [...prev, normalizeSession({ id: newId, title: 'New chat', created_at: new Date().toISOString(), updated_at: new Date().toISOString(), message_count: 0, is_active: true }) as any]);
      setCurrentSessionId(newId);
    }
  };

  const handleSessionClick = async (sessionId: string) => {
    setCurrentSessionId(sessionId);
    setShowHistory(false);
    setHistoryLoading(true);

    try {
      const history = await getConversationHistory(sessionId);
      const mapped = history.messages.map(m => ({
        type: m.message_type === 'assistant' ? 'ai' : m.message_type === 'user' ? 'user' : 'error',
        content: m.content,
        timestamp: new Date(m.created_at),
        sqlQuery: m.sql_query || undefined,
        data: undefined,
        executionTime: m.execution_time_ms || undefined,
        resultCount: m.result_count || undefined,
        chartConfig: m.chart_config || undefined
      }));
      setMessages(mapped);
    } catch (e) {
      console.error('Failed to load conversation history', e);
      setMessages([]);
    } finally {
      setHistoryLoading(false);
    }
  };

  if (showConfig) {
    return (
      <ConfigPanel
        dbConfig={dbConfig}
        onConfigChange={setDbConfig}
        onContinue={() => setShowConfig(false)}
      />
    );
  }

  return (
    <div className="h-screen bg-gray-50 flex flex-col relative overflow-hidden">
      {/* Fixed Header */}
      <div className="fixed top-0 left-0 right-0 z-50">
        <Header
          onConfigClick={showConfig ? undefined : () => setShowConfig(true)}
          onHistoryClick={() => setShowHistory(!showHistory)}
          onNewChat={handleNewChat}
          backendStatus={backendStatus}
        />
      </div>

      {/* Chat History Sidebar */}
      <ChatHistory
        sessions={chatSessions}
        currentSessionId={currentSessionId}
        onSessionClick={handleSessionClick}
        onNewChat={handleNewChat}
        onClose={() => setShowHistory(false)}
        isOpen={showHistory}
      />

      {/* Main Content Area - with top padding for fixed header */}
      <div className="flex-1 flex flex-col pt-[73px] overflow-hidden relative">
        <MessageList
          messages={messages}
          loading={loading}
          historyLoading={historyLoading}
          showExamples={true} // re-enabled homepage suggestions
          messagesEndRef={messagesEndRef}
          onExampleClick={(example) => setInput(example)}
        />

        {/* Bottom input for active chats (always present) */}
        <InputArea
          input={input}
          onInputChange={setInput}
          onSubmit={processQuery}
          onMicClick={toggleListening}
          isListening={isListening}
          loading={loading}
        />
      </div>
    </div>
  );
}
