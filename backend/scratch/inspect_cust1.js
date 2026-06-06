const { pool } = require('../db');

async function run() {
  try {
    const userRes = await pool.query("SELECT * FROM users WHERE cus_id = $1", ['CUST1']);
    console.log("User details for CUST1:", userRes.rows);

    const accountsRes = await pool.query("SELECT * FROM accounts WHERE cus_id = $1", ['CUST1']);
    console.log("Accounts details for CUST1:", accountsRes.rows);
  } catch (err) {
    console.error("Error fetching CUST1:", err);
  } finally {
    await pool.end();
  }
}

run();
