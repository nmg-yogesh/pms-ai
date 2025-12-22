import React from 'react';
import { Sparkles } from 'lucide-react';
import { EXAMPLE_QUERIES } from '../constants';

interface ExampleQueriesProps {
  onExampleClick: (example: string) => void;
}

export const ExampleQueries: React.FC<ExampleQueriesProps> = ({ onExampleClick }) => {
  return (
    <div className="text-center py-12">
      <Sparkles className="w-16 h-16 text-purple-400 mx-auto mb-4" />
      <h2 className="text-2xl font-bold text-gray-800 mb-2">
        Ask me anything about your database
      </h2>
      <p className="text-gray-600 mb-6">
        Use your voice or type your question in plain English
      </p>
      <div className="flex flex-wrap gap-2 justify-center">
        {EXAMPLE_QUERIES.map((example, idx) => (
          <button
            key={idx}
            onClick={() => onExampleClick(example)}
            className="px-4 py-2 bg-purple-100 text-purple-700 rounded-full hover:bg-purple-200 transition text-sm"
          >
            {example}
          </button>
        ))}
      </div>
    </div>
  );
};
