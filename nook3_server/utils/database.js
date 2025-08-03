const { Pool } = require('pg');

// Create database connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Test database connection
pool.on('connect', () => {
  console.log('Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('Database connection error:', err);
});

// User database functions
const db = {
  // Find user by email
  async findUserByEmail(email) {
    const query = 'SELECT * FROM app_user WHERE email = $1';
    const result = await pool.query(query, [email]);
    return result.rows[0] || null;
  },

  // Find user by ID
  async findUserById(id) {
    const query = 'SELECT * FROM app_user WHERE id = $1';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  },

  // Create new user
  async createUser(userData) {
    const { email, phone, display_name, password_hash, is_anonymous = false } = userData;
    const query = `
      INSERT INTO app_user (email, phone, display_name, password_hash, is_anonymous, email_verified, created_at, last_active_at)
      VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      RETURNING *
    `;
    const result = await pool.query(query, [email, phone, display_name, password_hash, is_anonymous, false]);
    return result.rows[0];
  },

  // Update user's last active timestamp
  async updateLastActive(userId) {
    const query = 'UPDATE app_user SET last_active_at = CURRENT_TIMESTAMP WHERE id = $1';
    await pool.query(query, [userId]);
  },

  // Set auth token for user (for email verification or password reset)
  async setAuthToken(userId, token, expiresAt) {
    const query = 'UPDATE app_user SET auth_token = $1, auth_token_expires = $2 WHERE id = $3';
    await pool.query(query, [token, expiresAt, userId]);
  },

  // Find user by auth token
  async findByAuthToken(token) {
    const query = 'SELECT * FROM app_user WHERE auth_token = $1 AND auth_token_expires > CURRENT_TIMESTAMP';
    const result = await pool.query(query, [token]);
    return result.rows[0] || null;
  },

  // Clear auth token (after successful use)
  async clearAuthToken(userId) {
    const query = 'UPDATE app_user SET auth_token = NULL, auth_token_expires = NULL WHERE id = $1';
    await pool.query(query, [userId]);
  },

  // Mark email as verified
  async markEmailVerified(userId) {
    const query = 'UPDATE app_user SET email_verified = TRUE WHERE id = $1';
    await pool.query(query, [userId]);
  },

  // Update password and clear token
  async updatePassword(userId, passwordHash) {
    const query = 'UPDATE app_user SET password_hash = $1, auth_token = NULL, auth_token_expires = NULL WHERE id = $2';
    await pool.query(query, [passwordHash, userId]);
  },

  // Update display name
  async updateDisplayName(userId, displayName) {
    const query = 'UPDATE app_user SET display_name = $1 WHERE id = $2';
    await pool.query(query, [displayName, userId]);
  },

  // Clean up expired tokens (optional maintenance function)
  async cleanExpiredTokens() {
    const query = 'UPDATE app_user SET auth_token = NULL, auth_token_expires = NULL WHERE auth_token_expires < CURRENT_TIMESTAMP';
    const result = await pool.query(query);
    return result.rowCount;
  },

  // Category database functions
  
  // Get all active product categories
  async getAllCategories() {
    const query = 'SELECT * FROM product_categories WHERE is_active = TRUE ORDER BY name';
    const result = await pool.query(query);
    return result.rows;
  },

  // Get category by ID
  async getCategoryById(id) {
    const query = 'SELECT * FROM product_categories WHERE id = $1 AND is_active = TRUE';
    const result = await pool.query(query, [id]);
    return result.rows[0] || null;
  },

  // Get category by name (case-insensitive)
  async getCategoryByName(name) {
    const query = 'SELECT * FROM product_categories WHERE LOWER(name) = LOWER($1) AND is_active = TRUE';
    const result = await pool.query(query, [name]);
    return result.rows[0] || null;
  },

  // Get categories by type (share box or buffet)
  async getCategoriesByType(type) {
    const query = 'SELECT * FROM product_categories WHERE LOWER(name) LIKE LOWER($1) AND is_active = TRUE ORDER BY name';
    const searchPattern = `%${type}%`;
    const result = await pool.query(query, [searchPattern]);
    return result.rows;
  },

  // Get menu items for a specific category
  async getMenuItemsByCategory(categoryId) {
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
    const result = await pool.query(query, [categoryId]);
    return result.rows;
  },

  // Cart/Order database functions

  // Create new order
  async createOrder(orderData) {
    const { app_user_id, guest_email, total_amount, order_status, 
            delivery_type, requested_date, requested_time, delivery_address, 
            delivery_notes, special_instructions } = orderData;
    
    const query = `
      INSERT INTO orders (app_user_id, guest_email, total_amount, order_status, 
                         delivery_type, requested_date, requested_time, delivery_address, 
                         delivery_notes, special_instructions, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, CURRENT_TIMESTAMP)
      RETURNING *
    `;
    const result = await pool.query(query, [
      app_user_id, guest_email, total_amount, order_status,
      delivery_type, requested_date, requested_time, delivery_address,
      delivery_notes, special_instructions
    ]);
    return result.rows[0];
  },

  // Get cart order by user ID
  async getCartOrderByUserId(userId) {
    const query = 'SELECT * FROM orders WHERE app_user_id = $1 AND order_status = $2 ORDER BY created_at DESC LIMIT 1';
    const result = await pool.query(query, [userId, 'cart']);
    return result.rows[0] || null;
  },

  // Get cart order by session ID (stored in guest_email field temporarily)
  async getCartOrderBySessionId(sessionId) {
    const query = 'SELECT * FROM orders WHERE guest_email = $1 AND order_status = $2 ORDER BY created_at DESC LIMIT 1';
    const result = await pool.query(query, [sessionId, 'cart']);
    return result.rows[0] || null;
  },

  // Add order category
  async addOrderCategory(categoryData) {
    const { order_id, category_id, quantity, unit_price, total_price, notes, department_label } = categoryData;
    
    const query = `
      INSERT INTO order_categories (order_id, category_id, quantity, unit_price, total_price, notes, department_label, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)
      RETURNING *
    `;
    const result = await pool.query(query, [order_id, category_id, quantity, unit_price, total_price, notes, department_label]);
    return result.rows[0];
  },

  // Add order item
  async addOrderItem(itemData) {
    const { order_id, order_category_id, menu_item_id } = itemData;
    
    const query = `
      INSERT INTO order_items (order_id, order_category_id, menu_item_id, created_at)
      VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
      RETURNING *
    `;
    const result = await pool.query(query, [order_id, order_category_id, menu_item_id]);
    return result.rows[0];
  },

  // Update order metadata (store additional info like department_label, deluxe_format in notes)
  async updateOrderMetadata(orderCategoryId, metadata) {
    const metadataJson = JSON.stringify(metadata);
    const query = 'UPDATE order_categories SET notes = COALESCE(notes || $1, $1) WHERE id = $2';
    await pool.query(query, [` | Metadata: ${metadataJson}`, orderCategoryId]);
  },

  // Get cart items with full details
  async getCartItemsWithDetails(orderId) {
    const query = `
      SELECT 
        oc.id as order_category_id,
        oc.quantity,
        oc.unit_price,
        oc.total_price,
        oc.notes,
        oc.department_label,
        pc.id as category_id,
        pc.name as category_name,
        pc.description as category_description,
        array_agg(
          json_build_object(
            'id', mi.id,
            'name', mi.name,
            'description', mi.description,
            'is_vegetarian', mi.is_vegetarian
          )
        ) as included_items
      FROM order_categories oc
      JOIN product_categories pc ON pc.id = oc.category_id
      LEFT JOIN order_items oi ON oi.order_category_id = oc.id
      LEFT JOIN menu_items mi ON mi.id = oi.menu_item_id
      WHERE oc.order_id = $1
      GROUP BY oc.id, oc.quantity, oc.unit_price, oc.total_price, oc.notes, oc.department_label,
               pc.id, pc.name, pc.description
      ORDER BY oc.created_at ASC
    `;
    const result = await pool.query(query, [orderId]);
    return result.rows;
  },

  // Delete order items by category
  async deleteOrderItemsByCategory(orderCategoryId) {
    const query = 'DELETE FROM order_items WHERE order_category_id = $1';
    const result = await pool.query(query, [orderCategoryId]);
    return result.rowCount;
  },

  // Delete order category
  async deleteOrderCategory(orderCategoryId, orderId) {
    const query = 'DELETE FROM order_categories WHERE id = $1 AND order_id = $2';
    const result = await pool.query(query, [orderCategoryId, orderId]);
    return result.rowCount > 0;
  },

  // Delete entire order
  async deleteOrder(orderId) {
    // Delete order items first
    await pool.query('DELETE FROM order_items WHERE order_id = $1', [orderId]);
    // Delete order categories
    await pool.query('DELETE FROM order_categories WHERE order_id = $1', [orderId]);
    // Delete order
    const result = await pool.query('DELETE FROM orders WHERE id = $1', [orderId]);
    return result.rowCount > 0;
  },

  // Update order total amount
  async updateOrderTotal(orderId) {
    const query = `
      UPDATE orders 
      SET total_amount = (
        SELECT COALESCE(SUM(total_price), 0) 
        FROM order_categories 
        WHERE order_id = $1
      )
      WHERE id = $1
    `;
    await pool.query(query, [orderId]);
  },

  // Update cart order to pending order
  async updateOrderToConfirmed(orderData) {
    const { orderId, totalAmount, deliveryType, deliveryAddress, deliveryNotes,
            phoneNumber, email, requestedDate, requestedTime, specialInstructions } = orderData;
    
    // Combine requestedDate and requestedTime into a proper timestamp
    // requestedDate comes as YYYY-MM-DD, requestedTime as HH:MM
    const combinedDateTime = `${requestedDate} ${requestedTime}:00`; // Add seconds
    
    const query = `
      UPDATE orders 
      SET total_amount = $2,
          order_status = 'pending',
          delivery_type = $3,
          delivery_address = $4,
          delivery_notes = $5,
          guest_phone = $6,
          guest_email = $7,
          requested_date = $8,
          requested_time = $9::timestamp,
          special_instructions = $10,
          confirmed_at = CURRENT_TIMESTAMP,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;
    
    const result = await pool.query(query, [
      orderId, totalAmount, deliveryType, deliveryAddress, deliveryNotes,
      phoneNumber, email, requestedDate, combinedDateTime, specialInstructions
    ]);
    
    return result.rows[0];
  },

  // Store information functions (using system_settings table)
  
  // Get all store information
  async getAllStoreInfo() {
    const query = 'SELECT setting_key as info_key, setting_value as info_value, description FROM system_settings ORDER BY setting_key';
    const result = await pool.query(query);
    return result.rows;
  },

  // Get specific store information by key
  async getStoreInfoByKey(key) {
    const query = 'SELECT setting_key as info_key, setting_value as info_value, description FROM system_settings WHERE setting_key = $1';
    const result = await pool.query(query, [key]);
    return result.rows[0] || null;
  },

  // Update store information (for admin use)
  async updateStoreInfo(key, value) {
    const query = `
      UPDATE system_settings 
      SET setting_value = $2, updated_at = CURRENT_TIMESTAMP 
      WHERE setting_key = $1 
      RETURNING setting_key as info_key, setting_value as info_value, description
    `;
    const result = await pool.query(query, [key, value]);
    return result.rows[0];
  },

  // Order tracking functions

  // Get order history for a specific user
  async getOrdersByUserId(userId, limit = 20, offset = 0) {
    const query = `
      SELECT 
        o.id,
        o.total_amount,
        o.order_status,
        o.delivery_type,
        o.requested_date,
        o.requested_time,
        o.delivery_address,
        o.special_instructions,
        o.created_at,
        o.confirmed_at,
        o.completed_at,
        COUNT(oc.id) as item_count
      FROM orders o
      LEFT JOIN order_categories oc ON oc.order_id = o.id
      WHERE o.app_user_id = $1 AND o.order_status != 'cart'
      GROUP BY o.id, o.total_amount, o.order_status, o.delivery_type, 
               o.requested_date, o.requested_time, o.delivery_address,
               o.special_instructions, o.created_at, o.confirmed_at, o.completed_at
      ORDER BY o.created_at DESC
      LIMIT $2 OFFSET $3
    `;
    const result = await pool.query(query, [userId, limit, offset]);
    return result.rows;
  },

  // Get specific order with full details for a user
  async getOrderWithDetails(orderId, userId) {
    // First verify the order belongs to the user
    const orderQuery = `
      SELECT 
        o.*,
        COUNT(oc.id) as item_count
      FROM orders o
      LEFT JOIN order_categories oc ON oc.order_id = o.id
      WHERE o.id = $1 AND o.app_user_id = $2 AND o.order_status != 'cart'
      GROUP BY o.id
    `;
    const orderResult = await pool.query(orderQuery, [orderId, userId]);
    
    if (orderResult.rows.length === 0) {
      return null;
    }

    const order = orderResult.rows[0];
    
    // Get order items with details
    order.items = await this.getCartItemsWithDetails(orderId);
    
    return order;
  },


  // Update order status
  async updateOrderStatus(orderId, newStatus, notes = null) {
    // Update the main order status
    const updateQuery = `
      UPDATE orders 
      SET order_status = $2, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `;
    const updateResult = await pool.query(updateQuery, [orderId, newStatus]);
    
    if (updateResult.rows.length > 0) {
      return updateResult.rows[0];
    }
    
    return null;
  }
};

// Export both the db object and the pool for health checks
module.exports = db;
module.exports.pool = pool;