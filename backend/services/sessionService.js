const { pool } = require('../db');
const { hashToken } = require('../utils/cryptoUtils');
const entropyClient = require('./entropyClient');

/**
 * Helper to dynamically target the query by auth_user_id (UUID) or cus_id (text)
 * to avoid PostgreSQL type casting operator mismatch errors.
 */
function getTargetField(userId) {
  const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(userId);
  return isUuid ? 'auth_user_id' : 'cus_id';
}

/**
 * Creates a new active session for the user.
 */
async function createSession(userId, rawSessionToken, expiresIn) {
  const tStart = Date.now();
  try {
    const tokenHash = hashToken(rawSessionToken);
    const createdAt = new Date();
    const expiresAt = new Date(createdAt.getTime() + (expiresIn * 1000));
    const status = 'ACTIVE';

    const targetField = getTargetField(userId);
    const query = `
      UPDATE users 
      SET current_session_token_hash = $1,
          current_session_created_at = $2,
          current_session_expires_at = $3,
          current_session_status = $4
      WHERE ${targetField} = $5
    `;
    const result = await pool.query(query, [tokenHash, createdAt, expiresAt, status, userId]);
    
    if (result.rowCount === 0) {
      throw new Error(`User not found: ${userId}`);
    }

    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Session Created | User ID: ${userId} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
    return { success: true, message: 'Session successfully created.' };
  } catch (error) {
    console.error('[SessionService] Error in createSession:', error.message);
    throw error;
  }
}

/**
 * Returns current session info without exposing the hash.
 */
async function getCurrentSession(userId) {
  try {
    const targetField = getTargetField(userId);
    const query = `
      SELECT current_session_status, current_session_created_at, current_session_expires_at
      FROM users
      WHERE ${targetField} = $1
    `;
    const result = await pool.query(query, [userId]);
    
    if (result.rows.length === 0) {
      throw new Error(`User not found: ${userId}`);
    }
    
    const row = result.rows[0];
    return {
      status: row.current_session_status,
      created_at: row.current_session_created_at,
      expires_at: row.current_session_expires_at
    };
  } catch (error) {
    console.error('[SessionService] Error in getCurrentSession:', error.message);
    throw error;
  }
}

/**
 * Validates a raw session token.
 */
async function validateSession(rawSessionToken) {
  try {
    const tokenHash = hashToken(rawSessionToken);
    const query = `
      SELECT auth_user_id, cus_id, current_session_status, current_session_expires_at
      FROM users
      WHERE current_session_token_hash = $1
    `;
    const result = await pool.query(query, [tokenHash]);
    
    if (result.rows.length === 0) {
      return { isValid: false };
    }
    
    const user = result.rows[0];
    if (user.current_session_status !== 'ACTIVE') {
      return { isValid: false };
    }
    
    const expiresAt = new Date(user.current_session_expires_at);
    if (expiresAt < new Date()) {
      return { isValid: false };
    }
    
    return { isValid: true, userId: user.auth_user_id, cus_id: user.cus_id };
  } catch (error) {
    console.error('[SessionService] Error in validateSession:', error.message);
    return { isValid: false };
  }
}

/**
 * Marks current session as expired. Keep historical timestamps.
 */
async function expireSession(userId) {
  const tStart = Date.now();
  try {
    const targetField = getTargetField(userId);
    const query = `
      UPDATE users
      SET current_session_status = 'EXPIRED'
      WHERE ${targetField} = $1
    `;
    const result = await pool.query(query, [userId]);
    
    if (result.rowCount === 0) {
      throw new Error(`User not found: ${userId}`);
    }

    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Session Expired | User ID: ${userId} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
    return { success: true };
  } catch (error) {
    console.error('[SessionService] Error in expireSession:', error.message);
    throw error;
  }
}

/**
 * Revokes current session by setting hash to null, status to revoked and expires_at to now.
 */
async function revokeSession(userId) {
  const tStart = Date.now();
  try {
    const targetField = getTargetField(userId);
    const query = `
      UPDATE users
      SET current_session_token_hash = NULL,
          current_session_status = 'REVOKED',
          current_session_expires_at = NOW()
      WHERE ${targetField} = $1
    `;
    const result = await pool.query(query, [userId]);
    
    if (result.rowCount === 0) {
      throw new Error(`User not found: ${userId}`);
    }

    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Session Revoked | User ID: ${userId} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
    return { success: true };
  } catch (error) {
    console.error('[SessionService] Error in revokeSession:', error.message);
    throw error;
  }
}

/**
 * Logs out session by clearing all session values.
 */
async function logoutSession(userId) {
  const tStart = Date.now();
  try {
    const targetField = getTargetField(userId);
    const query = `
      UPDATE users
      SET current_session_token_hash = NULL,
          current_session_created_at = NULL,
          current_session_expires_at = NULL,
          current_session_status = 'LOGGED_OUT'
      WHERE ${targetField} = $1
    `;
    const result = await pool.query(query, [userId]);
    
    if (result.rowCount === 0) {
      throw new Error(`User not found: ${userId}`);
    }

    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Session Logged Out | User ID: ${userId} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
    return { success: true };
  } catch (error) {
    console.error('[SessionService] Error in logoutSession:', error.message);
    throw error;
  }
}

/**
 * Refreshes session by requesting a new raw token.
 * Wrapped in a PostgreSQL transaction for atomicity (Task 11).
 * Either the old session is fully replaced or no changes are committed.
 */
async function refreshSession(userId) {
  const tStart = Date.now();
  console.log(`[INFO] Session Refresh Started | User ID: ${userId} | Timestamp: ${new Date().toISOString()}`);

  // 1. Fetch new raw token from the Python Aquarium Token Service
  console.log(`[INFO] Python Token Requested | User ID: ${userId} | Timestamp: ${new Date().toISOString()}`);
  let tokenData;
  try {
    tokenData = await entropyClient.generateSessionToken();
  } catch (error) {
    console.error(`[SessionService] Python Token Service unavailable for user ${userId}:`, error.message);
    const err = new Error('Python Token Service unavailable');
    err.code = 'SERVICE_UNAVAILABLE';
    throw err;
  }
  console.log(`[INFO] New Session Generated | User ID: ${userId} | Timestamp: ${new Date().toISOString()}`);

  // 2. Hash the new token — never store the raw token
  const tokenHash = hashToken(tokenData.token);
  const createdAt = new Date();
  const expiresAt = new Date(createdAt.getTime() + (tokenData.expires_in * 1000));
  const status = 'ACTIVE';

  // 3. Atomic DB update inside a transaction
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    console.log(`[INFO] Database Update Started | User ID: ${userId} | Timestamp: ${new Date().toISOString()}`);

    const targetField = getTargetField(userId);
    const query = `
      UPDATE users
      SET current_session_token_hash = $1,
          current_session_created_at = $2,
          current_session_expires_at = $3,
          current_session_status = $4
      WHERE ${targetField} = $5
    `;
    const result = await client.query(query, [tokenHash, createdAt, expiresAt, status, userId]);

    if (result.rowCount === 0) {
      await client.query('ROLLBACK');
      throw new Error(`User not found: ${userId}`);
    }

    await client.query('COMMIT');
    console.log(`[INFO] Database Updated | User ID: ${userId} | Timestamp: ${new Date().toISOString()}`);

    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Session Refresh Completed | User ID: ${userId} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
    return {
      success: true,
      raw_token: tokenData.token,
      expires_in: tokenData.expires_in
    };
  } catch (error) {
    await client.query('ROLLBACK').catch(() => {});
    console.error('[SessionService] Error in refreshSession (rolled back):', error.message);
    throw error;
  } finally {
    client.release();
  }
}

module.exports = {
  createSession,
  getCurrentSession,
  validateSession,
  expireSession,
  revokeSession,
  logoutSession,
  refreshSession
};
