/*
=======================================================================================================================================
Middleware: version_check
=======================================================================================================================================
Purpose: Validates that the mobile app version meets the minimum required version before allowing API access
=======================================================================================================================================
Headers Required:
{
  "app-version": "1.0.0"                  // string, required - Current app version
}

Error Response:
{
  "return_code": "APP_UPDATE_REQUIRED",
  "message": "App update required",       // string, user-friendly message
  "required_version": "1.0.0",           // string, minimum required version
  "current_version": "0.9.0"             // string, user's current version
}
=======================================================================================================================================
Return Codes:
"APP_UPDATE_REQUIRED" - App version is below minimum required
"MISSING_APP_VERSION" - No app-version header provided
"SERVER_ERROR" - Internal server error
=======================================================================================================================================
*/

const versionCheck = (req, res, next) => {
  try {
    const currentVersion = req.headers['app-version'];
    const requiredVersion = process.env.REQUIRED_APP_VERSION || '1.0.0';

    // Check if app-version header is provided
    if (!currentVersion) {
      return res.status(400).json({
        return_code: 'MISSING_APP_VERSION',
        message: 'App version header is required'
      });
    }

    // Compare versions
    if (!isVersionValid(currentVersion, requiredVersion)) {
      return res.status(426).json({
        return_code: 'APP_UPDATE_REQUIRED',
        message: 'Please update your app to continue using this service',
        required_version: requiredVersion,
        current_version: currentVersion
      });
    }

    // Version is valid, continue to next middleware
    next();
  } catch (error) {
    console.error('Version check error:', error);
    return res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
};

/**
 * Compare semantic versions (e.g., "1.2.3")
 * Returns true if current version >= required version
 */
function isVersionValid(current, required) {
  const currentParts = current.split('.').map(Number);
  const requiredParts = required.split('.').map(Number);

  // Pad arrays to same length
  while (currentParts.length < requiredParts.length) currentParts.push(0);
  while (requiredParts.length < currentParts.length) requiredParts.push(0);

  for (let i = 0; i < currentParts.length; i++) {
    if (currentParts[i] > requiredParts[i]) return true;
    if (currentParts[i] < requiredParts[i]) return false;
  }

  return true; // Versions are equal
}

module.exports = versionCheck;