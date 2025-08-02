/*
=======================================================================================================================================
API Route: Buffet Items
=======================================================================================================================================
Method: POST
Purpose: Handle all buffet items requests for customization based on buffet type
=======================================================================================================================================
Request Payload:
{
  "action": "get_by_buffet_type",                    // string, required - action to perform
  "buffet_type": "Classic|Enhanced|Deluxe"          // string, required - buffet type
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Buffet items retrieved successfully",  // string, description
  "items": [                                         // array, list of buffet items
    {
      "id": 1,                                       // integer, item ID
      "name": "Sandwiches",                          // string, item name
      "description": "Mixed sandwich selection",     // string, item description
      "is_default": true                             // boolean, default included
    }
  ]
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"MISSING_ACTION"
"INVALID_ACTION"
"MISSING_BUFFET_TYPE"
"INVALID_BUFFET_TYPE"
"SERVER_ERROR"
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();

// Main buffet items endpoint - handles all buffet item operations
router.post('/', async (req, res) => {
  try {
    const { action, buffet_type } = req.body;
    
    // Validate action parameter
    if (!action) {
      return res.status(400).json({
        return_code: 'MISSING_ACTION',
        message: 'Action parameter is required'
      });
    }

    switch (action) {
      case 'get_by_buffet_type':
        if (!buffet_type) {
          return res.status(400).json({
            return_code: 'MISSING_BUFFET_TYPE',
            message: 'Buffet type is required for get_by_buffet_type action'
          });
        }

        // Validate buffet type
        const validTypes = ['Classic', 'Enhanced', 'Deluxe'];
        if (!validTypes.includes(buffet_type)) {
          return res.status(400).json({
            return_code: 'INVALID_BUFFET_TYPE',
            message: 'Invalid buffet type. Valid types: Classic, Enhanced, Deluxe'
          });
        }

        // Return buffet items based on type
        const buffetItems = getBuffetItemsByType(buffet_type);
        
        return res.json({
          return_code: 'SUCCESS',
          message: 'Buffet items retrieved successfully',
          items: buffetItems
        });

      default:
        return res.status(400).json({
          return_code: 'INVALID_ACTION',
          message: 'Invalid action. Supported actions: get_by_buffet_type'
        });
    }
  } catch (error) {
    console.error('Error in buffet items route:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to process buffet items request'
    });
  }
});

// Helper function to get buffet items by type
function getBuffetItemsByType(buffetType) {
  const baseItems = [
    { id: 1, name: 'Sandwiches', description: 'Mixed sandwich selection', is_default: true },
    { id: 2, name: 'Quiche', description: 'Freshly baked quiche', is_default: true },
    { id: 3, name: 'Cocktail Sausages', description: 'Mini cocktail sausages', is_default: true },
    { id: 4, name: 'Sausage Rolls', description: 'Homemade sausage rolls', is_default: true },
    { id: 5, name: 'Pork Pies', description: 'Traditional pork pies', is_default: true },
    { id: 6, name: 'Scotch Eggs', description: 'Fresh scotch eggs', is_default: true },
    { id: 7, name: 'Tortillas/Dips', description: 'Tortilla chips with dips', is_default: true },
    { id: 8, name: 'Cakes', description: 'Assorted cakes and desserts', is_default: true }
  ];

  const enhancedItems = [
    { id: 9, name: 'Vegetable Sticks & Dips', description: 'Fresh vegetable sticks with dips', is_default: true },
    { id: 10, name: 'Cheese/Pineapple/Grapes', description: 'Cheese and fruit platter', is_default: true },
    { id: 11, name: 'Bread Sticks', description: 'Crispy bread sticks', is_default: true },
    { id: 12, name: 'Pickles', description: 'Assorted pickles', is_default: true },
    { id: 13, name: 'Coleslaw', description: 'Fresh coleslaw', is_default: true }
  ];

  const deluxeItems = [
    { id: 14, name: 'Greek Salad', description: 'Traditional Greek salad', is_default: true },
    { id: 15, name: 'Potato Salad', description: 'Creamy potato salad', is_default: true },
    { id: 16, name: 'Tomato & Mozzarella Skewers', description: 'Caprese skewers', is_default: true },
    { id: 17, name: 'Fresh Vegetables', description: 'Seasonal fresh vegetables', is_default: true },
    { id: 18, name: 'Premium Dips', description: 'Selection of premium dips', is_default: true }
  ];

  switch (buffetType) {
    case 'Classic':
      return baseItems;
    case 'Enhanced':
      return [...baseItems, ...enhancedItems];
    case 'Deluxe':
      return [...baseItems, ...enhancedItems, ...deluxeItems];
    default:
      return baseItems;
  }
}

module.exports = router;