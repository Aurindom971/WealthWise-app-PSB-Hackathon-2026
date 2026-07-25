const authService = require('../services/authService');
const entropyClient = require('../services/entropyClient');
const sessionService = require('../services/sessionService');

/**
 * Controller to handle user login flow with Aquarium Session Token Service integration.
 */
async function login(req, res) {
  const tStart = Date.now();
  const { email, password, cus_id } = req.body;
  const identifier = email || cus_id;

  if (!identifier || !password) {
    return res.status(400).json({
      success: false,
      message: 'Email/Cus ID and password are required'
    });
  }

  try {
    // 1. Authenticate user credentials
    const user = await authService.authenticateUser(identifier, password);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials'
      });
    }

    console.log(`[INFO] User Authenticated | User ID: ${user.auth_user_id} | Timestamp: ${new Date().toISOString()}`);

    // 2. Request a secure session token from Python Token Service
    console.log(`[INFO] Token Requested | User ID: ${user.auth_user_id} | Timestamp: ${new Date().toISOString()}`);
    const tTokenStart = Date.now();
    let tokenData;
    
    try {
      tokenData = await entropyClient.generateSessionToken();
    } catch (err) {
      return res.status(503).json({
        success: false,
        message: 'Session token service unavailable.'
      });
    }
    
    const tTokenElapsed = Date.now() - tTokenStart;
    console.log(`[INFO] Token Received | User ID: ${user.auth_user_id} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tTokenElapsed} ms`);

    // 3. Hash the session token and store the session details via the Session Service
    try {
      await sessionService.createSession(user.auth_user_id, tokenData.token, tokenData.expires_in);
    } catch (err) {
      return res.status(500).json({
        success: false,
        message: 'Database update failed.'
      });
    }

    // 4. Complete login flow and return the RAW session token to the client
    const totalElapsed = Date.now() - tStart;
    console.log(`[INFO] Login Completed | User ID: ${user.auth_user_id} | Timestamp: ${new Date().toISOString()} | Total Processing Time: ${totalElapsed} ms`);

    return res.status(200).json({
      success: true,
      user: {
        id: user.auth_user_id,
        cus_id: user.cus_id,
        email: user.email,
        full_name: user.full_name
      },
      session_token: tokenData.token,
      expires_in: tokenData.expires_in
    });

  } catch (error) {
    console.error('[AuthController] Login error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error.'
    });
  }
}

/**
 * Controller to handle user logout.
 * Requires sessionMiddleware — only authenticated users may logout.
 */
async function logout(req, res) {
  const tStart = Date.now();
  const userId = req.user.cus_id;

  console.log(`[INFO] Logout Started | User ID: ${userId} | Timestamp: ${new Date().toISOString()}`);

  try {
    await sessionService.logoutSession(userId);

    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Logout Completed | User ID: ${userId} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);

    return res.status(200).json({
      success: true,
      message: 'Successfully logged out.'
    });
  } catch (error) {
    console.error('[AuthController] Logout error:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Internal server error.'
    });
  }
}

/**
 * Controller to handle session refresh.
 * Requires sessionMiddleware — only authenticated users may refresh.
 * Calls the Python Aquarium Token Service, hashes the new token,
 * atomically replaces the old session, and returns the raw token.
 */
async function refreshSessionController(req, res) {
  const tStart = Date.now();
  const userId = req.user.cus_id;

  console.log(`[INFO] Session Refresh Requested | User ID: ${userId} | Timestamp: ${new Date().toISOString()}`);

  try {
    const result = await sessionService.refreshSession(userId);

    const tElapsed = Date.now() - tStart;
    console.log(`[INFO] Session Refresh Completed | User ID: ${userId} | Timestamp: ${new Date().toISOString()} | Processing Time: ${tElapsed} ms`);

    return res.status(200).json({
      success: true,
      session_token: result.raw_token,
      expires_in: result.expires_in
    });
  } catch (error) {
    console.error('[AuthController] Refresh error:', error.message);

    // Python Token Service offline
    if (error.code === 'SERVICE_UNAVAILABLE' || error.code === 'ECONNREFUSED' || error.code === 'ECONNABORTED') {
      return res.status(503).json({
        success: false,
        message: 'Session token service unavailable.'
      });
    }

    // Database or other internal failure — token is NOT returned
    return res.status(500).json({
      success: false,
      message: 'Internal server error.'
    });
  }
}

module.exports = {
  login,
  logout,
  refreshSession: refreshSessionController
};
