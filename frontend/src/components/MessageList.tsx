import React from 'react';
import { Loader2 } from 'lucide-react';
import { Message } from '../types';
import { speakText } from '../utils/speechUtils';
import { MessageBubble } from './MessageBubble';
import { ExampleQueries } from './ExampleQueries';

interface MessageListProps {
  messages: Message[];
  loading: boolean;
  messagesEndRef: React.RefObject<HTMLDivElement>;
  onExampleClick: (example: string) => void;
}

export const MessageList: React.FC<MessageListProps> = ({
  messages,
  loading,
  messagesEndRef,
  onExampleClick
}) => {
  return (
    <div className="flex-1 overflow-y-auto p-6">
      <div className="max-w-4xl mx-auto space-y-4">
        {messages.length === 0 && (
          <ExampleQueries onExampleClick={onExampleClick} />
        )}

        {messages.map((msg, idx) => (
          <MessageBubble
            key={idx}
            message={msg}
            onSpeak={() => speakText(msg.content)}
          />
        ))}

        {loading && (
          <div className="flex justify-start">
            <div className="bg-white shadow-md rounded-lg p-4 flex items-center gap-3">
              <Loader2 className="w-5 h-5 text-purple-600 animate-spin" />
              <span className="text-gray-700">Processing your question...</span>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>
    </div>
  );
};
