import React from 'react';
import { MessageSquare, Volume2 } from 'lucide-react';
import { Message } from '../types';
import { DataTable } from './DataTable';

interface MessageBubbleProps {
  message: Message;
  onSpeak: () => void;
}

export const MessageBubble: React.FC<MessageBubbleProps> = ({ message, onSpeak }) => {
  return (
    <div
      className={`flex ${message.type === 'user' ? 'justify-end' : 'justify-start'}`}
    >
      <div
        className={`max-w-3xl rounded-lg p-4 ${
          message.type === 'user'
            ? 'bg-purple-600 text-white'
            : message.type === 'error'
            ? 'bg-red-100 text-red-800'
            : 'bg-white shadow-md'
        }`}
      >
        {message.type === 'ai' && (
          <div className="flex items-center gap-2 mb-2">
            <MessageSquare className="w-5 h-5 text-purple-600" />
            <span className="font-semibold text-gray-800">AI Assistant</span>
          </div>
        )}

        <div className="whitespace-pre-wrap">{message.content}</div>

        {message.sqlQuery && (
          <details className="mt-3 pt-3 border-t border-gray-200">
            <summary className="cursor-pointer text-sm text-gray-600 hover:text-gray-800">
              View SQL Query
            </summary>
            <pre className="mt-2 p-2 bg-gray-900 text-green-400 rounded text-xs overflow-x-auto">
              {message.sqlQuery}
            </pre>
          </details>
        )}

        {message.data && message.data.length > 0 && (
          <details className="mt-3 pt-3 border-t border-gray-200">
            <summary className="cursor-pointer text-sm text-gray-600 hover:text-gray-800">
              View Raw Data
            </summary>
            <div className="mt-2 overflow-x-auto">
              <DataTable data={message.data} />
            </div>
          </details>
        )}

        {message.type === 'ai' && (
          <button
            onClick={onSpeak}
            className="mt-2 flex items-center gap-1 text-sm text-purple-600 hover:text-purple-700"
          >
            <Volume2 className="w-4 h-4" />
            Read aloud
          </button>
        )}
      </div>
    </div>
  );
};
