import React from 'react';
import { History, RotateCcw, CheckCircle, XCircle } from 'lucide-react';

interface HeaderProps {
  onConfigClick?: () => void;
  onHistoryClick?: () => void;
  onNewChat?: () => void;
  backendStatus?: {
    connected: boolean;
    message: string;
  };
}

export const Header: React.FC<HeaderProps> = ({
  onConfigClick,
  onHistoryClick,
  onNewChat,
  backendStatus
}) => {
  return (
    <div className="bg-white shadow-sm border-b p-4">
      <div className="max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <img
            src="https://nmgtempbucket-us-east-1.s3.amazonaws.com/uploads/6808e5741ed19.png"
            alt="Process HQ Logo"
            className="h-8 w-auto"
          />
          <div className="border-l border-gray-300 pl-3">
            <h1 className="text-xl font-bold text-gray-800">PROCESS HQ</h1>
            <p className="text-xs text-gray-500">Ask Process AI HQ anything</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          {backendStatus && (
            <div className="flex items-center gap-2">
              {backendStatus.connected ? (
                <>
                  <CheckCircle className="w-4 h-4 text-green-500" />
                  <span className="text-xs text-green-600 hidden md:inline">{backendStatus.message}</span>
                </>
              ) : (
                <>
                  <XCircle className="w-4 h-4 text-red-500" />
                  <span className="text-xs text-red-600 hidden md:inline">{backendStatus.message}</span>
                </>
              )}
            </div>
          )}

          {onNewChat && (
            <button
              onClick={onNewChat}
              className="p-2 hover:bg-gray-100 rounded-lg transition flex items-center gap-2"
              title="New Chat"
            >
              <RotateCcw className="w-5 h-5 text-gray-600" />
            </button>
          )}

          {onHistoryClick && (
            <button
              onClick={onHistoryClick}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition flex items-center gap-2"
            >
              <History className="w-4 h-4" />
              <span className="hidden md:inline">New Chat</span>
            </button>
          )}
        </div>
      </div>
    </div>
  );
};
