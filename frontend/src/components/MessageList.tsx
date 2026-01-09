import React from 'react';
import { Loader2 } from 'lucide-react';
import { Message } from '../types';
import { speakText } from '../utils/speechUtils';
import { MessageBubble } from './MessageBubble';
import { ExampleQueries } from './ExampleQueries';

interface MessageListProps {
  messages: Message[];
  loading: boolean;
  historyLoading?: boolean;
  showExamples?: boolean; // when false, example suggestions are hidden
  messagesEndRef: React.RefObject<HTMLDivElement>;
  onExampleClick: (example: string) => void;
}

export const MessageList: React.FC<MessageListProps> = ({
  messages,
  loading,
  historyLoading,
  showExamples = false,
  messagesEndRef,
  onExampleClick
}) => {
  if (historyLoading) {
    return (
      <div className="flex-1 flex items-center justify-center p-6 bg-white">
        <div className="bg-white shadow-md rounded-lg p-6 flex items-center gap-3 border border-gray-200">
          <Loader2 className="w-6 h-6 text-blue-600 animate-spin" />
          <span className="text-gray-700">Loading chat history...</span>
        </div>
      </div>
    );
  }

  return (
    <div className="flex-1 overflow-y-auto p-6 bg-white">
      <div className="max-w-5xl mx-auto space-y-6">
        {/* Example suggestions hidden by default for a cleaner design.
            To re-enable, pass `showExamples` prop as true from the parent.
        */}
        {showExamples && messages.length === 0 && (
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
            <div className="bg-white shadow-md rounded-lg p-4 flex items-center gap-3 border border-gray-200">
              <Loader2 className="w-5 h-5 text-blue-600 animate-spin" />
              <span className="text-gray-700">Thinking...</span>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>
    </div>
  );
};
