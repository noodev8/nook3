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

/**
 * Send order confirmation email
 */
async function sendOrderConfirmationEmail(email, orderDetails) {
  const { orderNumber, totalAmount, deliveryType, deliveryAddress, requestedDate, 
          requestedTime, estimatedTime, cartItems, customerName, phoneNumber } = orderDetails;
  
  // Format the cart items for display
  const itemsHtml = cartItems.map(item => `
    <tr style="border-bottom: 1px solid #e0e0e0;">
      <td style="padding: 12px 0; color: #000000; font-weight: 500;">${item.category_name}</td>
      <td style="padding: 12px 0; text-align: center; color: #666666;">x${item.quantity}</td>
      <td style="padding: 12px 0; text-align: right; color: #000000; font-weight: 500;">£${parseFloat(item.total_price).toFixed(2)}</td>
    </tr>
  `).join('');

  const itemsText = cartItems.map(item => 
    `${item.category_name} x${item.quantity} - £${parseFloat(item.total_price).toFixed(2)}`
  ).join('\n');

  const deliveryInfo = deliveryType === 'delivery' 
    ? `<strong>Delivery Address:</strong><br>${deliveryAddress}`
    : `<strong>Collection from:</strong><br>The Nook of Welshpool<br>42 High Street, Welshpool, SY21 7JQ`;

  const deliveryInfoText = deliveryType === 'delivery'
    ? `Delivery Address: ${deliveryAddress}`
    : `Collection from: The Nook of Welshpool, 42 High Street, Welshpool, SY21 7JQ`;

  const htmlTemplate = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Order Confirmation - ${process.env.EMAIL_NAME}</title>
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
          background: #f8f9fa;
        }
        .header h1 { 
          margin: 0; 
          font-size: 22px; 
          font-weight: 600; 
          color: #000000;
        }
        .success-badge {
          display: inline-block;
          background: #27AE60;
          color: white;
          padding: 6px 12px;
          border-radius: 4px;
          font-size: 14px;
          font-weight: 500;
          margin-top: 8px;
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
        .order-summary {
          background: #f8f9fa;
          border: 1px solid #e0e0e0;
          border-radius: 8px;
          padding: 24px;
          margin: 24px 0;
        }
        .order-details {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 16px;
          margin-bottom: 24px;
        }
        .detail-item {
          border-bottom: 1px solid #e0e0e0;
          padding-bottom: 8px;
        }
        .detail-label {
          font-size: 14px;
          color: #666666;
          font-weight: 500;
        }
        .detail-value {
          font-size: 16px;
          color: #000000;
          font-weight: 600;
          margin-top: 4px;
        }
        .items-table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 20px;
        }
        .items-header {
          background: #e0e0e0;
          font-weight: 600;
          font-size: 14px;
          color: #000000;
        }
        .items-header th {
          padding: 12px 0;
          text-align: left;
        }
        .total-row {
          background: #f0f0f0;
          font-weight: 600;
          font-size: 16px;
        }
        .total-row td {
          padding: 16px 0;
          border-top: 2px solid #000000;
        }
        .footer { 
          padding: 20px 30px; 
          color: #666666; 
          font-size: 14px;
          border-top: 1px solid #e0e0e0;
          background: #f8f9fa;
        }
        .notice { 
          padding: 16px; 
          margin: 24px 0; 
          font-size: 14px;
          border: 1px solid #e0e0e0;
          background: #fafafa;
          border-radius: 6px;
        }
        .contact-info {
          margin-top: 24px;
          padding: 16px;
          background: #f8f9fa;
          border-radius: 6px;
          border: 1px solid #e0e0e0;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>The Nook of Welshpool</h1>
          <div class="success-badge">✓ Order Confirmed</div>
        </div>
        <div class="content">
          <h2>Thank you for your order!</h2>
          <p>Hi ${customerName || 'there'},</p>
          <p>We've received your order and are preparing it now. Here are your order details:</p>
          
          <div class="order-summary">
            <div class="order-details">
              <div class="detail-item">
                <div class="detail-label">Order Number</div>
                <div class="detail-value">${orderNumber}</div>
              </div>
              <div class="detail-item">
                <div class="detail-label">Estimated Ready Time</div>
                <div class="detail-value">${estimatedTime}</div>
              </div>
              <div class="detail-item">
                <div class="detail-label">Date & Time</div>
                <div class="detail-value">${requestedDate} at ${requestedTime}</div>
              </div>
              <div class="detail-item">
                <div class="detail-label">Order Type</div>
                <div class="detail-value">${deliveryType === 'delivery' ? 'Delivery' : 'Collection'}</div>
              </div>
            </div>
            
            <div style="margin-bottom: 20px;">
              ${deliveryInfo}
            </div>
            
            <table class="items-table">
              <thead class="items-header">
                <tr>
                  <th>Item</th>
                  <th style="text-align: center;">Qty</th>
                  <th style="text-align: right;">Price</th>
                </tr>
              </thead>
              <tbody>
                ${itemsHtml}
                <tr class="total-row">
                  <td colspan="2"><strong>Total</strong></td>
                  <td style="text-align: right;"><strong>£${parseFloat(totalAmount).toFixed(2)}</strong></td>
                </tr>
              </tbody>
            </table>
          </div>
          
          <div class="notice">
            <strong>What's next?</strong><br>
            ${deliveryType === 'delivery' 
              ? `We'll deliver your order to the address provided. Please ensure someone is available to receive it.`
              : `Please arrive at the stated collection time. Ring the bell if the shop appears closed.`
            }
          </div>
          
          <div class="contact-info">
            <strong>Need to make changes or have questions?</strong><br>
            Phone: 01938 123456<br>
            Email: info@nookofwelshpool.co.uk<br>
            <em>Please have your order number (${orderNumber}) ready when contacting us.</em>
          </div>
        </div>
        <div class="footer">
          <p>Thank you for choosing The Nook of Welshpool!</p>
          <p>&copy; 2025 The Nook of Welshpool. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  const textTemplate = `
The Nook of Welshpool - Order Confirmation

Thank you for your order!

Hi ${customerName || 'there'},

We've received your order and are preparing it now. Here are your order details:

ORDER DETAILS:
Order Number: ${orderNumber}
Estimated Ready Time: ${estimatedTime}
Date & Time: ${requestedDate} at ${requestedTime}
Order Type: ${deliveryType === 'delivery' ? 'Delivery' : 'Collection'}

${deliveryInfoText}

YOUR ORDER:
${itemsText}

Total: £${parseFloat(totalAmount).toFixed(2)}

WHAT'S NEXT:
${deliveryType === 'delivery' 
  ? `We'll deliver your order to the address provided. Please ensure someone is available to receive it.`
  : `Please arrive at the stated collection time. Ring the bell if the shop appears closed.`
}

NEED HELP?
Phone: 01938 123456
Email: info@nookofwelshpool.co.uk
Please have your order number (${orderNumber}) ready when contacting us.

Thank you for choosing The Nook of Welshpool!

© 2025 The Nook of Welshpool. All rights reserved.
  `;

  try {
    const result = await resend.emails.send({
      from: `The Nook of Welshpool <${process.env.EMAIL_FROM}>`,
      to: email,
      subject: `Order Confirmation - ${orderNumber}`,
      html: htmlTemplate,
      text: textTemplate
    });

    console.log('Order confirmation email sent successfully:', result);
    return { success: true, messageId: result.id };
  } catch (error) {
    console.error('Error sending order confirmation email:', error);
    return { success: false, error: error.message };
  }
}

module.exports = {
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendOrderConfirmationEmail
};