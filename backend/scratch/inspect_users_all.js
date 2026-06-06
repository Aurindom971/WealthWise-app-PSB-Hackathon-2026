const { pool } = require('../db');

async function run() {
  try {
    const res = await pool.query("SELECT * FROM users LIMIT 2");
    if (res.rows.length > 0) {
      console.log("Keys of users table:", Object.keys(res.rows[0]));
      console.log("Row values:", res.rows[0]);
    } else {
      console.log("No users found.");
    }
  } catch (err) {
    console.error("Error fetching users:", err);
  } finally {
    await pool.end();
  }
}

run();
