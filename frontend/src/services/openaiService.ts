import { OPENAI_MODEL, SQL_MAX_TOKENS, EXPLANATION_MAX_TOKENS, DATABASE_SCHEMA } from '../constants';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

const callOpenAIAPI = async (messages: any[], maxTokens: number): Promise<string> => {
  const response = await fetch(`${API_URL}agentic/query`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: OPENAI_MODEL,
      max_tokens: maxTokens,
      messages,
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error?.message || error.message || 'OpenAI API request failed');
  }

  const data = await response.json();
  return data.choices[0].message.content;
};

export const convertNaturalLanguageToSQL = async (query: string): Promise<string> => {
  const sqlPrompt = `You are a SQL expert. Convert this natural language query to a Postgres SQL query.\n\n` +
    `Only use tables and columns listed in the schema below. Do NOT reference attributes that are not present in the schema. If the query requires an attribute not present, then omit it or ask for clarification.\n\n` +
    `${DATABASE_SCHEMA}\n\n` +
    `Natural language query: "${query}"\n\n` +
    `Return ONLY the SQL query without explanation or markdown formatting.`;

  const sqlQuery = await callOpenAIAPI(
    [{ role: 'user', content: sqlPrompt }],
    SQL_MAX_TOKENS
  );

  console.log('SQL Query:', sqlQuery);

  return sqlQuery
    .replace(/```sql\n?/g, '')
    .replace(/```\n?/g, '')
    .trim();
};

export const generateExplanation = async (
  originalQuery: string,
  sqlQuery: string,
  queryResults: Record<string, any>[]
): Promise<string> => {
  const explainPrompt = `You are a data analyst explaining database results to a non-technical person.

Original question: "${originalQuery}"

SQL Query executed: ${sqlQuery}

Query results: ${JSON.stringify(queryResults, null, 2)}

Provide a clear, concise explanation of the results in natural language. Use simple terms and highlight key insights. Format the response in a friendly, conversational way.`;

  return await callOpenAIAPI(
    [{ role: 'user', content: explainPrompt }],
    EXPLANATION_MAX_TOKENS
  );
};
