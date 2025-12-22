export interface Message {
  type: 'user' | 'ai' | 'error';
  content: string;
  timestamp: Date;
  sqlQuery?: string;
  data?: Record<string, any>[];
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
