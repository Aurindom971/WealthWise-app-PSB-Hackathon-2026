const { pool } = require('../db');

async function run() {
  try {
    const usersRes = await pool.query("SELECT cus_id, email, full_name FROM users");
    console.log("=== USERS ===");
    console.table(usersRes.rows);

    const accountsRes = await pool.query("SELECT cus_id, account_id, account_type, balance FROM accounts");
    console.log("\n=== ACCOUNTS ===");
    console.table(accountsRes.rows);
  } catch (err) {
    console.error("Error:", err);
  } finally {
    await pool.end();
  }
}

run();
