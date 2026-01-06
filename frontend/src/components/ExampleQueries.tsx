import React, { useState, useEffect } from 'react';
import { Ticket, Workflow, Users, FolderKanban } from 'lucide-react';
import { EXAMPLE_QUERIES, EXAMPLE_QUERIES_BY_CATEGORY } from '../constants';
import { getExampleQueries } from '../services/openaiService';

interface ExampleQueriesProps {
  onExampleClick: (example: string) => void;
}

export const ExampleQueries: React.FC<ExampleQueriesProps> = ({ onExampleClick }) => {
  const [examples, setExamples] = useState(EXAMPLE_QUERIES);
  const [categorizedExamples, setCategorizedExamples] = useState(EXAMPLE_QUERIES_BY_CATEGORY);
  const [showCategories, setShowCategories] = useState(false);

  useEffect(() => {
    // Try to fetch examples from backend
    const fetchExamples = async () => {
      try {
        const backendExamples = await getExampleQueries();
        setCategorizedExamples(backendExamples);

        // Flatten all examples for simple view
        const allExamples = [
          ...backendExamples.hit_tickets.slice(0, 2),
          ...backendExamples.fms_workflows.slice(0, 2),
          ...backendExamples.users.slice(0, 1),
          ...backendExamples.general?.slice(0, 1) || []
        ];
        setExamples(allExamples);
      } catch (error) {
        // Use default examples if backend fetch fails
        console.log('Using default examples');
      }
    };

    fetchExamples();
  }, []);

  const categoryIcons = {
    hit_tickets: <Ticket className="w-4 h-4" />,
    fms_workflows: <Workflow className="w-4 h-4" />,
    users: <Users className="w-4 h-4" />,
    projects: <FolderKanban className="w-4 h-4" />
  };

  const categoryLabels = {
    hit_tickets: 'Help Tickets',
    fms_workflows: 'Workflows',
    users: 'Users & Departments',
    projects: 'Projects & Tasks'
  };

  return (
    <div className="text-center py-16">
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-gray-800 mb-3">
          Ask Process AI HQ anything
        </h2>
        <p className="text-gray-500 text-lg">
          Start Asking for e.g. how many HIT I have, Show most pending task member, create<br />
          report of all IT Department Members, etc
        </p>
      </div>

      <div className="mb-6">
        <button
          onClick={() => setShowCategories(!showCategories)}
          className="text-sm text-blue-600 hover:text-blue-700 font-medium"
        >
          {showCategories ? 'Show less' : 'Browse by category'}
        </button>
      </div>

      {!showCategories ? (
        <div className="flex flex-wrap gap-3 justify-center max-w-3xl mx-auto">
          {examples.map((example, idx) => (
            <button
              key={idx}
              onClick={() => onExampleClick(example)}
              className="px-5 py-2.5 bg-white border-2 border-gray-200 text-gray-700 rounded-lg hover:border-blue-500 hover:text-blue-700 hover:shadow-md transition text-sm font-medium"
            >
              {example}
            </button>
          ))}
        </div>
      ) : (
        <div className="max-w-4xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-4">
          {Object.entries(categorizedExamples).map(([category, queries]) => (
            <div key={category} className="bg-white rounded-xl p-5 shadow-sm border-2 border-gray-100 hover:border-blue-200 transition">
              <div className="flex items-center gap-2 mb-4">
                <div className="p-2 bg-blue-50 rounded-lg">
                  {categoryIcons[category as keyof typeof categoryIcons]}
                </div>
                <h3 className="font-semibold text-gray-800">
                  {categoryLabels[category as keyof typeof categoryLabels] || category}
                </h3>
              </div>
              <div className="space-y-2">
                {queries.slice(0, 4).map((query: string, idx: number) => (
                  <button
                    key={idx}
                    onClick={() => onExampleClick(query)}
                    className="w-full text-left px-4 py-2.5 bg-gray-50 hover:bg-blue-50 rounded-lg text-sm text-gray-700 hover:text-blue-700 transition border border-transparent hover:border-blue-200"
                  >
                    {query}
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};
