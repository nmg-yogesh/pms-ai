/**
 * PMS Agentic AI - Frontend Constants
 * Example queries for the Project Management System
 */

export const EXAMPLE_QUERIES = [
  "How many pending help tickets are there?",
  "Show me all active workflows",
  "List all users in the IT department",
  "Which user has the most pending tickets?",
  "Show me all high priority tickets",
  "What's the current step in the hiring process?"
];

export const EXAMPLE_QUERIES_BY_CATEGORY = {
  hit_tickets: [
    "How many help tickets are pending?",
    "Show me all high priority tickets",
    "Which user has the most pending tickets?",
    "List all tickets completed this week"
  ],
  fms_workflows: [
    "Show me all active workflows",
    "What's the current step in the hiring process?",
    "How many purchase orders are in progress?",
    "List all workflow entries created this month"
  ],
  users: [
    "List all users in the IT department",
    "How many active users are there?",
    "Show me all department team leads",
    "Which department has the most users?"
  ],
  projects: [
    "Show me all active projects",
    "Which project has the most tasks?",
    "List overdue tasks",
    "What's the completion rate for projects?"
  ]
};

export const APP_CONFIG = {
  name: 'PMS Agentic AI',
  version: '2.0.0',
  description: 'Natural Language Query Interface for Project Management System',
  features: [
    'Natural language to SQL conversion',
    'Automatic database schema integration',
    'AI-powered result analysis',
    'Voice input support',
    'Real-time query execution'
  ]
};

export const BACKEND_INFO = {
  apiUrl: process.env.NODE_ENV === 'production'
    ? 'https://processhq-gpt-demo.newmediaguru.co'
    : process.env.REACT_APP_API_URL || 'http://localhost:8000',
  apiVersion: 'v1',
  endpoints: {
    query: '/api/v1/agentic/query',
    examples: '/api/v1/agentic/examples',
    health: '/api/v1/health'
  }
};
