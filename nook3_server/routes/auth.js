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
    console.log('Looking up user by email...');
    const user = await db.findUserByEmail(email);
    console.log('User lookup result:', user ? 'User found' : 'User not found');
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
          <title>Invalid Verification Link - ${process.env.EMAIL_NAME}</title>
          <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
            .container { max-width: 500px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; text-align: center; }
            .header { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; padding: 30px; }
            .header h1 { margin: 0; font-size: 28px; font-weight: 300; }
            .content { padding: 40px; }
            .content h2 { color: #333; margin-bottom: 20px; }
            .content p { color: #666; margin-bottom: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>${process.env.EMAIL_NAME}</h1>
            </div>
            <div class="content">
              <h2>❌ Invalid Verification Link</h2>
              <p>This verification link is invalid or malformed. Please check your email for the correct link or request a new verification email.</p>
            </div>
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
          <title>Verification Link Expired - ${process.env.EMAIL_NAME}</title>
          <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
            .container { max-width: 500px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; text-align: center; }
            .header { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: white; padding: 30px; }
            .header h1 { margin: 0; font-size: 28px; font-weight: 300; }
            .content { padding: 40px; }
            .content h2 { color: #333; margin-bottom: 20px; }
            .content p { color: #666; margin-bottom: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>${process.env.EMAIL_NAME}</h1>
            </div>
            <div class="content">
              <h2>⏰ Verification Link Expired</h2>
              <p>This verification link has expired or has already been used. Please request a new verification email from the app.</p>
            </div>
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
        <title>Email Verified - ${process.env.EMAIL_NAME}</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
          .container { max-width: 500px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; text-align: center; }
          .header { background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); color: white; padding: 30px; }
          .header h1 { margin: 0; font-size: 28px; font-weight: 300; }
          .content { padding: 40px; }
          .content h2 { color: #333; margin-bottom: 20px; }
          .content p { color: #666; margin-bottom: 20px; }
          .success-icon { font-size: 48px; margin-bottom: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>${process.env.EMAIL_NAME}</h1>
          </div>
          <div class="content">
            <div class="success-icon">✅</div>
            <h2>Email Verified Successfully!</h2>
            <p>Your email address has been verified. You can now log in to your account and enjoy all the features of ${process.env.EMAIL_NAME}.</p>
            <p>You can close this window and return to the app.</p>
          </div>
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
        <title>Verification Error - ${process.env.EMAIL_NAME}</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
          .container { max-width: 500px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; text-align: center; }
          .header { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; padding: 30px; }
          .header h1 { margin: 0; font-size: 28px; font-weight: 300; }
          .content { padding: 40px; }
          .content h2 { color: #333; margin-bottom: 20px; }
          .content p { color: #666; margin-bottom: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>${process.env.EMAIL_NAME}</h1>
          </div>
          <div class="content">
            <h2>❌ Verification Error</h2>
            <p>An error occurred while verifying your email. Please try again or contact support.</p>
          </div>
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

    console.log('Looking up user by email...');
    const user = await db.findUserByEmail(email);
    console.log('User lookup result:', user ? 'User found' : 'User not found');
    
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
  console.log('=== FORGOT PASSWORD ROUTE STARTED ===');
  try {
    const { email } = req.body;
    console.log('Email received:', email);

    if (!email) {
      return res.status(400).json({
        return_code: 'VALIDATION_ERROR',
        message: 'Email is required'
      });
    }

    console.log('Looking up user by email...');
    const user = await db.findUserByEmail(email);
    console.log('User lookup result:', user ? 'User found' : 'User not found');
    
    // Generic response to prevent user enumeration
    const genericResponse = {
      return_code: 'SUCCESS',
      message: 'If this email is registered, a password reset link has been sent.'
    };

    // If user doesn't exist, return generic response
    if (!user || user.is_anonymous) {
      console.log('User not found or anonymous - returning generic response without sending email');
      return res.json(genericResponse);
    }
    
    console.log('User found - proceeding to send reset email');

    // Generate reset token
    const resetToken = generateToken('reset');
    console.log('Generated reset token for user:', user.id, 'Token length:', resetToken.length);
    
    const tokenExpiry = getTokenExpiry(1); // 1 hour
    console.log('Token expiry set to:', tokenExpiry);
    
    await db.setAuthToken(user.id, resetToken, tokenExpiry);
    console.log('Token saved to database for user:', user.id);

    // Send password reset email
    console.log('Attempting to send password reset email to:', email);
    const emailResult = await sendPasswordResetEmail(email, resetToken);
    console.log('Email send result:', emailResult);
    
    if (!emailResult.success) {
      console.error('Failed to send password reset email:', emailResult.error);
    } else {
      console.log('Password reset email sent successfully with message ID:', emailResult.messageId);
    }

    console.log('=== FORGOT PASSWORD ROUTE COMPLETED SUCCESSFULLY ===');
    res.json(genericResponse);

  } catch (error) {
    console.error('=== FORGOT PASSWORD ROUTE ERROR ===');
    console.error('Forgot password error:', error);
    console.error('Error stack:', error.stack);
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
          <title>Invalid Reset Link - ${process.env.EMAIL_NAME}</title>
          <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
            .container { max-width: 500px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; text-align: center; }
            .header { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; padding: 30px; }
            .header h1 { margin: 0; font-size: 28px; font-weight: 300; }
            .content { padding: 40px; }
            .content h2 { color: #333; margin-bottom: 20px; }
            .content p { color: #666; margin-bottom: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>${process.env.EMAIL_NAME}</h1>
            </div>
            <div class="content">
              <h2>❌ Invalid Reset Link</h2>
              <p>This password reset link is invalid or malformed. Please request a new password reset.</p>
            </div>
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
          <title>Reset Link Expired - ${process.env.EMAIL_NAME}</title>
          <style>
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
            .container { max-width: 500px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; text-align: center; }
            .header { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: white; padding: 30px; }
            .header h1 { margin: 0; font-size: 28px; font-weight: 300; }
            .content { padding: 40px; }
            .content h2 { color: #333; margin-bottom: 20px; }
            .content p { color: #666; margin-bottom: 20px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>${process.env.EMAIL_NAME}</h1>
            </div>
            <div class="content">
              <h2>⏰ Reset Link Expired</h2>
              <p>This password reset link has expired or has already been used. Please request a new password reset.</p>
            </div>
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
        <title>Reset Password - ${process.env.EMAIL_NAME}</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
          .container { max-width: 400px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; }
          .header { background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); color: white; padding: 30px; text-align: center; }
          .header h1 { margin: 0; font-size: 28px; font-weight: 300; }
          .content { padding: 40px; }
          .form-group { margin-bottom: 20px; }
          .form-group label { display: block; margin-bottom: 5px; color: #333; font-weight: 500; }
          .form-group input { width: 100%; padding: 12px; border: 2px solid #e5e7eb; border-radius: 5px; font-size: 16px; box-sizing: border-box; }
          .form-group input:focus { outline: none; border-color: #2563eb; }
          .reset-button { width: 100%; background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); color: white; padding: 12px; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; transition: transform 0.2s; }
          .reset-button:hover { transform: translateY(-2px); }
          .reset-button:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
          .message { padding: 10px; border-radius: 5px; margin-bottom: 20px; display: none; }
          .message.success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
          .message.error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
          .password-requirements { font-size: 14px; color: #666; margin-top: 5px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>${process.env.EMAIL_NAME}</h1>
          </div>
          <div class="content">
            <h2 style="color: #333; margin-bottom: 20px; text-align: center;">Reset Your Password</h2>
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
        <title>Reset Error - ${process.env.EMAIL_NAME}</title>
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
          .container { max-width: 500px; background: white; border-radius: 10px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); overflow: hidden; text-align: center; }
          .header { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); color: white; padding: 30px; }
          .header h1 { margin: 0; font-size: 28px; font-weight: 300; }
          .content { padding: 40px; }
          .content h2 { color: #333; margin-bottom: 20px; }
          .content p { color: #666; margin-bottom: 20px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>${process.env.EMAIL_NAME}</h1>
          </div>
          <div class="content">
            <h2>❌ Reset Error</h2>
            <p>An error occurred while loading the password reset form. Please try again or request a new password reset.</p>
          </div>
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