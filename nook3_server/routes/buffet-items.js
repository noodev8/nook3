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
const db = require('../utils/database');

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

        // Map buffet type to category ID
        const categoryIdMap = {
          'Classic': 3,
          'Enhanced': 4,
          'Deluxe': 5
        };
        
        const categoryId = categoryIdMap[buffet_type];
        if (!categoryId) {
          return res.status(400).json({
            return_code: 'INVALID_BUFFET_TYPE',
            message: 'Invalid buffet type. Valid types: Classic, Enhanced, Deluxe'
          });
        }

        // Query database for actual menu items for this category
        const buffetItems = await getBuffetItemsFromDatabase(categoryId);
        
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

// Database function to get buffet items for a specific category
async function getBuffetItemsFromDatabase(categoryId) {
  try {
    const query = `
      SELECT 
        mi.id,
        mi.name,
        mi.description,
        mi.item_type,
        mi.is_vegetarian,
        cmi.is_default_included as is_default
      FROM category_menu_items cmi
      JOIN menu_items mi ON mi.id = cmi.menu_item_id
      WHERE cmi.category_id = $1 
        AND mi.is_active = true
      ORDER BY mi.name ASC
    `;
    
    const result = await db.query(query, [categoryId]);
    
    if (result.rows && result.rows.length > 0) {
      return result.rows.map(row => ({
        id: row.id,
        name: row.name,
        description: row.description || '',
        item_type: row.item_type || '',
        is_vegetarian: row.is_vegetarian || false,
        is_default: row.is_default || true
      }));
    } else {
      // If no database items found, return fallback items
      console.log(`No menu items found in database for category ${categoryId}, using fallback`);
      return getFallbackItems();
    }
  } catch (error) {
    console.error('Database error in getBuffetItemsFromDatabase:', error);
    // Return fallback items if database query fails
    return getFallbackItems();
  }
}

// Fallback items when database is unavailable or empty
function getFallbackItems() {
  return [
    { id: 1, name: 'Sandwiches', description: 'Mixed sandwich selection', is_default: true },
    { id: 2, name: 'Quiche', description: 'Freshly baked quiche', is_default: true },
    { id: 3, name: 'Cocktail Sausages', description: 'Mini cocktail sausages', is_default: true },
    { id: 4, name: 'Sausage Rolls', description: 'Homemade sausage rolls', is_default: true },
    { id: 5, name: 'Pork Pies', description: 'Traditional pork pies', is_default: true },
    { id: 6, name: 'Scotch Eggs', description: 'Fresh scotch eggs', is_default: true },
    { id: 7, name: 'Tortillas/Dips', description: 'Tortilla chips with dips', is_default: true },
    { id: 8, name: 'Cakes', description: 'Assorted cakes and desserts', is_default: true }
  ];
}

module.exports = router;