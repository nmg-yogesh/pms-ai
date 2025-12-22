import React from 'react';
import { Database } from 'lucide-react';

interface HeaderProps {
  onConfigClick: () => void;
}

export const Header: React.FC<HeaderProps> = ({ onConfigClick }) => {
  return (
    <div className="bg-white shadow-sm border-b p-4">
      <div className="max-w-4xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Database className="w-6 h-6 text-purple-600" />
          <h1 className="text-xl font-bold text-gray-800">AI Database Assistant</h1>
        </div>
        <button
          onClick={onConfigClick}
          className="text-sm text-purple-600 hover:text-purple-700"
        >
          Configure DB
        </button>
      </div>
    </div>
  );
};
