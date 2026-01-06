import React from 'react';
import { Mic, MicOff, Send } from 'lucide-react';

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
    <div className="bg-white border-t p-4 shadow-lg">
      <div className="max-w-4xl mx-auto">
        <div className="relative">
          <input
            type="text"
            value={input}
            onChange={(e) => onInputChange(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Start Asking for e.g. how many HIT I have, Show most pending task member, Create report of all IT Department Members, etc"
            disabled={loading}
            className="w-full px-4 py-4 pr-24 border-2 border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 disabled:bg-gray-50 transition text-gray-800 placeholder-gray-400"
          />

          <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-2">
            <button
              onClick={onMicClick}
              disabled={loading}
              className={`p-2 rounded-lg transition ${
                isListening
                  ? 'bg-red-100 text-red-600 hover:bg-red-200'
                  : 'text-gray-400 hover:text-blue-600 hover:bg-blue-50'
              } disabled:opacity-50`}
              title={isListening ? 'Stop recording' : 'Voice input'}
            >
              {isListening ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
            </button>

            <button
              onClick={onSubmit}
              disabled={loading || !input.trim()}
              className="p-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition"
              title="Send message"
            >
              <Send className="w-5 h-5" />
            </button>
          </div>
        </div>

        <p className="text-xs text-gray-400 mt-2 text-center">
          Ask anything related to Process HQ
        </p>
      </div>
    </div>
  );
};
