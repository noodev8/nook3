/*
=======================================================================================================================================
API Route: Cart/Basket Operations
=======================================================================================================================================
Method: POST
Purpose: Handle cart operations including add item, get cart, delete item, and clear cart
=======================================================================================================================================
Request Payload:
{
  "action": "add|get|delete|clear",              // string, required - action to perform
  "user_id": 123,                                // integer, optional - for logged in users
  "session_id": "abc123",                        // string, optional - for guest users
  "category_id": 3,                              // integer, required for add - buffet type
  "quantity": 5,                                 // integer, required for add - number of people
  "unit_price": 9.90,                           // decimal, required for add - price per head
  "department_label": "Marketing Team",          // string, optional for add
  "notes": "Special requirements",               // string, optional for add
  "deluxe_format": "Mixed",                      // string, optional for add - deluxe buffets only
  "included_items": [1, 2, 3],                  // array of integers, required for add - menu item IDs
  "order_category_id": 456                       // integer, required for delete - which cart item to remove
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Item added to cart successfully",
  "cart_items": [...],                           // array, current cart contents
  "total_amount": 59.50                          // decimal, total cart value
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"MISSING_ACTION"
"INVALID_ACTION"
"MISSING_USER_SESSION"
"MISSING_REQUIRED_FIELDS"
"CATEGORY_NOT_FOUND"
"CART_EMPTY"
"ITEM_NOT_FOUND"
"SERVER_ERROR"
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const db = require('../utils/database');

// Main cart endpoint - handles all cart operations
router.post('/', async (req, res) => {
  try {
    const { action, user_id, session_id, category_id, quantity, unit_price, 
            department_label, notes, deluxe_format, included_items, order_category_id } = req.body;
    
    // Validate action parameter
    if (!action) {
      return res.status(400).json({
        return_code: 'MISSING_ACTION',
        message: 'Action parameter is required'
      });
    }

    // Validate user identification (either user_id or session_id required)
    if (!user_id && !session_id) {
      return res.status(400).json({
        return_code: 'MISSING_USER_SESSION',
        message: 'Either user_id or session_id is required'
      });
    }

    switch (action) {
      case 'add':
        return await addItemToCart(req.body, res);
      
      case 'get':
        return await getCartItems(req.body, res);
      
      case 'delete':
        return await deleteCartItem(req.body, res);
      
      case 'clear':
        return await clearCart(req.body, res);

      case 'validation':
        return await getCartValidation(req.body, res);

      default:
        return res.status(400).json({
          return_code: 'INVALID_ACTION',
          message: 'Invalid action. Supported actions: add, get, delete, clear, validation'
        });
    }
  } catch (error) {
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to process cart request'
    });
  }
});

// Add item to cart
async function addItemToCart(data, res) {
  const { user_id, session_id, category_id, quantity, unit_price, 
          department_label, notes, deluxe_format, included_items } = data;

  // Validate required fields
  if (!category_id || !quantity || !unit_price || !included_items) {
    return res.status(400).json({
      return_code: 'MISSING_REQUIRED_FIELDS',
      message: 'category_id, quantity, unit_price, and included_items are required'
    });
  }

  // Verify category exists
  const category = await db.getCategoryById(category_id);
  if (!category) {
    return res.status(404).json({
      return_code: 'CATEGORY_NOT_FOUND',
      message: 'Category not found'
    });
  }

  // Get or create cart order
  let cartOrder = await getOrCreateCartOrder(user_id, session_id);
  
  // Calculate total price
  const total_price = quantity * unit_price;

  // Add order category
  const orderCategory = await db.addOrderCategory({
    order_id: cartOrder.id,
    category_id: category_id,
    quantity: quantity,
    unit_price: unit_price,
    total_price: total_price,
    notes: notes || null,
    department_label: department_label || null
  });

  // Add selected menu items
  for (const menu_item_id of included_items) {
    await db.addOrderItem({
      order_id: cartOrder.id,
      order_category_id: orderCategory.id,
      menu_item_id: menu_item_id
    });
  }

  // Store additional metadata in order notes if needed (only deluxe_format now)
  if (deluxe_format) {
    const metadata = {
      deluxe_format: deluxe_format
    };
    await db.updateOrderMetadata(orderCategory.id, metadata);
  }

  // Return updated cart
  const cartItems = await getCartContents(user_id, session_id);
  const totalAmount = calculateCartTotal(cartItems);

  return res.json({
    return_code: 'SUCCESS',
    message: 'Item added to cart successfully',
    cart_items: cartItems,
    total_amount: totalAmount
  });
}

// Get cart items
async function getCartItems(data, res) {
  const { user_id, session_id } = data;

  const cartItems = await getCartContents(user_id, session_id);
  const totalAmount = calculateCartTotal(cartItems);

  return res.json({
    return_code: 'SUCCESS',
    message: 'Cart retrieved successfully',
    cart_items: cartItems,
    total_amount: totalAmount
  });
}

// Delete cart item
async function deleteCartItem(data, res) {
  const { user_id, session_id, order_category_id } = data;

  if (!order_category_id) {
    return res.status(400).json({
      return_code: 'MISSING_REQUIRED_FIELDS',
      message: 'order_category_id is required'
    });
  }

  // Verify item belongs to user's cart
  const cartOrder = await getCartOrderForUser(user_id, session_id);
  if (!cartOrder) {
    return res.status(404).json({
      return_code: 'CART_EMPTY',
      message: 'Cart is empty'
    });
  }

  // Delete order items first (foreign key constraint)
  await db.deleteOrderItemsByCategory(order_category_id);
  
  // Delete order category
  const deleted = await db.deleteOrderCategory(order_category_id, cartOrder.id);
  
  if (!deleted) {
    return res.status(404).json({
      return_code: 'ITEM_NOT_FOUND',
      message: 'Cart item not found'
    });
  }

  // Return updated cart
  const cartItems = await getCartContents(user_id, session_id);
  const totalAmount = calculateCartTotal(cartItems);

  return res.json({
    return_code: 'SUCCESS',
    message: 'Item removed from cart successfully',
    cart_items: cartItems,
    total_amount: totalAmount
  });
}

// Clear entire cart
async function clearCart(data, res) {
  const { user_id, session_id } = data;

  const cartOrder = await getCartOrderForUser(user_id, session_id);
  if (cartOrder) {
    await db.deleteOrder(cartOrder.id);
  }

  return res.json({
    return_code: 'SUCCESS',
    message: 'Cart cleared successfully',
    cart_items: [],
    total_amount: 0
  });
}

// Get cart validation info (minimum quantities per category)
async function getCartValidation(data, res) {
  try {
    // Get all categories with their minimum quantities
    const categories = await db.getAllCategories();
    
    return res.json({
      return_code: 'SUCCESS',
      message: 'Validation info retrieved successfully',
      categories: categories.map(cat => ({
        id: cat.id,
        name: cat.name,
        minimum_quantity: cat.minimum_quantity || 1
      }))
    });
  } catch (error) {
    return res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to retrieve validation info'
    });
  }
}

// Helper function to get or create cart order
async function getOrCreateCartOrder(user_id, session_id) {
  let cartOrder = await getCartOrderForUser(user_id, session_id);
  
  if (!cartOrder) {
    // Create new cart order (order_number column removed from schema)
    cartOrder = await db.createOrder({
      app_user_id: user_id || null,
      guest_email: session_id || null, // Using guest_email field for session_id temporarily
      total_amount: 0,
      order_status: 'cart',
      delivery_type: 'pending',
      requested_date: new Date(),
      requested_time: new Date()
    });
  }
  
  return cartOrder;
}

// Helper function to get cart order for user
async function getCartOrderForUser(user_id, session_id) {
  if (user_id) {
    return await db.getCartOrderByUserId(user_id);
  } else {
    return await db.getCartOrderBySessionId(session_id);
  }
}

// Helper function to get cart contents
async function getCartContents(user_id, session_id) {
  const cartOrder = await getCartOrderForUser(user_id, session_id);
  if (!cartOrder) {
    return [];
  }

  return await db.getCartItemsWithDetails(cartOrder.id);
}

// Helper function to calculate cart total
function calculateCartTotal(cartItems) {
  return cartItems.reduce((total, item) => total + (item.total_price || 0), 0);
}

// Note: Cart items use temporary order numbers that will be replaced with proper order numbers
// when the cart is converted to an actual order during checkout

module.exports = router;