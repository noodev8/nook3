/*
=======================================================================================================================================
API Route: Categories
=======================================================================================================================================
Method: POST
Purpose: Handle all category-related requests including fetching all categories, getting by ID, and getting by type
=======================================================================================================================================
Request Payload:
{
  "action": "get_all|get_by_id|get_by_type",  // string, required - action to perform
  "category_id": 1,                           // integer, optional - required for get_by_id
  "category_type": "share box"                // string, optional - required for get_by_type
}

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Categories retrieved successfully",    // string, description
  "categories": [...],                              // array, list of categories (for get_all, get_by_type)
  "category": {...}                                 // object, single category (for get_by_id)
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"MISSING_ACTION"
"INVALID_ACTION"
"MISSING_CATEGORY_ID"
"INVALID_CATEGORY_ID"
"CATEGORY_NOT_FOUND"
"MISSING_CATEGORY_TYPE"
"SERVER_ERROR"
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const db = require('../utils/database');

// Main categories endpoint - handles all category operations
router.post('/', async (req, res) => {
  
  try {
    const { action, category_id, category_type } = req.body;
    
    // Validate action parameter
    if (!action) {
      return res.status(400).json({
        return_code: 'MISSING_ACTION',
        message: 'Action parameter is required'
      });
    }

    switch (action) {
      case 'get_all':
        const categories = await db.getAllCategories();
        return res.json({
          return_code: 'SUCCESS',
          message: 'Categories retrieved successfully',
          categories: categories
        });

      case 'get_by_id':
        if (!category_id) {
          return res.status(400).json({
            return_code: 'MISSING_CATEGORY_ID',
            message: 'Category ID is required for get_by_id action'
          });
        }

        const categoryId = parseInt(category_id);
        if (isNaN(categoryId)) {
          return res.status(400).json({
            return_code: 'INVALID_CATEGORY_ID',
            message: 'Invalid category ID'
          });
        }

        const category = await db.getCategoryById(categoryId);
        
        if (!category) {
          return res.status(404).json({
            return_code: 'CATEGORY_NOT_FOUND',
            message: 'Category not found'
          });
        }

        return res.json({
          return_code: 'SUCCESS',
          message: 'Category retrieved successfully',
          category: category
        });

      case 'get_by_type':
        if (!category_type || category_type.trim() === '') {
          return res.status(400).json({
            return_code: 'MISSING_CATEGORY_TYPE',
            message: 'Category type is required for get_by_type action'
          });
        }

        const categoriesByType = await db.getCategoriesByType(category_type);
        return res.json({
          return_code: 'SUCCESS',
          message: 'Categories retrieved successfully',
          categories: categoriesByType
        });

      default:
        return res.status(400).json({
          return_code: 'INVALID_ACTION',
          message: 'Invalid action. Supported actions: get_all, get_by_id, get_by_type'
        });
    }
  } catch (error) {
    console.error('Error in categories route:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to process category request'
    });
  }
});

module.exports = router;