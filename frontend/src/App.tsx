import React, { useState } from 'react';
import { Message, DBConfig } from './types';
import {
  ConfigPanel,
  Header,
  MessageList,
  InputArea
} from './components';
import { useAutoScroll } from './hooks';
import { simulateQueryExecution } from './utils/querySimulator';
import { speakText } from './utils/speechUtils';
import { convertNaturalLanguageToSQL, generateExplanation } from './services/openaiService';

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
  const [showConfig, setShowConfig] = useState(true);
  const [isListening, setIsListening] = useState(false);

  const messagesEndRef = useAutoScroll([messages]);

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

    try {
      // Step 1: Convert natural language to SQL
      const sqlQuery = await convertNaturalLanguageToSQL(currentInput);

      // Step 2: Execute the SQL query on the backend Postgres and persist results
      const execResp = await fetch(`${process.env.REACT_APP_API_URL || 'http://localhost:8000/api/v1/'}/api/execute-sql`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sql: sqlQuery, persist: true }),
      });

      const execData = await execResp.json();
      if (!execResp.ok) {
        // If invalid attributes were referenced, show a friendly message
        const invalid = execData.invalid || [];
        const errMsg = invalid.length > 0
          ? `The generated SQL references attributes that don't exist: ${invalid.join(', ')}. I won't run those. Please refine your question.`
          : execData.error || 'Failed to execute SQL on server';

        const errorMessage: Message = {
          type: 'error',
          content: errMsg,
          timestamp: new Date()
        };
        setMessages(prev => [...prev, errorMessage]);
        setLoading(false);
        return;
      }
      const queryResult = {
        success: execData.ok,
        data: execData.rows || [],
        rowCount: execData.rowCount || (execData.rows ? execData.rows.length : 0),
      };

      // Step 3: Generate explanation
      const explanation = await generateExplanation(
        currentInput,
        sqlQuery,
        queryResult.data
      );

      const aiMessage: Message = {
        type: 'ai',
        content: explanation,
        sqlQuery,
        data: queryResult.data,
        timestamp: new Date()
      };

      setMessages(prev => [...prev, aiMessage]);
      speakText(explanation);

    } catch (error) {
      const errorMessage: Message = {
        type: 'error',
        content: `Sorry, I encountered an error: ${error instanceof Error ? error.message : 'Unknown error'}`,
        timestamp: new Date()
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setLoading(false);
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
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50 flex flex-col">
      <Header onConfigClick={() => setShowConfig(true)} />
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
  );
}
