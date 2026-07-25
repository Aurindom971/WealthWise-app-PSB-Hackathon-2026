const { pool } = require('../db');
const crypto = require('crypto');

/**
 * Checks if a string is a 64-character hex SHA-256 hash.
 */
function isSha256Hash(value) {
  return typeof value === 'string' && value.length === 64 && /^[a-fA-F0-9]{64}$/.test(value);
}

/**
 * Verifies user credentials.
 * Supports looking up users by email or cus_id.
 * Handles both plain-text and SHA-256 migrated passwords.
 */
async function authenticateUser(identifier, password) {
  try {
    const query = 'SELECT auth_user_id, cus_id, email, auth_password, full_name FROM users WHERE email = $1 OR cus_id = $1';
    const result = await pool.query(query, [identifier]);
    
    if (result.rows.length === 0) {
      return null;
    }
    
    const user = result.rows[0];
    const storedPassword = user.auth_password;
    
    // If stored password is a SHA-256 hash (64-char hex), hash the incoming password and compare
    if (isSha256Hash(storedPassword)) {
      const incomingHash = crypto.createHash('sha256').update(password).digest('hex');
      if (storedPassword !== incomingHash) {
        return null;
      }
    } else {
      // Plain-text comparison (legacy)
      if (storedPassword !== password) {
        return null;
      }
    }
    
    return user;
  } catch (error) {
    console.error('[AuthService] Error authenticating user:', error.message);
    throw error;
  }
}

module.exports = {
  authenticateUser
};
