import React from 'react';
import { MessageSquare, Clock, X } from 'lucide-react';

export interface ChatSession {
  id: string;
  title: string;
  timestamp: Date;
  messageCount: number;
}

interface ChatHistoryProps {
  sessions: ChatSession[];
  currentSessionId?: string;
  onSessionClick: (sessionId: string) => void;
  onNewChat: () => void;
  onClose: () => void;
  isOpen: boolean;
} 

export const ChatHistory: React.FC<ChatHistoryProps> = ({
  sessions,
  currentSessionId,
  onSessionClick,
  onNewChat,
  onClose,
  isOpen
}) => {
  const formatTimestamp = (date: Date) => {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return 'Just now';
    if (minutes < 60) return `${minutes} min ago`;
    if (hours < 24) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    if (days < 7) return `${days} day${days > 1 ? 's' : ''} ago`;
    return date.toLocaleDateString();
  };

  const groupedSessions = React.useMemo(() => {
    const now = new Date();
    const today: ChatSession[] = [];
    const yesterday: ChatSession[] = [];
    const thisWeek: ChatSession[] = [];
    const older: ChatSession[] = [];

    sessions.forEach(session => {
      const diff = now.getTime() - session.timestamp.getTime();
      const days = Math.floor(diff / 86400000);

      if (days === 0) today.push(session);
      else if (days === 1) yesterday.push(session);
      else if (days < 7) thisWeek.push(session);
      else older.push(session);
    });

    return { today, yesterday, thisWeek, older };
  }, [sessions]);

  if (!isOpen) return null;

  return (
    <div className="fixed right-0 top-[73px] bottom-0 w-80 bg-white shadow-2xl z-40 flex flex-col">
      {/* Header */}
      <div className="p-4 border-b flex items-center justify-between">
        <h2 className="text-lg font-semibold text-gray-800">History Chats</h2>
        <button
          onClick={onClose}
          className="p-1 hover:bg-gray-100 rounded-lg transition"
        >
          <X className="w-5 h-5 text-gray-600" />
        </button>
      </div>

      {/* New Chat Button */}
      <div className="p-4 border-b">
        <button
          onClick={onNewChat}
          className="w-full py-2 px-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition flex items-center justify-center gap-2"
        >
          <MessageSquare className="w-4 h-4" />
          New Chat
        </button>
      </div>

      {/* Chat List */}
      <div className="flex-1 overflow-y-auto">
        {groupedSessions.today.length > 0 && (
          <div className="p-4">
            <h3 className="text-xs font-semibold text-gray-500 uppercase mb-2">Today</h3>
            {groupedSessions.today.map(session => (
              <ChatSessionItem
                key={session.id}
                session={session}
                isActive={session.id === currentSessionId}
                onClick={() => onSessionClick(session.id)}
                formatTimestamp={formatTimestamp}
              />
            ))}
          </div>
        )}

        {groupedSessions.yesterday.length > 0 && (
          <div className="p-4">
            <h3 className="text-xs font-semibold text-gray-500 uppercase mb-2">Yesterday</h3>
            {groupedSessions.yesterday.map(session => (
              <ChatSessionItem
                key={session.id}
                session={session}
                isActive={session.id === currentSessionId}
                onClick={() => onSessionClick(session.id)}
                formatTimestamp={formatTimestamp}
              />
            ))}
          </div>
        )}

        {groupedSessions.thisWeek.length > 0 && (
          <div className="p-4">
            <h3 className="text-xs font-semibold text-gray-500 uppercase mb-2">This Week</h3>
            {groupedSessions.thisWeek.map(session => (
              <ChatSessionItem
                key={session.id}
                session={session}
                isActive={session.id === currentSessionId}
                onClick={() => onSessionClick(session.id)}
                formatTimestamp={formatTimestamp}
              />
            ))}
          </div>
        )}

        {groupedSessions.older.length > 0 && (
          <div className="p-4">
            <h3 className="text-xs font-semibold text-gray-500 uppercase mb-2">Older</h3>
            {groupedSessions.older.map(session => (
              <ChatSessionItem
                key={session.id}
                session={session}
                isActive={session.id === currentSessionId}
                onClick={() => onSessionClick(session.id)}
                formatTimestamp={formatTimestamp}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

const ChatSessionItem: React.FC<{
  session: ChatSession;
  isActive: boolean;
  onClick: () => void;
  formatTimestamp: (date: Date) => string;
}> = ({ session, isActive, onClick, formatTimestamp }) => (
  <button
    onClick={onClick}
    className={`w-full text-left p-3 rounded-lg mb-2 transition ${
      isActive
        ? 'bg-blue-50 border border-blue-200'
        : 'hover:bg-gray-50 border border-transparent'
    }`}
  >
    <div className="flex items-start gap-2">
      <MessageSquare className={`w-4 h-4 mt-1 ${isActive ? 'text-blue-600' : 'text-gray-400'}`} />
      <div className="flex-1 min-w-0">
        <p className={`text-sm font-medium truncate ${isActive ? 'text-blue-900' : 'text-gray-900'}`}>
          {session.title}
        </p>
        <div className="flex items-center gap-2 mt-1">
          <Clock className="w-3 h-3 text-gray-400" />
          <span className="text-xs text-gray-500">{formatTimestamp(session.timestamp)}</span>
          <span className="text-xs text-gray-400">• {session.messageCount} chats</span>
        </div>
      </div>
    </div>
  </button>
);