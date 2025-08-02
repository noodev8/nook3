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
  }
};

module.exports = db;