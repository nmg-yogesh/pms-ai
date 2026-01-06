export interface ChartConfig {
  chart_type: 'bar' | 'stacked_bar' | 'pie' | 'line' | 'doughnut';
  x_axis?: string;
  y_axis?: string[];
  title?: string;
  description?: string;
  stacked_keys?: string[];
  colors?: Record<string, string>;
}

export interface Message {
  type: 'user' | 'ai' | 'error';
  content: string;
  timestamp: Date;
  sqlQuery?: string;
  data?: Record<string, any>[];
  executionTime?: number;
  resultCount?: number;
  chartConfig?: ChartConfig;
}

export interface DBConfig {
  host: string;
  user: string;
  password: string;
  database: string;
}

export interface QueryResult {
  success: boolean;
  data: Record<string, any>[];
  rowCount: number;
}

export interface DatabaseSchema {
  tables: string[];
  columns: Record<string, string[]>;
}
