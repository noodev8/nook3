const crypto = require('crypto');

/**
 * Generate a secure random token with prefix
 * @param {string} prefix - Token prefix ('verify' or 'reset')
 * @returns {string} - Prefixed token
 */
function generateToken(prefix) {
  const randomBytes = crypto.randomBytes(32).toString('hex');
  return `${prefix}_${randomBytes}`;
}

/**
 * Check if a timestamp is expired
 * @param {Date} date - The expiry date to check
 * @returns {boolean} - True if expired
 */
function isTokenExpired(date) {
  return new Date() > new Date(date);
}

/**
 * Get expiry timestamp for tokens
 * @param {number} hours - Hours from now
 * @returns {Date} - Expiry timestamp
 */
function getTokenExpiry(hours) {
  const expiry = new Date();
  expiry.setHours(expiry.getHours() + hours);
  return expiry;
}

/**
 * Validate token format
 * @param {string} token - Token to validate
 * @param {string} expectedPrefix - Expected prefix ('verify' or 'reset')
 * @returns {boolean} - True if valid format
 */
function isValidTokenFormat(token, expectedPrefix) {
  if (!token || typeof token !== 'string') return false;
  const prefix = `${expectedPrefix}_`;
  return token.startsWith(prefix) && token.length > prefix.length;
}

module.exports = {
  generateToken,
  isTokenExpired,
  getTokenExpiry,
  isValidTokenFormat
};