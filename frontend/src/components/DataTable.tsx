import React from 'react';

interface DataTableProps {
  data: Record<string, any>[];
}

export const DataTable: React.FC<DataTableProps> = ({ data }) => {
  if (!data || data.length === 0) {
    return <div className="text-gray-600">No data available</div>;
  }

  return (
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
        {data.map((row, i) => (
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
  );
};
