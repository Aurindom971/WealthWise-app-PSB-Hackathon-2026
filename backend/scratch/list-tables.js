const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function main() {
  try {
    const tablesQuery = `
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
      ORDER BY table_name;
    `;
    const res = await pool.query(tablesQuery);
    console.log('--- TABLES ---');
    console.log(res.rows.map(r => r.table_name));

    for (const row of res.rows) {
      const colQuery = `
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_schema = 'public' AND table_name = $1
        ORDER BY ordinal_position;
      `;
      const colRes = await pool.query(colQuery, [row.table_name]);
      console.log(`\nTable: ${row.table_name}`);
      console.log(colRes.rows.map(c => `${c.column_name} (${c.data_type})`).join(', '));
    }
  } catch (err) {
    console.error('Error:', err);
  } finally {
    await pool.end();
  }
}

main();
