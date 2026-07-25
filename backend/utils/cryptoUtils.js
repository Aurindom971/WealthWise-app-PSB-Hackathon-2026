const crypto = require('crypto');

/**
 * Hashes a token string using SHA3-512 algorithm.
 * @param {string} token - The raw session token
 * @returns {string} - Hex digest of the hashed token
 */
function hashToken(token) {
  if (!token) {
    throw new Error('Token is required for hashing.');
  }
  return crypto.createHash('sha3-512').update(token).digest('hex');
}

module.exports = {
  hashToken
};
