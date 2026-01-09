import React, { useMemo, useState } from 'react';

interface DataTableProps {
  data: Record<string, any>[];
  pageSize?: number;
}

export const DataTable: React.FC<DataTableProps> = ({ data, pageSize = 10 }) => {
  const [page, setPage] = useState(1);
  const totalPages = Math.max(1, Math.ceil((data?.length ?? 0) / pageSize));

  const pageData = useMemo(() => {
    if (!data || data.length === 0) return [] as Record<string, any>[];
    const start = (page - 1) * pageSize;
    return data.slice(start, start + pageSize);
  }, [data, page, pageSize]);

  if (!data || data.length === 0) {
    return <div className="text-gray-600">No data available</div>;
  }

  const onPrev = () => setPage(p => Math.max(1, p - 1));
  const onNext = () => setPage(p => Math.min(totalPages, p + 1));

  return (
    <div>
      <table className="min-w-full text-sm">
        <thead className="bg-gray-50">
          <tr>
            {Object.keys(data[0]).map(key => (
              <th key={key} className="px-3 py-2 text-left font-medium text-gray-700">
                {key}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {pageData.map((row, i) => (
            <tr key={i} className="border-t">
              {Object.values(row).map((val, j) => (
                <td key={j} className="px-3 py-2 text-gray-800">
                  {String(val)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>

      {totalPages > 1 && (
        <div className="mt-3 flex items-center justify-between text-sm text-gray-600">
          <div>
            Showing {(page - 1) * pageSize + 1} - {Math.min(page * pageSize, data.length)} of {data.length}
          </div>
          <div className="flex items-center gap-2">
            <button
              onClick={onPrev}
              disabled={page === 1}
              className="px-3 py-1 rounded-md bg-white border border-gray-200 text-gray-700 disabled:opacity-50"
            >
              Prev
            </button>
            <div className="px-2">Page {page} / {totalPages}</div>
            <button
              onClick={onNext}
              disabled={page === totalPages}
              className="px-3 py-1 rounded-md bg-white border border-gray-200 text-gray-700 disabled:opacity-50"
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  );
};
