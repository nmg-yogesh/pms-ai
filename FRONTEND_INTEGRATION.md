# 🎨 Frontend Integration Guide

This guide shows how to integrate the Agentic AI backend with your frontend application.

## 📦 Installation

### React/Next.js
```bash
npm install axios
# or
yarn add axios
```

## 🔧 API Client Setup

### Create API Client (`src/services/agenticApi.js`)

```javascript
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';
const API_PREFIX = '/api/v1';

class AgenticAPI {
  constructor() {
    this.client = axios.create({
      baseURL: `${API_BASE_URL}${API_PREFIX}`,
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  // Health check
  async healthCheck() {
    const response = await this.client.get('/health');
    return response.data;
  }

  // Process natural language query
  async query(queryText, options = {}) {
    const payload = {
      query: queryText,
      include_explanation: options.includeExplanation ?? true,
      speak_response: options.speakResponse ?? false,
      user_id: options.userId ?? null,
    };

    const response = await this.client.post('/agentic/query', payload);
    return response.data;
  }

  // Get example queries
  async getExamples() {
    const response = await this.client.get('/agentic/examples');
    return response.data;
  }

  // Validate SQL query
  async validateQuery(sqlQuery) {
    const response = await this.client.post('/agentic/validate-query', null, {
      params: { sql_query: sqlQuery },
    });
    return response.data;
  }
}

export default new AgenticAPI();
```

## 🎤 Voice Input Component

### React Component with Speech Recognition

```jsx
import React, { useState, useEffect } from 'react';
import agenticAPI from '../services/agenticApi';

const AgenticAssistant = () => {
  const [query, setQuery] = useState('');
  const [isListening, setIsListening] = useState(false);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Speech Recognition Setup
  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  const [recognition, setRecognition] = useState(null);

  useEffect(() => {
    if (SpeechRecognition) {
      const recognitionInstance = new SpeechRecognition();
      recognitionInstance.continuous = false;
      recognitionInstance.interimResults = false;
      recognitionInstance.lang = 'en-US';

      recognitionInstance.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        setQuery(transcript);
        setIsListening(false);
      };

      recognitionInstance.onerror = (event) => {
        console.error('Speech recognition error:', event.error);
        setIsListening(false);
      };

      recognitionInstance.onend = () => {
        setIsListening(false);
      };

      setRecognition(recognitionInstance);
    }
  }, []);

  const startListening = () => {
    if (recognition) {
      setIsListening(true);
      recognition.start();
    }
  };

  const stopListening = () => {
    if (recognition) {
      recognition.stop();
      setIsListening(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!query.trim()) return;

    setLoading(true);
    setError(null);

    try {
      const response = await agenticAPI.query(query, {
        includeExplanation: true,
        userId: 1, // Replace with actual user ID
      });

      setResult(response);

      // Optional: Text-to-Speech
      if (response.explanation && 'speechSynthesis' in window) {
        const utterance = new SpeechSynthesisUtterance(response.explanation);
        window.speechSynthesis.speak(utterance);
      }
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="agentic-assistant">
      <h2>🤖 AI Assistant</h2>

      <form onSubmit={handleSubmit}>
        <div className="input-group">
          <textarea
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Ask about help tickets, workflows, users..."
            rows={3}
            disabled={loading}
          />

          <div className="button-group">
            <button
              type="button"
              onClick={isListening ? stopListening : startListening}
              className={isListening ? 'recording' : ''}
              disabled={loading}
            >
              {isListening ? '🔴 Stop' : '🎤 Speak'}
            </button>

            <button type="submit" disabled={loading || !query.trim()}>
              {loading ? '⏳ Processing...' : '🚀 Ask AI'}
            </button>
          </div>
        </div>
      </form>

      {error && (
        <div className="error">
          ❌ Error: {error}
        </div>
      )}

      {result && result.success && (
        <div className="results">
          <div className="explanation">
            <h3>💡 Explanation</h3>
            <p>{result.explanation}</p>
          </div>

          <div className="metadata">
            <span>📊 {result.result_count} results</span>
            <span>⏱️ {result.execution_time_ms.toFixed(2)}ms</span>
          </div>

          {result.results && result.results.length > 0 && (
            <div className="data-table">
              <h3>📋 Results</h3>
              <table>
                <thead>
                  <tr>
                    {Object.keys(result.results[0]).map((key) => (
                      <th key={key}>{key}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {result.results.slice(0, 10).map((row, idx) => (
                    <tr key={idx}>
                      {Object.values(row).map((value, i) => (
                        <td key={i}>{String(value)}</td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          <details className="sql-query">
            <summary>🔍 View SQL Query</summary>
            <pre>{result.sql_query}</pre>
          </details>
        </div>
      )}
    </div>
  );
};

export default AgenticAssistant;
```

## 🎨 CSS Styling

```css
.agentic-assistant {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.input-group {
  margin-bottom: 20px;
}

textarea {
  width: 100%;
  padding: 12px;
  border: 2px solid #ddd;
  border-radius: 8px;
  font-size: 16px;
  resize: vertical;
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}

button {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s;
}

button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.recording {
  background-color: #ff4444;
  color: white;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}

.results {
  margin-top: 20px;
  padding: 20px;
  background: #f5f5f5;
  border-radius: 8px;
}

.explanation {
  background: white;
  padding: 15px;
  border-radius: 8px;
  margin-bottom: 15px;
}

.data-table {
  overflow-x: auto;
  margin-top: 15px;
}

table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

th, td {
  padding: 12px;
  text-align: left;
  border-bottom: 1px solid #ddd;
}

th {
  background-color: #4CAF50;
  color: white;
}

.error {
  padding: 15px;
  background-color: #ffebee;
  color: #c62828;
  border-radius: 8px;
  margin-top: 15px;
}
```

## 🚀 Usage Example

```jsx
import React from 'react';
import AgenticAssistant from './components/AgenticAssistant';

function App() {
  return (
    <div className="App">
      <header>
        <h1>PMS Agentic AI</h1>
      </header>
      <main>
        <AgenticAssistant />
      </main>
    </div>
  );
}

export default App;
```

## 📱 Environment Variables

Create `.env` file in your frontend project:

```env
REACT_APP_API_URL=http://localhost:8000
```

## ✅ Testing

```javascript
// Test the API connection
import agenticAPI from './services/agenticApi';

async function testAPI() {
  try {
    const health = await agenticAPI.healthCheck();
    console.log('Health:', health);

    const result = await agenticAPI.query('Show me all active workflows');
    console.log('Result:', result);
  } catch (error) {
    console.error('Error:', error);
  }
}

testAPI();
```

## 🎯 Next Steps

1. Customize the UI to match your design system
2. Add authentication/authorization
3. Implement query history
4. Add favorite queries
5. Create dashboard with analytics

