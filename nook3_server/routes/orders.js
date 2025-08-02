/*
=======================================================================================================================================
API Route: Order Submission
=======================================================================================================================================
Method: POST
Purpose: Convert cart to confirmed order and update database with correct total
=======================================================================================================================================
Request Payload:
{
  "user_id": 123,                                // integer, optional - for logged in users
  "session_id": "abc123",                        // string, optional - for guest users
  "delivery_type": "delivery|collection",        // string, required
  "delivery_address": "123 Main St",             // string, optional (required for delivery)
  "phone_number": "+44123456789",                // string, required
  "email": "user@example.com",                   // string, required
  "requested_date": "2024-08-03",                // date, required
  "requested_time": "12:30",                     // time, required
  "special_instructions": "Leave at door"        // string, optional
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Order submitted successfully",
  "order_id": 123,
  "order_number": "NK000123",
  "total_amount": 59.50,
  "estimated_time": "45 minutes",
  "email_sent": true
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"MISSING_USER_SESSION"
"MISSING_REQUIRED_FIELDS"
"CART_EMPTY"
"SERVER_ERROR"
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const db = require('../utils/database');
const { sendOrderConfirmationEmail } = require('../services/emailService');

// Submit order - convert cart to confirmed order
router.post('/submit', async (req, res) => {
  try {
    const { user_id, session_id, delivery_type, delivery_address, phone_number, 
            email, requested_date, requested_time, special_instructions } = req.body;
    
    // Validate user identification
    if (!user_id && !session_id) {
      return res.status(400).json({
        return_code: 'MISSING_USER_SESSION',
        message: 'Either user_id or session_id is required'
      });
    }

    // Validate required fields
    if (!delivery_type || !phone_number || !email || !requested_date || !requested_time) {
      return res.status(400).json({
        return_code: 'MISSING_REQUIRED_FIELDS',
        message: 'delivery_type, phone_number, email, requested_date, and requested_time are required'
      });
    }

    // Validate delivery address if delivery type is delivery
    if (delivery_type === 'delivery' && !delivery_address) {
      return res.status(400).json({
        return_code: 'MISSING_REQUIRED_FIELDS',
        message: 'delivery_address is required for delivery orders'
      });
    }

    // Get cart order
    let cartOrder;
    if (user_id) {
      cartOrder = await db.getCartOrderByUserId(user_id);
    } else {
      cartOrder = await db.getCartOrderBySessionId(session_id);
    }

    if (!cartOrder) {
      return res.status(404).json({
        return_code: 'CART_EMPTY',
        message: 'No cart found for this user'
      });
    }

    // Get cart items to calculate total
    const cartItems = await db.getCartItemsWithDetails(cartOrder.id);
    if (cartItems.length === 0) {
      return res.status(404).json({
        return_code: 'CART_EMPTY',
        message: 'Cart is empty'
      });
    }

    // Calculate total amount
    const totalAmount = cartItems.reduce((total, item) => total + (parseFloat(item.total_price) || 0), 0);

    // Update cart order to confirmed order
    const confirmedOrder = await db.updateOrderToConfirmed({
      orderId: cartOrder.id,
      totalAmount: totalAmount,
      deliveryType: delivery_type,
      deliveryAddress: delivery_address,
      phoneNumber: phone_number,
      email: email,
      requestedDate: requested_date,
      requestedTime: requested_time,
      specialInstructions: special_instructions
    });

    // Estimate delivery/collection time based on order size
    const estimatedTime = calculateEstimatedTime(cartItems);

    // Send order confirmation email using order ID as order number
    try {
      const emailResult = await sendOrderConfirmationEmail(email, {
        orderNumber: `NK${confirmedOrder.id.toString().padStart(6, '0')}`, // Format: NK000123
        totalAmount: totalAmount,
        deliveryType: delivery_type,
        deliveryAddress: delivery_address,
        requestedDate: requested_date,
        requestedTime: requested_time,
        estimatedTime: estimatedTime,
        cartItems: cartItems,
        customerName: null, // We don't have customer name in current flow
        phoneNumber: phone_number
      });

      if (!emailResult.success) {
        console.error('Failed to send order confirmation email:', emailResult.error);
        // Continue with success response even if email fails
      }
    } catch (emailError) {
      console.error('Error sending order confirmation email:', emailError);
      // Continue with success response even if email fails
    }

    return res.json({
      return_code: 'SUCCESS',
      message: 'Order submitted successfully',
      order_id: confirmedOrder.id,
      order_number: `NK${confirmedOrder.id.toString().padStart(6, '0')}`,
      total_amount: totalAmount,
      estimated_time: estimatedTime,
      email_sent: true // Always return true to not worry users about email delivery
    });

  } catch (error) {
    console.error('Error submitting order:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to submit order'
    });
  }
});

// Order number is generated from order ID: NK + 6-digit padded ID (e.g., NK000123)

// Helper function to calculate estimated time
function calculateEstimatedTime(cartItems) {
  const itemCount = cartItems.reduce((total, item) => total + item.quantity, 0);
  
  // Base time: 30 minutes
  // Add 5 minutes per buffet portion
  const baseTime = 30;
  const additionalTime = itemCount * 5;
  const totalMinutes = Math.min(baseTime + additionalTime, 90); // Cap at 90 minutes
  
  return `${totalMinutes} minutes`;
}

module.exports = router;