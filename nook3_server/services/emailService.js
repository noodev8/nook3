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
          background: #ffffff;
          color: #000000;
        }
        .container { 
          max-width: 600px; 
          margin: 0 auto; 
          background: #ffffff; 
          border: 1px solid #e0e0e0;
        }
        .header { 
          padding: 30px; 
          text-align: left; 
          border-bottom: 1px solid #e0e0e0;
        }
        .header h1 { 
          margin: 0; 
          font-size: 22px; 
          font-weight: 600; 
          color: #000000;
        }
        .content { 
          padding: 30px; 
        }
        .content h2 { 
          color: #000000; 
          margin: 0 0 24px 0; 
          font-size: 18px;
          font-weight: 600;
        }
        .content p { 
          color: #444444; 
          margin: 0 0 20px 0; 
          font-size: 16px;
        }
        .verify-button { 
          display: inline-block; 
          background: #000000; 
          color: #ffffff; 
          padding: 12px 24px; 
          text-decoration: none; 
          font-weight: 500; 
          font-size: 16px;
          margin: 24px 0;
          border: 2px solid #000000;
        }
        .verify-button:hover {
          background: #ffffff;
          color: #000000;
        }
        .footer { 
          padding: 20px 30px; 
          color: #666666; 
          font-size: 14px;
          border-top: 1px solid #e0e0e0;
        }
        .notice { 
          padding: 16px; 
          margin: 24px 0; 
          font-size: 14px;
          border: 1px solid #e0e0e0;
          background: #fafafa;
        }
        .url-fallback {
          margin-top: 24px; 
          font-size: 14px; 
          color: #666666;
          word-break: break-all;
          line-height: 1.5;
        }
        .url-fallback a {
          color: #000000;
          text-decoration: underline;
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
          <p>Please click the button below to verify your email address and complete your registration.</p>
          
          <p><a href="${verificationUrl}" class="verify-button">Verify Email Address</a></p>
          
          <div class="notice">
            <strong>Important:</strong> This verification link will expire in 24 hours for security reasons.
          </div>
          
          <div class="url-fallback">
            If the button doesn't work, copy and paste this link into your browser:<br>
            <a href="${verificationUrl}">${verificationUrl}</a>
          </div>
        </div>
        <div class="footer">
          <p>If you didn't create an account with ${process.env.EMAIL_NAME}, please ignore this email.</p>
          <p>&copy; 2025 ${process.env.EMAIL_NAME}. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const textTemplate = `
${process.env.EMAIL_NAME} - Email Verification Required

Please verify your email address by visiting the link below:
${verificationUrl}

IMPORTANT: This verification link will expire in 24 hours for security reasons.

If you didn't create an account with ${process.env.EMAIL_NAME}, please ignore this email.

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
          background: #ffffff;
          color: #000000;
        }
        .container { 
          max-width: 600px; 
          margin: 0 auto; 
          background: #ffffff; 
          border: 1px solid #e0e0e0;
        }
        .header { 
          padding: 30px; 
          text-align: left; 
          border-bottom: 1px solid #e0e0e0;
        }
        .header h1 { 
          margin: 0; 
          font-size: 22px; 
          font-weight: 600; 
          color: #000000;
        }
        .content { 
          padding: 30px; 
        }
        .content h2 { 
          color: #000000; 
          margin: 0 0 24px 0; 
          font-size: 18px;
          font-weight: 600;
        }
        .content p { 
          color: #444444; 
          margin: 0 0 20px 0; 
          font-size: 16px;
        }
        .reset-button { 
          display: inline-block; 
          background: #000000; 
          color: #ffffff; 
          padding: 12px 24px; 
          text-decoration: none; 
          font-weight: 500; 
          font-size: 16px;
          margin: 24px 0;
          border: 2px solid #000000;
        }
        .reset-button:hover {
          background: #ffffff;
          color: #000000;
        }
        .footer { 
          padding: 20px 30px; 
          color: #666666; 
          font-size: 14px;
          border-top: 1px solid #e0e0e0;
        }
        .notice { 
          padding: 16px; 
          margin: 24px 0; 
          font-size: 14px;
          border: 1px solid #e0e0e0;
          background: #fafafa;
        }
        .security-info {
          margin: 24px 0;
          padding: 16px;
          border: 1px solid #e0e0e0;
          background: #fafafa;
          font-size: 14px;
        }
        .url-fallback {
          margin-top: 24px; 
          font-size: 14px; 
          color: #666666;
          word-break: break-all;
          line-height: 1.5;
        }
        .url-fallback a {
          color: #000000;
          text-decoration: underline;
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
          
          <div class="notice">
            <strong>Important:</strong> This password reset link will expire in 1 hour for security reasons.
          </div>
          
          <div class="security-info">
            <strong>Security Notice:</strong> If you didn't request this password reset, please ignore this email. Your account remains secure.
          </div>
          
          <div class="url-fallback">
            If the button doesn't work, copy and paste this link into your browser:<br>
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
${process.env.EMAIL_NAME} - Password Reset Request

We received a request to reset your password for your ${process.env.EMAIL_NAME} account.

Click the link below to reset your password:
${resetUrl}

IMPORTANT: This password reset link will expire in 1 hour for security reasons.

SECURITY NOTICE: If you didn't request this password reset, please ignore this email. Your account remains secure.

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