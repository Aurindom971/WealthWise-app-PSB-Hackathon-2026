const { pool } = require('../db');

async function run() {
  try {
    const tablesRes = await pool.query(
      "SELECT table_name FROM information_schema.tables WHERE table_schema='public'"
    );
    console.log("Tables:", tablesRes.rows.map(r => r.table_name));

    for (const table of tablesRes.rows.map(r => r.table_name)) {
      const colsRes = await pool.query(
        "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = $1",
        [table]
      );
      console.log(`\nColumns of ${table}:`);
      colsRes.rows.forEach(c => {
        console.log(`  - ${c.column_name}: ${c.data_type}`);
      });
    }
  } catch (err) {
    console.error("Error listing tables:", err);
  } finally {
    await pool.end();
  }
}

run();
