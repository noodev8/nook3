const { Resend } = require('resend');

const resend = new Resend(process.env.RESEND_API_KEY);

/**
 * Send email verification email
 */
async function sendVerificationEmail(email, token) {
  const verificationUrl = `${process.env.EMAIL_VERIFICATION_URL}/api/auth/verify-email?token=${token}`;
  
  const htmlTemplate = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Verify Your Email - ${process.env.EMAIL_NAME}</title>
      <style>
        body { 
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; 
          line-height: 1.6; 
          margin: 0; 
          padding: 20px; 
          background: #f5f5f5;
          color: #333;
        }
        .container { 
          max-width: 600px; 
          margin: 0 auto; 
          background: white; 
          border-radius: 8px; 
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          overflow: hidden;
        }
        .header { 
          background: #f8f9fa; 
          padding: 30px; 
          text-align: center; 
          border-bottom: 1px solid #e9ecef;
        }
        .header h1 { 
          margin: 0; 
          font-size: 24px; 
          font-weight: 600; 
          color: #333;
        }
        .content { 
          padding: 40px; 
        }
        .content h2 { 
          color: #333; 
          margin-bottom: 20px; 
          font-size: 20px;
          font-weight: 500;
        }
        .content p { 
          color: #666; 
          margin-bottom: 20px; 
          font-size: 16px;
        }
        .verify-button { 
          display: inline-block; 
          background: #0066cc; 
          color: white; 
          padding: 14px 28px; 
          text-decoration: none; 
          border-radius: 4px; 
          font-weight: 500; 
          font-size: 16px;
          margin: 20px 0;
        }
        .footer { 
          background: #f8f9fa; 
          padding: 20px; 
          text-align: center; 
          color: #666; 
          font-size: 14px;
          border-top: 1px solid #e9ecef;
        }
        .expiry-notice { 
          background: #fff3cd; 
          color: #856404; 
          padding: 12px; 
          border-radius: 4px; 
          margin: 20px 0; 
          font-size: 14px;
          border: 1px solid #ffeaa7;
        }
        .url-fallback {
          margin-top: 30px; 
          font-size: 14px; 
          color: #666;
          word-break: break-all;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>${process.env.EMAIL_NAME}</h1>
        </div>
        <div class="content">
          <h2>Verify Your Email Address</h2>
          <p>Welcome to ${process.env.EMAIL_NAME}! Please click the button below to verify your email address and complete your registration.</p>
          <p><a href="${verificationUrl}" class="verify-button">Verify Email Address</a></p>
          <div class="expiry-notice">
            This verification link will expire in 24 hours for security reasons.
          </div>
          <div class="url-fallback">
            If the button doesn't work, you can copy and paste this link into your browser:<br>
            <a href="${verificationUrl}">${verificationUrl}</a>
          </div>
        </div>
        <div class="footer">
          <p>If you didn't create an account with ${process.env.EMAIL_NAME}, you can safely ignore this email.</p>
          <p>&copy; 2025 ${process.env.EMAIL_NAME}. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const textTemplate = `
    Welcome to ${process.env.EMAIL_NAME}!
    
    Please verify your email address by clicking the link below:
    ${verificationUrl}
    
    This verification link will expire in 24 hours for security reasons.
    
    If you didn't create an account with ${process.env.EMAIL_NAME}, you can safely ignore this email.
    
    © 2025 ${process.env.EMAIL_NAME}. All rights reserved.
  `;

  try {
    const result = await resend.emails.send({
      from: `${process.env.EMAIL_NAME} <${process.env.EMAIL_FROM}>`,
      to: email,
      subject: `Verify your email address - ${process.env.EMAIL_NAME}`,
      html: htmlTemplate,
      text: textTemplate
    });

    console.log('Verification email sent successfully:', result);
    return { success: true, messageId: result.id };
  } catch (error) {
    console.error('Error sending verification email:', error);
    return { success: false, error: error.message };
  }
}

/**
 * Send password reset email
 */
async function sendPasswordResetEmail(email, token) {
  const resetUrl = `${process.env.EMAIL_VERIFICATION_URL}/api/auth/reset-password?token=${token}`;
  
  const htmlTemplate = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Reset Your Password - ${process.env.EMAIL_NAME}</title>
      <style>
        body { 
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; 
          line-height: 1.6; 
          margin: 0; 
          padding: 20px; 
          background: #f5f5f5;
          color: #333;
        }
        .container { 
          max-width: 600px; 
          margin: 0 auto; 
          background: white; 
          border-radius: 8px; 
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
          overflow: hidden;
        }
        .header { 
          background: #f8f9fa; 
          padding: 30px; 
          text-align: center; 
          border-bottom: 1px solid #e9ecef;
        }
        .header h1 { 
          margin: 0; 
          font-size: 24px; 
          font-weight: 600; 
          color: #333;
        }
        .content { 
          padding: 40px; 
        }
        .content h2 { 
          color: #333; 
          margin-bottom: 20px; 
          font-size: 20px;
          font-weight: 500;
        }
        .content p { 
          color: #666; 
          margin-bottom: 20px; 
          font-size: 16px;
        }
        .reset-button { 
          display: inline-block; 
          background: #0066cc; 
          color: white; 
          padding: 14px 28px; 
          text-decoration: none; 
          border-radius: 4px; 
          font-weight: 500; 
          font-size: 16px;
          margin: 20px 0;
        }
        .footer { 
          background: #f8f9fa; 
          padding: 20px; 
          text-align: center; 
          color: #666; 
          font-size: 14px;
          border-top: 1px solid #e9ecef;
        }
        .security-notice { 
          background: #fff3cd; 
          color: #856404; 
          padding: 12px; 
          border-radius: 4px; 
          margin: 20px 0; 
          font-size: 14px;
          border: 1px solid #ffeaa7;
        }
        .warning { 
          background: #f8d7da; 
          color: #721c24; 
          padding: 12px; 
          border-radius: 4px; 
          margin: 20px 0; 
          font-size: 14px;
          border: 1px solid #f5c6cb;
        }
        .url-fallback {
          margin-top: 30px; 
          font-size: 14px; 
          color: #666;
          word-break: break-all;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>${process.env.EMAIL_NAME}</h1>
        </div>
        <div class="content">
          <h2>Reset Your Password</h2>
          <p>We received a request to reset your password for your ${process.env.EMAIL_NAME} account.</p>
          <p><a href="${resetUrl}" class="reset-button">Reset Password</a></p>
          <div class="security-notice">
            This password reset link will expire in 1 hour for security reasons.
          </div>
          <div class="warning">
            If you didn't request this password reset, please ignore this email. Your account remains secure.
          </div>
          <div class="url-fallback">
            If the button doesn't work, you can copy and paste this link into your browser:<br>
            <a href="${resetUrl}">${resetUrl}</a>
          </div>
        </div>
        <div class="footer">
          <p>For security reasons, this link can only be used once and will expire soon.</p>
          <p>&copy; 2025 ${process.env.EMAIL_NAME}. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const textTemplate = `
    Reset Your Password - ${process.env.EMAIL_NAME}
    
    We received a request to reset your password for your ${process.env.EMAIL_NAME} account.
    
    Click the link below to reset your password:
    ${resetUrl}
    
    This password reset link will expire in 1 hour for security reasons.
    
    If you didn't request this password reset, please ignore this email. Your account remains secure.
    
    For security reasons, this link can only be used once and will expire soon.
    
    © 2025 ${process.env.EMAIL_NAME}. All rights reserved.
  `;

  try {
    const result = await resend.emails.send({
      from: `${process.env.EMAIL_NAME} <${process.env.EMAIL_FROM}>`,
      to: email,
      subject: `Reset your password - ${process.env.EMAIL_NAME}`,
      html: htmlTemplate,
      text: textTemplate
    });

    console.log('Password reset email sent successfully:', result);
    return { success: true, messageId: result.id };
  } catch (error) {
    console.error('Error sending password reset email:', error);
    return { success: false, error: error.message };
  }
}

module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail
};