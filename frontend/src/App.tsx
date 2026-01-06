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
import { processAgenticQuery, checkHealth } from './services/openaiService';

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

  const messagesEndRef = useAutoScroll([messages]);

  // Check backend health on mount
  useEffect(() => {
    const checkBackendHealth = async () => {
      try {
        const health = await checkHealth();
        if (health.status === 'healthy' && health.database_connected && health.openai_configured) {
          setBackendStatus({
            connected: true,
            message: `Connected to PMS AI v${health.version}`
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

    // Update chat session
    updateChatSession(currentInput);

    try {
      // Use the unified backend API that handles everything:
      // 1. Natural language to SQL conversion
      // 2. Query validation
      // 3. Database execution
      // 4. Result analysis
      // 5. Natural language explanation
      const response = await processAgenticQuery(currentInput, undefined, true);

      if (!response.success) {
        const errorMessage: Message = {
          type: 'error',
          content: response.error || 'Failed to process query',
          timestamp: new Date()
        };
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

  const updateChatSession = (query: string) => {
    setChatSessions(prev => {
      const existingSession = prev.find(s => s.id === currentSessionId);
      if (existingSession) {
        return prev.map(s =>
          s.id === currentSessionId
            ? { ...s, title: query.slice(0, 50), messageCount: s.messageCount + 1, timestamp: new Date() }
            : s
        );
      } else {
        return [...prev, {
          id: currentSessionId,
          title: query.slice(0, 50),
          timestamp: new Date(),
          messageCount: 1
        }];
      }
    });
  };

  const handleNewChat = () => {
    setMessages([]);
    setCurrentSessionId(`session-${Date.now()}`);
    setShowHistory(false);
  };

  const handleSessionClick = (sessionId: string) => {
    setCurrentSessionId(sessionId);
    // In a real app, you'd load messages for this session
    setMessages([]);
    setShowHistory(false);
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
      <div className="flex-1 flex flex-col pt-[73px] overflow-hidden">
        <MessageList
          messages={messages}
          loading={loading}
          messagesEndRef={messagesEndRef}
          onExampleClick={(example) => setInput(example)}
        />

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
