import { QueryResult } from '../types';

export const simulateQueryExecution = (sqlQuery: string): QueryResult => {
  // Simulated response based on query type
  if (sqlQuery.toLowerCase().includes('count')) {
    return {
      success: true,
      data: [{ count: 42 }],
      rowCount: 1
    };
  } else if (sqlQuery.toLowerCase().includes('sum') || sqlQuery.toLowerCase().includes('total')) {
    return {
      success: true,
      data: [{ total: 125000 }],
      rowCount: 1
    };
  } else if (sqlQuery.toLowerCase().includes('top') || sqlQuery.toLowerCase().includes('limit')) {
    return {
      success: true,
      data: [
        { name: 'Product A', value: 5000 },
        { name: 'Product B', value: 4500 },
        { name: 'Product C', value: 4200 },
      ],
      rowCount: 3
    };
  } else {
    return {
      success: true,
      data: [
        { id: 1, name: 'John Doe', email: 'john@example.com', total_orders: 5 },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com', total_orders: 8 },
      ],
      rowCount: 2
    };
  }
};
