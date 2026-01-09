import React from 'react';
import { Clock } from 'lucide-react';
import { Message } from '../types';
import { DataTable } from './DataTable';

// NOTE: Chart and table visualizations are disabled temporarily per UX request
// to only show concise, text-only responses (1–2 lines).


interface MessageBubbleProps {
  message: Message;
  onSpeak: () => void;
}

export const MessageBubble: React.FC<MessageBubbleProps> = ({ message, onSpeak }) => {
  // Graphical output disabled by product requirement: never show chart/table
  const shouldShowChart = false;

  // Concise content formatter: remove headings like "Key insight(s)", "Actionable recommendation(s)", etc.
  // and limit displayed text to up to two sentences (or truncate) to keep UI short.
  const conciseContent = (text?: string) => {
    if (!text) return '';
    // Remove common heading labels (e.g., "Key Insights:") but keep the following text
    text = text.replace(/(?:Key\s+Insights?|Key\s+Findings|Notable\s+Findings|Actionable\s+Recommendations|Recommendations|Analysis|Insights)[:-]*/gi, '');
    // Collapse whitespace and newlines
    text = text.replace(/\n+/g, ' ').replace(/\s+/g, ' ').trim();
    // Split into sentences and filter out unwanted sentences
    const sentences = text.split(/(?<=[.!?])\s+/);
    const filtered = sentences.filter(s => !/(key insight|notable finding|actionable|recommendation|insight)/i.test(s));
    let result = '';
    if (filtered.length >= 2) {
      result = filtered.slice(0,2).join(' ');
    } else if (filtered.length === 1) {
      result = filtered[0];
    } else {
      result = sentences.slice(0,2).join(' ');
    }
    if (result.length > 300) result = result.slice(0,297) + '...';
    return result;
  };

  // Detect explicit FMS workflows prompt (case-insensitive). If present, show full description and table.
  const isFMSWorkflows = (message.content || '').toLowerCase().includes('fms workflows') || /(active\s+fms\s+workflows)/i.test(message.content || '');
  const sanitizeSummaryHeading = (text?: string) => {
    if (!text) return '';
    return text.replace(/^###\s*Summary of the Data\s*/i, '').trim();
  };

  return (
    <div
      className={`flex ${message.type === 'user' ? 'justify-end' : 'justify-start'}`}
    >
      <div
        className={`max-w-4xl w-full rounded-2xl p-4 ${
          message.type === 'user'
            ? 'bg-gray-300 text-gray-800'
            : message.type === 'error'
            ? 'bg-red-100 text-red-800'
            : 'bg-white shadow-md'
        }`}
      >
        {message.type === 'ai' && (
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              {/* <MessageSquare className="w-5 h-5 text-blue-600" />
              <span className="font-semibold text-gray-800">Process AI HQ</span> */}
            </div>
            {message.executionTime !== undefined && (
              <div className="flex items-center gap-3 text-xs text-gray-500">
                {/* {message.resultCount !== undefined && (
                  <div className="flex items-center gap-1">
                    <Database className="w-3 h-3" />
                    <span>{message.resultCount} result{message.resultCount !== 1 ? 's' : ''}</span>
                  </div>
                )} */}
                <div className="flex items-center gap-1">
                  <Clock className="w-3 h-3" />
                  <span>{message.executionTime.toFixed(2)}ms</span>
                </div>
              </div>
            )}
          </div>
        )}



        {/* Description/Explanation - show full description (FMS workflows) or concise content; DataTable is shown for any message with data */}
        {message.content && (
          <div className={shouldShowChart && message.type === 'ai' ? "mt-4 pt-4 border-t border-gray-200" : ""}>
            {isFMSWorkflows ? (
              <div className="whitespace-pre-wrap text-gray-800 leading-relaxed">
                {sanitizeSummaryHeading(message.content)}
              </div>
            ) : (
              <div
                className="text-gray-800 leading-relaxed"
                style={{ display: '-webkit-box', WebkitLineClamp: 2 as any, WebkitBoxOrient: 'vertical' as any, overflow: 'hidden' }}
              >
                {conciseContent(message.content)}
              </div>
            )}
          </div>
        )}

        {/* Data Table - show whenever backend returned data */}
        {message.data && message.data.length > 0 && (
          <div className="mt-3 overflow-x-auto">
            <DataTable data={message.data} />
          </div>
        )}

        {/* SQL Query - Always collapsible */}
        {/* {message.sqlQuery && (
          <details className="mt-4 pt-3 border-t border-gray-200">
            <summary className="cursor-pointer text-sm font-medium text-gray-700 hover:text-gray-900 flex items-center gap-2">
              <Database className="w-4 h-4" />
              View SQL Query
            </summary>
            <pre className="mt-3 p-3 bg-gray-900 text-green-400 rounded-lg text-xs overflow-x-auto">
              {message.sqlQuery}
            </pre>
          </details>
        )} */}



        {/* Action Buttons */}
        {/* {message.type === 'ai' && (
          <div className="mt-3 pt-3 border-t border-gray-200 flex items-center gap-2">
            <button
              onClick={onSpeak}
              className="flex items-center gap-1 text-sm text-blue-600 hover:text-blue-700 transition"
            >
              <Volume2 className="w-4 h-4" />
              Read aloud
            </button>
          </div>
        )} */}
      </div>
    </div>
  );
};
