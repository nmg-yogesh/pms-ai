const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// Database helper (optional) - will be used by /api/db-test
let testConnection;
try {
  // require lazily so the server can still start without mysql dependency configured
  ({ testConnection } = require('./frontend/db'));
} catch (e) {
  // ignore if db module not present
}

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
console.log(OPENAI_API_KEY);
const OPENAI_API_URL = 'https://api.openai.com/v1/chat/completions';

if (!OPENAI_API_KEY) {
  console.error('Error: OPENAI_API_KEY environment variable is not set');
  process.exit(1);
}

// Proxy endpoint for OpenAI API
app.post('/api/openai', async (req, res) => {
  try {
    const { messages, model, max_tokens } = req.body;

    const response = await fetch(OPENAI_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: model || 'gpt-4o-mini',
        max_tokens: max_tokens || 1000,
        messages,
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json(data);
    }

    res.json(data);
  } catch (error) {
    console.error('OpenAI API error:', error);
    res.status(500).json({ 
      error: 'Failed to process request',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Database connectivity test endpoint
app.get('/api/db-test', async (req, res) => {
  if (!testConnection) {
    return res.status(500).json({ ok: false, error: 'DB module not configured on server' });
  }

  try {
    const rows = await testConnection();
    res.json({ ok: true, result: rows });
  } catch (err) {
    console.error('DB test error:', err);
    res.status(500).json({ ok: false, error: err instanceof Error ? err.message : String(err) });
  }
});

// Load schema for validation
let DB_SCHEMA = {};
try {
  DB_SCHEMA = require('./db_schema.json');
} catch (e) {
  console.warn('db_schema.json not found, schema validation disabled');
}

const SQL_KEYWORDS = new Set([
  'select','from','where','join','left','right','inner','outer','on','group','by','order','limit','offset','as','and','or',
  'insert','into','values','update','set','delete','create','table','if','not','exists','primary','key','serial','text','jsonb',
  'into','returning','distinct','having',
  // Postgres aggregate functions
  'count','sum','avg','min','max','string_agg','array_agg',
  // Postgres date/time functions
  'date_trunc','current_date','current_timestamp','now','extract','interval','cast',
  // Postgres string functions
  'upper','lower','substring','length','concat','trim','ltrim','rtrim',
  // Postgres math functions
  'abs','ceil','floor','round','sqrt','power',
  // Postgres type functions
  'to_char','to_date','to_timestamp',
  // Common operators/keywords
  'between','in','is','null','true','false','case','when','then','else','end','with','recursive'
]);

function extractIdentifiers(sql) {
  // Remove string literals
  const noStrings = sql.replace(/'[^']*'/g, ' ');
  // Match simple identifiers (words and dotted identifiers)
  const tokens = noStrings.match(/\b[a-zA-Z_][a-zA-Z0-9_]*\b/g) || [];
  return tokens.map(t => t.toLowerCase());
}

function validateSQLAgainstSchema(sql) {
  if (!DB_SCHEMA || Object.keys(DB_SCHEMA).length === 0) return { valid: true, invalid: [] };

  const identifiers = extractIdentifiers(sql);
  const allowedTables = new Set(Object.keys(DB_SCHEMA).map(t => t.toLowerCase()));
  const allowedColumns = new Set();
  for (const [table, cols] of Object.entries(DB_SCHEMA)) {
    cols.forEach(c => allowedColumns.add(c.toLowerCase()));
  }

  const invalid = new Set();
  for (const id of identifiers) {
    if (SQL_KEYWORDS.has(id)) continue;
    if (/^\d+$/.test(id)) continue;
    // If identifier is a known table or column, it's fine
    if (allowedTables.has(id) || allowedColumns.has(id)) continue;
    // otherwise flag it
    invalid.add(id);
  }

  return { valid: invalid.size === 0, invalid: Array.from(invalid) };
}

function rewriteSQLRemovingColumns(sql, invalidCols) {
  // Simple rewrite strategy:
  // - If SELECT *, leave as-is (can't remove)
  // - Otherwise, locate the SELECT ... FROM portion and remove invalid columns from the select list
  try {
    const lower = sql.toLowerCase();
    const selectIdx = lower.indexOf('select');
    const fromIdx = lower.indexOf(' from ');
    if (selectIdx === -1 || fromIdx === -1 || fromIdx < selectIdx) return null;

    const selectList = sql.substring(selectIdx + 6, fromIdx).trim();
    if (selectList === '*' || selectList.includes('*')) return null;

    // split by commas but avoid splitting inside functions - naive but works for simple queries
    const parts = selectList.split(',').map(p => p.trim());
    const filtered = parts.filter(p => {
      // Extract the bare identifier(s) from the part
      // Handle cases like "table.col as alias" or "col as alias" or "func(col) as alias"
      const match = p.match(/([a-zA-Z_][a-zA-Z0-9_]*(?:\.[a-zA-Z_][a-zA-Z0-9_]*)?)/);
      if (!match) return true; // keep if we can't determine
      const ident = match[1].toLowerCase();
      const simple = ident.includes('.') ? ident.split('.').pop() : ident;
      return !invalidCols.includes(simple);
    });

    if (filtered.length === 0) return null;

    const newSql = sql.substring(0, selectIdx + 6) + ' ' + filtered.join(', ') + ' ' + sql.substring(fromIdx + 1);
    return newSql;
  } catch (e) {
    return null;
  }
}

// Execute SQL and optionally persist results
app.post('/api/execute-sql', async (req, res) => {
  if (!testConnection) {
    return res.status(500).json({ ok: false, error: 'DB module not configured on server' });
  }

  const { sql, persist = true } = req.body;
  if (!sql) return res.status(400).json({ ok: false, error: 'Missing sql in request body' });

  try {
    // get pool directly to run arbitrary queries
    const { getPool } = require('./frontend/db');
    const pool = getPool();
    const client = await pool.connect();
    try {
      // Validate SQL identifiers against schema to avoid executing queries referencing non-existent columns
      let validation = validateSQLAgainstSchema(sql);
      console.log('SQL validation:', validation);

      let finalSql = sql;
      let removed = [];
      if (!validation.valid) {
        // attempt automatic rewrite to remove invalid columns
        const rewrite = rewriteSQLRemovingColumns(sql, validation.invalid);
        if (rewrite) {
          const revalidation = validateSQLAgainstSchema(rewrite);
          if (revalidation.valid) {
            finalSql = rewrite;
            removed = validation.invalid;
            console.log('Rewrote SQL to remove invalid columns:', removed);
            validation = revalidation;
          }
        }
      }

      if (!validation.valid) {
        return res.status(400).json({ ok: false, error: 'SQL references unknown attributes', invalid: validation.invalid });
      }

      const result = await client.query(finalSql);

      // Persist results into audit table if requested
      if (persist) {
        await client.query(`CREATE TABLE IF NOT EXISTS ai_query_results (
          id SERIAL PRIMARY KEY,
          query_text TEXT,
          result JSONB,
          created_at TIMESTAMP DEFAULT now()
        )`);

        const rows = result.rows || [];
        await client.query('INSERT INTO ai_query_results (query_text, result) VALUES ($1, $2)', [sql, JSON.stringify(rows)]);
      }

      res.json({ ok: true, rows: result.rows, rowCount: result.rowCount });
    } finally {
      client.release();
    }
  } catch (err) {
    console.error('Execute SQL error:', err);
    res.status(500).json({ ok: false, error: err instanceof Error ? err.message : String(err) });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
