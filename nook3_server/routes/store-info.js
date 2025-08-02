/*
=======================================================================================================================================
API Route: Store Information
=======================================================================================================================================
Method: GET
Purpose: Fetch dynamic store information from database to avoid hardcoded values in app
=======================================================================================================================================

GET /api/store-info
Returns all store information as key-value pairs

GET /api/store-info/:key
Returns specific store information value

Success Response:
{
  "return_code": "SUCCESS",
  "message": "Store information retrieved successfully",
  "store_info": {
    "business_name": "The Nook of Welshpool",
    "business_address": "42 High Street, Welshpool, SY21 7JQ",
    "store_phone": "01938 123456",
    "store_email": "info@nookofwelshpool.co.uk",
    "opening_hours_mon_fri": "10:00 AM - 5:00 PM",
    "opening_hours_saturday": "10:00 AM - 4:00 PM",
    "opening_hours_sunday": "Closed",
    "collection_instructions": "Please arrive at the stated collection time...",
    "business_description": "Local food business specializing in buffets..."
  }
}
=======================================================================================================================================
Return Codes:
"SUCCESS"
"INFO_NOT_FOUND" (for specific key requests)
"SERVER_ERROR"
=======================================================================================================================================
*/

const express = require('express');
const router = express.Router();
const db = require('../utils/database');

// Get all store information
router.get('/', async (req, res) => {
  try {
    const storeInfo = await db.getAllStoreInfo();
    
    // Convert array to key-value object
    const storeInfoMap = {};
    storeInfo.forEach(item => {
      storeInfoMap[item.info_key] = item.info_value;
    });
    
    return res.json({
      return_code: 'SUCCESS',
      message: 'Store information retrieved successfully',
      store_info: storeInfoMap
    });
  } catch (error) {
    console.error('Error fetching store info:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to fetch store information'
    });
  }
});

// Get specific store information by key
router.get('/:key', async (req, res) => {
  try {
    const { key } = req.params;
    const storeInfo = await db.getStoreInfoByKey(key);
    
    if (!storeInfo) {
      return res.status(404).json({
        return_code: 'INFO_NOT_FOUND',
        message: `Store information not found for key: ${key}`
      });
    }
    
    return res.json({
      return_code: 'SUCCESS',
      message: 'Store information retrieved successfully',
      key: storeInfo.info_key,
      value: storeInfo.info_value,
      description: storeInfo.description
    });
  } catch (error) {
    console.error('Error fetching store info:', error);
    res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Failed to fetch store information'
    });
  }
});

module.exports = router;