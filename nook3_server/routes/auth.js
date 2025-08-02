const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const router = express.Router();

const db = require('../utils/database');
const { generateToken, getTokenExpiry, isValidTokenFormat } = require('../utils/tokenUtils');
const { sendVerificationEmail, sendPasswordResetEmail } = require('../services/emailService');

/**
 * Register new user
 */
router.post('/register', async (req, res) => {
  try {
    const { email, phone, display_name, password } = req.body;

    // Validation
    if (!email || !password || !display_name) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Email, password, and display name are required'
      });
    }

    if (password.length < 8) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Password must be at least 8 characters long'
      });
    }

    // Check if user already exists
    const existingUser = await db.findUserByEmail(email);
    if (existingUser) {
      return res.status(400).json({
        return_code: 'USER_EXISTS',
        message: 'User with this email already exists'
      });
    }

    // Hash password
    const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
    const password_hash = await bcrypt.hash(password, saltRounds);

    // Create user
    const userData = {
      email,
      phone: phone || null,
      display_name,
      password_hash,
      is_anonymous: false
    };

    const newUser = await db.createUser(userData);

    // Generate verification token and send email
    const verificationToken = generateToken('verify');
    const tokenExpiry = getTokenExpiry(24); // 24 hours
    await db.setAuthToken(newUser.id, verificationToken, tokenExpiry);

    // Send verification email
    const emailResult = await sendVerificationEmail(email, verificationToken);
    if (!emailResult.success) {
      console.error('Failed to send verification email:', emailResult.error);
      // Continue with registration even if email fails
    }

    // Return success (without password hash)
    const { password_hash: _, ...userResponse } = newUser;
    
    res.status(201).json({
      return_code: 'SUCCESS',
      message: 'User registered successfully. Please check your email to verify your account.',
      user: userResponse,
      email_sent: emailResult.success
    });

  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/**
 * Login user
 */
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Email and password are required'
      });
    }

    // Find user
    const user = await db.findUserByEmail(email);
    if (!user) {
      return res.status(401).json({
        return_code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password'
      });
    }

    // Check password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json({
        return_code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password'
      });
    }

    // Check if email is verified (only for non-anonymous users)
    if (!user.is_anonymous && !user.email_verified) {
      return res.status(401).json({
        return_code: 'EMAIL_NOT_VERIFIED',
        message: 'Email not verified. Please check your email or continue as guest.',
        user_id: user.id,
        email: user.email
      });
    }

    // Update last active
    await db.updateLastActive(user.id);

    // Generate JWT token
    const jwtPayload = {
      user_id: user.id,
      email: user.email,
      display_name: user.display_name,
      is_anonymous: user.is_anonymous,
      email_verified: user.email_verified
    };

    const token = jwt.sign(jwtPayload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '24h'
    });

    // Return success (without password hash)
    const { password_hash: _, auth_token: __, auth_token_expires: ___, ...userResponse } = user;

    res.json({
      return_code: 'SUCCESS',
      message: 'Login successful',
      token,
      user: userResponse
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/**
 * Email verification
 */
router.get('/verify-email', async (req, res) => {
  try {
    const { token } = req.query;

    if (!token || !isValidTokenFormat(token, 'verify')) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Invalid Verification Link</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; line-height: 1.6; }
            .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            h1 { margin: 0 0 20px 0; font-size: 24px; font-weight: 600; }
            h2 { margin: 0 0 16px 0; font-size: 20px; font-weight: 500; color: #d63384; }
            p { margin: 0 0 16px 0; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>${process.env.EMAIL_NAME}</h1>
            <h2>Invalid Verification Link</h2>
            <p>This verification link is invalid or malformed. Please check your email for the correct link or request a new verification email.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Find user by token
    const user = await db.findByAuthToken(token);
    if (!user) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Verification Link Expired</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; line-height: 1.6; }
            .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            h1 { margin: 0 0 20px 0; font-size: 24px; font-weight: 600; }
            h2 { margin: 0 0 16px 0; font-size: 20px; font-weight: 500; color: #fd7e14; }
            p { margin: 0 0 16px 0; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>${process.env.EMAIL_NAME}</h1>
            <h2>Verification Link Expired</h2>
            <p>This verification link has expired or has already been used. Please request a new verification email from the app.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Mark email as verified and clear token
    await db.markEmailVerified(user.id);
    await db.clearAuthToken(user.id);

    // Return success page
    res.send(`
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Email Verified</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; line-height: 1.6; }
          .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center; }
          h1 { margin: 0 0 20px 0; font-size: 24px; font-weight: 600; }
          h2 { margin: 0 0 16px 0; font-size: 20px; font-weight: 500; color: #198754; }
          p { margin: 0 0 16px 0; color: #666; }
          .success-icon { font-size: 48px; margin-bottom: 20px; color: #198754; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>${process.env.EMAIL_NAME}</h1>
          <div class="success-icon">✓</div>
          <h2>Email Verified Successfully</h2>
          <p>Your email address has been verified. You can now log in to your account and enjoy all the features of ${process.env.EMAIL_NAME}.</p>
          <p>You can close this window and return to the app.</p>
        </div>
      </body>
      </html>
    `);

  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).send(`
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Verification Error</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; line-height: 1.6; }
          .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
          h1 { margin: 0 0 20px 0; font-size: 24px; font-weight: 600; }
          h2 { margin: 0 0 16px 0; font-size: 20px; font-weight: 500; color: #dc3545; }
          p { margin: 0 0 16px 0; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>${process.env.EMAIL_NAME}</h1>
          <h2>Verification Error</h2>
          <p>An error occurred while verifying your email. Please try again or contact support.</p>
        </div>
      </body>
      </html>
    `);
  }
});

/**
 * Resend verification email
 */
router.post('/resend-verification', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Email is required'
      });
    }

    const user = await db.findUserByEmail(email);
    
    // Generic response to prevent user enumeration
    const genericResponse = {
      return_code: 'SUCCESS',
      message: 'If this email is registered and not yet verified, a verification email has been sent.'
    };

    // If user doesn't exist or is already verified, return generic response
    if (!user || user.email_verified) {
      return res.json(genericResponse);
    }

    // Generate new verification token
    const verificationToken = generateToken('verify');
    const tokenExpiry = getTokenExpiry(24); // 24 hours
    await db.setAuthToken(user.id, verificationToken, tokenExpiry);

    // Send verification email
    const emailResult = await sendVerificationEmail(email, verificationToken);
    if (!emailResult.success) {
      console.error('Failed to send verification email:', emailResult.error);
    }

    res.json(genericResponse);

  } catch (error) {
    console.error('Resend verification error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/**
 * Forgot password
 */
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Email is required'
      });
    }

    const user = await db.findUserByEmail(email);
    
    // Generic response to prevent user enumeration
    const genericResponse = {
      return_code: 'SUCCESS',
      message: 'If this email is registered, a password reset link has been sent.'
    };

    // If user doesn't exist, return generic response
    if (!user || user.is_anonymous) {
      return res.json(genericResponse);
    }

    // Generate reset token
    const resetToken = generateToken('reset');
    const tokenExpiry = getTokenExpiry(1); // 1 hour
    await db.setAuthToken(user.id, resetToken, tokenExpiry);

    // Send password reset email
    const emailResult = await sendPasswordResetEmail(email, resetToken);
    if (!emailResult.success) {
      console.error('Failed to send password reset email:', emailResult.error);
    }

    res.json(genericResponse);

  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/**
 * Password reset form (GET)
 */
router.get('/reset-password', async (req, res) => {
  try {
    const { token } = req.query;

    if (!token || !isValidTokenFormat(token, 'reset')) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Invalid Reset Link</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; line-height: 1.6; }
            .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            h1 { margin: 0 0 20px 0; font-size: 24px; font-weight: 600; }
            h2 { margin: 0 0 16px 0; font-size: 20px; font-weight: 500; color: #d63384; }
            p { margin: 0 0 16px 0; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>${process.env.EMAIL_NAME}</h1>
            <h2>Invalid Reset Link</h2>
            <p>This password reset link is invalid or malformed. Please request a new password reset.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Check if token exists and is valid
    const user = await db.findByAuthToken(token);
    if (!user) {
      return res.status(400).send(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Reset Link Expired</title>
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; line-height: 1.6; }
            .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            h1 { margin: 0 0 20px 0; font-size: 24px; font-weight: 600; }
            h2 { margin: 0 0 16px 0; font-size: 20px; font-weight: 500; color: #fd7e14; }
            p { margin: 0 0 16px 0; color: #666; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>${process.env.EMAIL_NAME}</h1>
            <h2>Reset Link Expired</h2>
            <p>This password reset link has expired or has already been used. Please request a new password reset.</p>
          </div>
        </body>
        </html>
      `);
    }

    // Serve password reset form
    res.send(`
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Password</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; line-height: 1.6; }
          .container { max-width: 500px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
          h1 { margin: 0 0 20px 0; font-size: 24px; font-weight: 600; }
          h2 { margin: 0 0 24px 0; font-size: 20px; font-weight: 500; }
          .form-group { margin-bottom: 20px; }
          .form-group label { display: block; margin-bottom: 6px; font-weight: 500; }
          .form-group input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 4px; font-size: 16px; box-sizing: border-box; }
          .form-group input:focus { outline: none; border-color: #0066cc; box-shadow: 0 0 0 2px rgba(0,102,204,0.2); }
          .reset-button { width: 100%; background: #0066cc; color: white; padding: 14px; border: none; border-radius: 4px; font-size: 16px; font-weight: 500; cursor: pointer; }
          .reset-button:hover { background: #0052a3; }
          .reset-button:disabled { opacity: 0.6; cursor: not-allowed; background: #0066cc; }
          .message { padding: 12px; border-radius: 4px; margin-bottom: 20px; display: none; }
          .message.success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
          .message.error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
          .password-requirements { font-size: 14px; color: #666; margin-top: 4px; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>${process.env.EMAIL_NAME}</h1>
          <h2>Reset Your Password</h2>
          <div id="message" class="message"></div>
          <form id="resetForm" method="post" action="javascript:void(0)">
            <input type="hidden" name="token" value="${token}">
            <div class="form-group">
              <label for="new_password">New Password</label>
              <input type="password" id="new_password" name="new_password" required minlength="8">
              <div class="password-requirements">Minimum 8 characters required</div>
            </div>
            <div class="form-group">
              <label for="confirm_password">Confirm New Password</label>
              <input type="password" id="confirm_password" name="confirm_password" required minlength="8">
            </div>
            <button type="submit" class="reset-button" id="submitBtn">Reset Password</button>
          </form>
        </div>
        <script>
          document.getElementById('resetForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const messageEl = document.getElementById('message');
            const submitBtn = document.getElementById('submitBtn');
            const newPassword = document.getElementById('new_password').value;
            const confirmPassword = document.getElementById('confirm_password').value;
            const token = document.querySelector('input[name="token"]').value;
            
            // Reset message
            messageEl.style.display = 'none';
            messageEl.className = 'message';
            
            // Validate passwords
            if (newPassword.length < 8) {
              showMessage('Password must be at least 8 characters long', 'error');
              return;
            }
            
            if (newPassword !== confirmPassword) {
              showMessage('Passwords do not match', 'error');
              return;
            }
            
            // Disable submit button
            submitBtn.disabled = true;
            submitBtn.textContent = 'Resetting...';
            
            try {
              const response = await fetch('/api/auth/reset-password', {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                  token: token,
                  new_password: newPassword
                })
              });
              
              const data = await response.json();
              
              if (data.return_code === 'SUCCESS') {
                showMessage('Password reset successfully! You can now log in with your new password.', 'success');
                document.getElementById('resetForm').style.display = 'none';
              } else {
                showMessage(data.message || 'Password reset failed', 'error');
              }
            } catch (error) {
              showMessage('Network error. Please try again.', 'error');
            }
            
            // Re-enable submit button
            submitBtn.disabled = false;
            submitBtn.textContent = 'Reset Password';
          });
          
          function showMessage(text, type) {
            const messageEl = document.getElementById('message');
            messageEl.textContent = text;
            messageEl.className = 'message ' + type;
            messageEl.style.display = 'block';
          }
        </script>
      </body>
      </html>
    `);

  } catch (error) {
    console.error('Password reset form error:', error);
    res.status(500).send(`
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Reset Error</title>
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; color: #333; line-height: 1.6; }
          .container { max-width: 600px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
          h1 { margin: 0 0 20px 0; font-size: 24px; font-weight: 600; }
          h2 { margin: 0 0 16px 0; font-size: 20px; font-weight: 500; color: #dc3545; }
          p { margin: 0 0 16px 0; color: #666; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>${process.env.EMAIL_NAME}</h1>
          <h2>Reset Error</h2>
          <p>An error occurred while loading the password reset form. Please try again or request a new password reset.</p>
        </div>
      </body>
      </html>
    `);
  }
});

/**
 * Process password reset (POST)
 */
router.post('/reset-password', async (req, res) => {
  try {
    const { token, new_password } = req.body;

    // Validation
    if (!token || !new_password) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Token and new password are required'
      });
    }

    if (!isValidTokenFormat(token, 'reset')) {
      return res.status(400).json({
        return_code: 'INVALID_TOKEN',
        message: 'Invalid reset token format'
      });
    }

    if (new_password.length < 8) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Password must be at least 8 characters long'
      });
    }

    // Find user by token
    const user = await db.findByAuthToken(token);
    if (!user) {
      return res.status(400).json({
        return_code: 'INVALID_TOKEN',
        message: 'Invalid or expired reset token'
      });
    }

    // Hash new password
    const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
    const newPasswordHash = await bcrypt.hash(new_password, saltRounds);

    // Update password and clear token
    await db.updatePassword(user.id, newPasswordHash);

    res.json({
      return_code: 'SUCCESS',
      message: 'Password reset successfully. You can now log in with your new password.'
    });

  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/**
 * JWT verification middleware
 */
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1]; // Bearer <token>

  if (!token) {
    return res.status(401).json({
      return_code: 'NO_TOKEN',
      message: 'Access token required'
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        return_code: 'TOKEN_EXPIRED',
        message: 'Token has expired'
      });
    }
    return res.status(401).json({
      return_code: 'INVALID_TOKEN',
      message: 'Invalid token'
    });
  }
}

/**
 * Get current user profile
 */
router.get('/profile', verifyToken, async (req, res) => {
  try {
    const user = await db.findUserById(req.user.user_id);
    if (!user) {
      return res.status(404).json({
        return_code: 'USER_NOT_FOUND',
        message: 'User not found'
      });
    }

    // Return user profile (without sensitive data)
    const { password_hash: _, auth_token: __, auth_token_expires: ___, ...userResponse } = user;
    
    res.json({
      return_code: 'SUCCESS',
      user: userResponse
    });

  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/**
 * Update display name
 */
router.put('/profile', verifyToken, async (req, res) => {
  try {
    const { display_name } = req.body;

    if (!display_name) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Display name is required'
      });
    }

    await db.updateDisplayName(req.user.user_id, display_name);

    res.json({
      return_code: 'SUCCESS',
      message: 'Display name updated successfully'
    });

  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

module.exports = router;