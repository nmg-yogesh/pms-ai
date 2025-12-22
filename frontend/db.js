const { Pool } = require('pg');
require('dotenv').config();

const DB_HOST = process.env.DB_HOST || 'localhost';
const DB_PORT = process.env.DB_PORT ? Number(process.env.DB_PORT) : 5432;
const DB_USER = process.env.DB_USER || 'postgres';
const DB_PASSWORD = process.env.DB_PASSWORD || '';
const DB_NAME = process.env.DB_NAME || '';

let pool;

function getPool() {
  if (!pool) {
    pool = new Pool({                                                 
      host: DB_HOST,
      port: DB_PORT,
      user: DB_USER,
      password: DB_PASSWORD,
      database: DB_NAME,
      max: 10,
      idleTimeoutMillis: 30000,
    });
  }
  return pool;
}

async function testConnection() {
  const p = getPool();
  const client = await p.connect();
  try {
    const res = await client.query('SELECT 1 AS ok');
    return res.rows;
  } finally {
    client.release();
  }
}

module.exports = { getPool, testConnection };
