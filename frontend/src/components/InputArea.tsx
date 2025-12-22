import React from 'react';
import { Mic, MicOff, Play } from 'lucide-react';

interface InputAreaProps {
  input: string;
  onInputChange: (value: string) => void;
  onSubmit: () => void;
  onMicClick: () => void;
  isListening: boolean;
  loading: boolean;
}

export const InputArea: React.FC<InputAreaProps> = ({
  input,
  onInputChange,
  onSubmit,
  onMicClick,
  isListening,
  loading
}) => {
  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !loading) {
      onSubmit();
    }
  };

  return (
    <div className="bg-white border-t p-4">
      <div className="max-w-4xl mx-auto">
        <div className="flex gap-2">
          <button
            onClick={onMicClick}
            disabled={loading}
            className={`p-3 rounded-lg transition ${
              isListening
                ? 'bg-red-600 hover:bg-red-700 text-white'
                : 'bg-purple-100 hover:bg-purple-200 text-purple-600'
            } disabled:opacity-50`}
          >
            {isListening ? <MicOff className="w-6 h-6" /> : <Mic className="w-6 h-6" />}
          </button>

          <input
            type="text"
            value={input}
            onChange={(e) => onInputChange(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Ask a question about your database..."
            disabled={loading}
            className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent disabled:bg-gray-100"
          />

          <button
            onClick={onSubmit}
            disabled={loading || !input.trim()}
            className="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition flex items-center gap-2"
          >
            <Play className="w-5 h-5" />
            Ask
          </button>
        </div>
      </div>
    </div>
  );
};
