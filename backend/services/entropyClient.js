const axios = require('axios');
require('dotenv').config();

const PYTHON_TOKEN_SERVICE = process.env.PYTHON_TOKEN_SERVICE || 'http://localhost:8100';

/**
 * Connects to the Python Token Service to request session tokens.
 */
async function generateSessionToken() {
  try {
    const url = `${PYTHON_TOKEN_SERVICE}/generate-session-token`;
    const response = await axios.post(url, {}, { timeout: 5000 });
    
    if (response.data && response.data.session_token) {
      return {
        token: response.data.session_token,
        algorithm: 'ChaCha20-CSPRNG',
        generated_at: new Date().toISOString(),
        expires_in: 3600
      };
    } else if (response.data && response.data.success && response.data.token) {
      return {
        token: response.data.token,
        algorithm: response.data.algorithm,
        generated_at: response.data.generated_at,
        expires_in: response.data.expires_in
      };
    } else {
      throw new Error('Invalid response structure from token service');
    }
  } catch (error) {
    console.error('[EntropyClient] Failed to generate session token:', error.message);
    throw error;
  }
}

module.exports = {
  generateSessionToken
};
