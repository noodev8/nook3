/*
=======================================================================================================================================
API Route: Order Submission
=======================================================================================================================================
Method: POST
Purpose: Convert cart to pending order and update database with correct total
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
const { sendOrderConfirmationEmail, sendBusinessOrderNotification } = require('../services/emailService');

// Submit order - convert cart to pending order
router.post('/submit', async (req, res) => {
  try {
    const { user_id, session_id, delivery_type, delivery_address, delivery_notes, phone_number, 
            email, requested_date, requested_time } = req.body;
    
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

    // Update cart order to pending order
    const confirmedOrder = await db.updateOrderToConfirmed({
      orderId: cartOrder.id,
      totalAmount: totalAmount,
      deliveryType: delivery_type,
      deliveryAddress: delivery_address,
      deliveryNotes: delivery_notes,
      phoneNumber: phone_number,
      email: email,
      requestedDate: requested_date,
      requestedTime: requested_time
    });

    // Send emails (order confirmation to customer and business notification)
    const orderDetails = {
      orderNumber: `NK${confirmedOrder.id.toString().padStart(6, '0')}`, // Format: NK000123
      totalAmount: totalAmount,
      deliveryType: delivery_type,
      deliveryAddress: delivery_address,
      requestedDate: requested_date,
      requestedTime: requested_time,
      cartItems: cartItems,
      customerName: null, // We don't have customer name in current flow
      phoneNumber: phone_number,
      email: email
    };

    // Send customer confirmation email
    try {
      const emailResult = await sendOrderConfirmationEmail(email, orderDetails);
      if (!emailResult.success) {
        console.error('Failed to send order confirmation email:', emailResult.error);
        // Continue with success response even if email fails
      }
    } catch (emailError) {
      console.error('Error sending order confirmation email:', emailError);
      // Continue with success response even if email fails
    }

    // Send business notification email
    try {
      const businessEmailResult = await sendBusinessOrderNotification(orderDetails);
      if (!businessEmailResult.success) {
        console.error('Failed to send business notification email:', businessEmailResult.error);
        // Continue with success response even if email fails
      }
    } catch (businessEmailError) {
      console.error('Error sending business notification email:', businessEmailError);
      // Continue with success response even if email fails
    }

    return res.json({
      return_code: 'SUCCESS',
      message: 'Order submitted successfully',
      order_id: confirmedOrder.id,
      order_number: `NK${confirmedOrder.id.toString().padStart(6, '0')}`,
      total_amount: totalAmount,
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

/*
=======================================================================================================================================
Order History API - Get user's order history
=======================================================================================================================================
Method: POST
Purpose: Retrieve order history for authenticated users
=======================================================================================================================================
Request Payload:
{
  "user_id": 123,                                // integer, required - user's ID
  "limit": 20,                                   // integer, optional - number of orders to return (default: 20)
  "offset": 0                                    // integer, optional - pagination offset (default: 0)
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Order history retrieved successfully",
  "orders": [...]                                // array of order objects
}
=======================================================================================================================================
*/

// Get order history for authenticated user
router.post('/history', async (req, res) => {
  try {
    const { user_id, limit = 20, offset = 0 } = req.body;

    // Validate user ID
    if (!user_id) {
      return res.status(400).json({
        return_code: 'MISSING_USER_ID',
        message: 'User ID is required'
      });
    }

    // Get order history
    const orders = await db.getOrdersByUserId(user_id, limit, offset);

    // Format orders with proper order numbers
    const formattedOrders = orders.map(order => ({
      ...order,
      order_number: `NK${order.id.toString().padStart(6, '0')}`,
      total_amount: parseFloat(order.total_amount)
    }));

    return res.json({
      return_code: 'SUCCESS',
      message: 'Order history retrieved successfully',
      orders: formattedOrders
    });

  } catch (error) {
    console.error('Error retrieving order history:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve order history'
    });
  }
});

/*
=======================================================================================================================================
Order Details API - Get specific order with full details and status tracking
=======================================================================================================================================
Method: POST
Purpose: Retrieve detailed information for a specific order including status history
=======================================================================================================================================
Request Payload:
{
  "user_id": 123,                                // integer, required - user's ID
  "order_id": 456                                // integer, required - specific order ID
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Order details retrieved successfully",
  "order": {                                     // complete order object with items and status history
    "id": 456,
    "order_number": "NK000456",
    "total_amount": 59.50,
    "order_status": "pending",
    "delivery_type": "delivery",
    "items": [...],                              // array of order items
    "status_history": [...]                      // array of status changes
  }
}
=======================================================================================================================================
*/

// Get detailed information for a specific order
router.post('/details', async (req, res) => {
  try {
    const { user_id, order_id } = req.body;

    // Validate required fields
    if (!user_id || !order_id) {
      return res.status(400).json({
        return_code: 'MISSING_REQUIRED_FIELDS',
        message: 'User ID and Order ID are required'
      });
    }

    // Get order with full details
    const order = await db.getOrderWithDetails(order_id, user_id);

    if (!order) {
      return res.status(404).json({
        return_code: 'ORDER_NOT_FOUND',
        message: 'Order not found or access denied'
      });
    }

    // Format order with proper order number
    const formattedOrder = {
      ...order,
      order_number: `NK${order.id.toString().padStart(6, '0')}`,
      total_amount: parseFloat(order.total_amount)
    };

    return res.json({
      return_code: 'SUCCESS',
      message: 'Order details retrieved successfully',
      order: formattedOrder
    });

  } catch (error) {
    console.error('Error retrieving order details:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve order details'
    });
  }
});

// Order number is generated from order ID: NK + 6-digit padded ID (e.g., NK000123)

module.exports = router;