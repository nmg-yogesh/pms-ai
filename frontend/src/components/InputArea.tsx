import React from 'react';
import { Mic, Send } from 'lucide-react';

interface InputAreaProps {
  input: string;
  onInputChange: (value: string) => void;
  onSubmit: () => void;
  onMicClick: () => void;
  isListening: boolean;
  loading: boolean;
  centered?: boolean;
}

export const InputArea: React.FC<InputAreaProps> = ({
  input,
  onInputChange,
  onSubmit,
  onMicClick,
  isListening,
  loading,
  centered = false
}) => {
  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !loading) {
      onSubmit();
    }
  };

  return (
    <div className={`bg-white border p-4 shadow-lg ${centered ? 'rounded-2xl border-gray-200' : 'rounded-xl border-gray-200'}`}>
      <div className="max-w-4xl mx-auto">
        {centered && (
          <div className="text-xl text-gray-400 mb-2 text-center">Ask anything related to Process HQ</div>
        )}

        <div className="relative">
          <input
            type="text"
            value={input}
            onChange={(e) => onInputChange(e.target.value)}
            onKeyPress={handleKeyPress}
            disabled={loading}
            className="outline-none w-full px-4 py-4 pr-24 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-50 transition text-gray-800 placeholder-gray-400"
          />

          <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-2">
            <button
              onClick={onMicClick}
              disabled={loading}
              className={`relative p-2 rounded-lg transition ${
                isListening
                  ? 'bg-gray-100 text-red-600 hover:bg-gray-200'
                  : 'text-gray-400 hover:text-blue-600 hover:bg-blue-50'
              } disabled:opacity-50`}
              title={isListening ? 'Stop recording' : 'Voice input'}
            >
              {/* Listening indicator: three bouncing dots — replaces mic icon while active */}
              {isListening ? (
                <div className="flex items-center gap-1">
                  <span className="h-2 w-2 rounded-full bg-gray-600 animate-bounce" style={{ animationDelay: '0s' }} />
                  <span className="h-2 w-2 rounded-full bg-gray-600 animate-bounce" style={{ animationDelay: '0.12s' }} />
                  <span className="h-2 w-2 rounded-full bg-gray-600 animate-bounce" style={{ animationDelay: '0.24s' }} />
                </div>
              ) : (
                <Mic className="w-5 h-5" />
              )}
            </button>

            <button
              onClick={onSubmit}
              disabled={loading || !input.trim()}
              className="p-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition"
              title="Send message"
            >
              <Send className="w-4 h-4" />
            </button>
          </div>
        </div>

      </div>
    </div>
  );
};
