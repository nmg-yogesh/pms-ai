import React from 'react';
import { Database } from 'lucide-react';
import { DBConfig } from '../types';
import { CONFIG_DISCLAIMER, DEMO_MESSAGE } from '../constants';

interface ConfigPanelProps {
  dbConfig: DBConfig;
  onConfigChange: (config: DBConfig) => void;
  onContinue: () => void;
}

export const ConfigPanel: React.FC<ConfigPanelProps> = ({
  dbConfig,
  onConfigChange,
  onContinue
}) => {
  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50 p-6 flex items-center justify-center">
      <div className="bg-white rounded-xl shadow-xl p-8 max-w-2xl w-full">
        <div className="flex items-center gap-3 mb-6">
          <Database className="w-8 h-8 text-purple-600" />
          <h1 className="text-3xl font-bold text-gray-800">AI Database Assistant</h1>
        </div>

        <div className="mb-6">
          <h2 className="text-xl font-semibold mb-4">Database Configuration</h2>
          <p className="text-sm text-gray-600 mb-4">{CONFIG_DISCLAIMER}</p>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Host</label>
              <input
                type="text"
                value={dbConfig.host}
                onChange={(e) => onConfigChange({...dbConfig, host: e.target.value})}
                placeholder="localhost"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Database Name</label>
              <input
                type="text"
                value={dbConfig.database}
                onChange={(e) => onConfigChange({...dbConfig, database: e.target.value})}
                placeholder="mydb"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Username</label>
              <input
                type="text"
                value={dbConfig.user}
                onChange={(e) => onConfigChange({...dbConfig, user: e.target.value})}
                placeholder="root"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Password</label>
              <input
                type="password"
                value={dbConfig.password}
                onChange={(e) => onConfigChange({...dbConfig, password: e.target.value})}
                placeholder="••••••••"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500"
              />
            </div>
          </div>
        </div>

        <button
          onClick={onContinue}
          className="w-full bg-purple-600 text-white py-3 rounded-lg font-medium hover:bg-purple-700 transition"
        >
          Continue to Assistant
        </button>

        <div className="mt-6 p-4 bg-amber-50 border border-amber-200 rounded-lg text-sm text-amber-800">
          <strong>Demo Mode:</strong> {DEMO_MESSAGE}
        </div>
      </div>
    </div>
  );
};
