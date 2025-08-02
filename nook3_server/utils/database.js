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
    const { order_id, category_id, quantity, unit_price, total_price, notes } = categoryData;
    
    const query = `
      INSERT INTO order_categories (order_id, category_id, quantity, unit_price, total_price, notes, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
      RETURNING *
    `;
    const result = await pool.query(query, [order_id, category_id, quantity, unit_price, total_price, notes]);
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
      GROUP BY oc.id, oc.quantity, oc.unit_price, oc.total_price, oc.notes, 
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
  }
};

module.exports = db;