const { pool } = require('../db');

async function run() {
  try {
    const res = await pool.query(
      "SELECT id, email, cus_id, auth_user_id, full_name FROM users"
    );
    console.log("Users in DB:", res.rows);
  } catch (err) {
    console.error("Error fetching users:", err);
  } finally {
    await pool.end();
  }
}

run();
