import React, { useState } from 'react';
import { MessageSquare, Volume2, Clock, Database, BarChart3, Table } from 'lucide-react';
import { Message } from '../types';
import { DataTable } from './DataTable';
import { ChartVisualization } from './ChartVisualization';

interface MessageBubbleProps {
  message: Message;
  onSpeak: () => void;
}

export const MessageBubble: React.FC<MessageBubbleProps> = ({ message, onSpeak }) => {
  const [showChart, setShowChart] = useState(true);
  const hasData = message.data && message.data.length > 0;

  // Show chart/table toggle ONLY if backend provides a chart config
  // This respects backend's decision on whether data should be visualized
  // List queries (e.g., "list all employees") will return chartConfig: null
  const shouldShowChart = hasData && message.chartConfig && message.chartConfig.chart_type;

  return (
    <div
      className={`flex ${message.type === 'user' ? 'justify-end' : 'justify-start'}`}
    >
      <div
        className={`max-w-4xl w-full rounded-lg p-4 ${
          message.type === 'user'
            ? 'bg-blue-600 text-white'
            : message.type === 'error'
            ? 'bg-red-100 text-red-800'
            : 'bg-white shadow-md'
        }`}
      >
        {message.type === 'ai' && (
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <MessageSquare className="w-5 h-5 text-blue-600" />
              <span className="font-semibold text-gray-800">Process AI HQ</span>
            </div>
            {message.executionTime !== undefined && (
              <div className="flex items-center gap-3 text-xs text-gray-500">
                {message.resultCount !== undefined && (
                  <div className="flex items-center gap-1">
                    <Database className="w-3 h-3" />
                    <span>{message.resultCount} result{message.resultCount !== 1 ? 's' : ''}</span>
                  </div>
                )}
                <div className="flex items-center gap-1">
                  <Clock className="w-3 h-3" />
                  <span>{message.executionTime.toFixed(2)}ms</span>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Chart/Table Visualization - SHOWN FIRST for AI responses with data */}
        {shouldShowChart && message.type === 'ai' && (
          <div className="mb-6">
            <div className="flex items-center gap-2 mb-3">
              <button
                onClick={() => setShowChart(true)}
                className={`px-3 py-1.5 rounded-lg text-sm font-medium transition ${
                  showChart
                    ? 'bg-blue-100 text-blue-700'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                <BarChart3 className="w-4 h-4 inline mr-1" />
                Chart
              </button>
              <button
                onClick={() => setShowChart(false)}
                className={`px-3 py-1.5 rounded-lg text-sm font-medium transition ${
                  !showChart
                    ? 'bg-blue-100 text-blue-700'
                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }`}
              >
                <Table className="w-4 h-4 inline mr-1" />
                Table
              </button>
            </div>

            {showChart ? (
              <ChartVisualization
                data={message.data!}
                chartType="auto"
                chartConfig={message.chartConfig}
              />
            ) : (
              <div className="overflow-x-auto">
                <DataTable data={message.data!} />
              </div>
            )}
          </div>
        )}

        {/* Description/Explanation - SHOWN AFTER chart (or standalone if no chart) */}
        {message.content && (
          <div className={shouldShowChart && message.type === 'ai' ? "mt-4 pt-4 border-t border-gray-200" : ""}>
            {shouldShowChart && message.type === 'ai' && (
              <div className="flex items-center gap-2 mb-2">
                <MessageSquare className="w-4 h-4 text-gray-600" />
                <span className="text-sm font-semibold text-gray-700">Analysis & Insights</span>
              </div>
            )}
            <div className="whitespace-pre-wrap text-gray-800 leading-relaxed">
              {message.content}
            </div>
          </div>
        )}

        {/* SQL Query - Always collapsible */}
        {message.sqlQuery && (
          <details className="mt-4 pt-3 border-t border-gray-200">
            <summary className="cursor-pointer text-sm font-medium text-gray-700 hover:text-gray-900 flex items-center gap-2">
              <Database className="w-4 h-4" />
              View SQL Query
            </summary>
            <pre className="mt-3 p-3 bg-gray-900 text-green-400 rounded-lg text-xs overflow-x-auto">
              {message.sqlQuery}
            </pre>
          </details>
        )}

        {/* Raw Data Table - Only show if not already showing chart/table above */}
        {hasData && !shouldShowChart && (
          <details className="mt-4 pt-3 border-t border-gray-200">
            <summary className="cursor-pointer text-sm font-medium text-gray-700 hover:text-gray-900 flex items-center gap-2">
              <Table className="w-4 h-4" />
              View Data Table
            </summary>
            <div className="mt-3 overflow-x-auto">
              <DataTable data={message.data!} />
            </div>
          </details>
        )}

        {/* Action Buttons */}
        {message.type === 'ai' && (
          <div className="mt-3 pt-3 border-t border-gray-200 flex items-center gap-2">
            <button
              onClick={onSpeak}
              className="flex items-center gap-1 text-sm text-blue-600 hover:text-blue-700 transition"
            >
              <Volume2 className="w-4 h-4" />
              Read aloud
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
