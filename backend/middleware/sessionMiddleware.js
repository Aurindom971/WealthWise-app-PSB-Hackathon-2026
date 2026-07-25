const crypto = require('crypto');
const { pool } = require('../db');
const { hashToken } = require('../utils/cryptoUtils');

/**
 * Helper to dynamically target the query by auth_user_id (UUID) or cus_id (text)
 * to avoid PostgreSQL type casting operator mismatch errors.
 */
function getTargetField(userId) {
  const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(userId);
  return isUuid ? 'auth_user_id' : 'cus_id';
}

/**
 * Constant-time comparison to prevent timing side-channel attacks.
 */
function constantTimeCompare(a, b) {
  try {
    const aBuffer = Buffer.from(a, 'utf-8');
    const bBuffer = Buffer.from(b, 'utf-8');
    if (aBuffer.length !== bBuffer.length) {
      return false;
    }
    return crypto.timingSafeEqual(aBuffer, bBuffer);
  } catch (_) {
    return false;
  }
}

/**
 * Reusable Express middleware to validate Aquarium-generated session tokens.
 */
async function sessionMiddleware(req, res, next) {
  const tStart = Date.now();
  console.log(`[INFO] Incoming Protected Request | Path: ${req.path} | Timestamp: ${new Date().toISOString()}`);

  const authHeader = req.headers['authorization'];

  // 1. Check for missing or malformed header
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.log(`[INFO] Validation Failed | Reason: Missing or invalid Authorization header | Timestamp: ${new Date().toISOString()}`);
    return res.status(401).json({
      success: false,
      message: 'Missing or invalid Authorization header.'
    });
  }

  const token = authHeader.substring(7).trim();
  if (!token) {
    console.log(`[INFO] Validation Failed | Reason: Empty Token | Timestamp: ${new Date().toISOString()}`);
    return res.status(401).json({
      success: false,
      message: 'Missing or invalid Authorization header.'
    });
  }

  console.log(`[INFO] Token Validation Started | Timestamp: ${new Date().toISOString()}`);

  try {
    // 2. Hash computed session token using SHA3-512
    const computedHash = hashToken(token);
    console.log(`[INFO] Hash Generated | Timestamp: ${new Date().toISOString()}`);

    // 3. Database Lookup
    console.log(`[INFO] Database Lookup | Timestamp: ${new Date().toISOString()}`);
    const query = `
      SELECT auth_user_id, cus_id, email, current_session_token_hash, current_session_status, current_session_expires_at
      FROM users
      WHERE current_session_token_hash = $1
    `;
    const result = await pool.query(query, [computedHash]);

    let user = null;
    if (result.rows.length > 0) {
      user = result.rows[0];
    } else {
      // Fallback: If token hash is NULL (e.g. revoked or logged out), we check if the user is identified
      // via request body (cus_id/email) or custom headers to accurately determine the status (403 vs 401).
      const identifier = (req.body && (req.body.cus_id || req.body.email)) || 
                         req.headers['x-user-id'] || 
                         req.headers['x-cus-id'];
      if (identifier) {
        const targetField = getTargetField(identifier);
        const fallbackQuery = `
          SELECT auth_user_id, cus_id, email, current_session_token_hash, current_session_status, current_session_expires_at
          FROM users
          WHERE ${targetField} = $1
        `;
        const fallbackResult = await pool.query(fallbackQuery, [identifier]);
        if (fallbackResult.rows.length > 0) {
          user = fallbackResult.rows[0];
        }
      }
    }

    if (!user) {
      const tElapsed = Date.now() - tStart;
      console.log(`[INFO] Validation Failed | Reason: Token not found / User unidentified | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
      return res.status(401).json({
        success: false,
        message: 'Invalid session token.'
      });
    }

    // 4. Constant-time comparison (only if token hash matches the computed hash,
    // otherwise if the session status is revoked/logged_out, we skip comparing hash so we can return the correct status response)
    if (user.current_session_token_hash) {
      const isHashMatch = constantTimeCompare(computedHash, user.current_session_token_hash);
      if (!isHashMatch) {
        const tElapsed = Date.now() - tStart;
        console.log(`[INFO] Validation Failed | Reason: Hash mismatch | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
        return res.status(401).json({
          success: false,
          message: 'Invalid session token.'
        });
      }
    }

    // 5. Verify session status and expiry
    const status = user.current_session_status;
    const expiresAt = new Date(user.current_session_expires_at);
    const now = new Date();

    if (status === 'REVOKED') {
      const tElapsed = Date.now() - tStart;
      console.log(`[INFO] Request Denied | User ID: ${user.auth_user_id} | Reason: Revoked | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
      return res.status(403).json({
        success: false,
        message: 'Session has been revoked.'
      });
    }

    if (status === 'LOGGED_OUT') {
      const tElapsed = Date.now() - tStart;
      console.log(`[INFO] Request Denied | User ID: ${user.auth_user_id} | Reason: Logged out | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
      return res.status(401).json({
        success: false,
        message: 'Session has been logged out.'
      });
    }

    if (status !== 'ACTIVE') {
      const tElapsed = Date.now() - tStart;
      console.log(`[INFO] Request Denied | User ID: ${user.auth_user_id} | Reason: Inactive | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
      return res.status(401).json({
        success: false,
        message: 'Session is inactive.'
      });
    }

    if (expiresAt < now) {
      const tElapsed = Date.now() - tStart;
      console.log(`[INFO] Request Denied | User ID: ${user.auth_user_id} | Reason: Expired | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
      return res.status(401).json({
        success: false,
        message: 'Session has expired.'
      });
    }

    // 6. Attach User Context
    req.user = {
      cus_id: user.cus_id,
      email: user.email,
      authenticated: true
    };

    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Validation Success | User ID: ${user.auth_user_id} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
    console.log(`[INFO] Request Allowed | Path: ${req.path} | User ID: ${user.auth_user_id} | Timestamp: ${new Date().toISOString()}`);
    
    return next();
  } catch (error) {
    console.error('[SessionMiddleware] Database/Internal failure:', error.message);
    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Validation Failed | Reason: DB/Internal error | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);
    return res.status(500).json({
      success: false,
      message: 'Internal server error.'
    });
  }
}

module.exports = {
  sessionMiddleware
};
