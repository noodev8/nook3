const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Import routes
const authRoutes = require('./routes/auth');
const categoriesRoutes = require('./routes/categories');
const buffetItemsRoutes = require('./routes/buffet-items');
const cartRoutes = require('./routes/cart');
const orderRoutes = require('./routes/orders');

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/buffet-items', buffetItemsRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);

// Basic health check route
app.get('/', (req, res) => {
  res.json({ 
    message: 'The Nook of Welshpool API Server',
    status: 'Running',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// API health check with database test
app.get('/api/health', async (req, res) => {
  try {
    // Test database connection
    const db = require('./utils/database');
    await db.pool.query('SELECT 1 as test');
    
    res.json({ 
      status: 'healthy',
      service: 'nook3-api',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Health check database error:', error);
    res.status(500).json({ 
      status: 'unhealthy',
      service: 'nook3-api',
      database: 'disconnected',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// Version check route for app startup
app.post('/api/version-check', (req, res) => {
  try {
    const currentVersion = req.body.app_version;
    const requiredVersion = process.env.REQUIRED_APP_VERSION || '1.0.0';

    // Check if app_version is provided
    if (!currentVersion) {
      return res.status(400).json({
        return_code: 'MISSING_APP_VERSION',
        message: 'App version is required'
      });
    }

    // Compare versions
    if (!isVersionValid(currentVersion, requiredVersion)) {
      return res.status(200).json({
        return_code: 'APP_UPDATE_REQUIRED',
        message: 'Please update your app to continue using this service',
        required_version: requiredVersion,
        current_version: currentVersion
      });
    }

    // Version is valid
    return res.status(200).json({
      return_code: 'SUCCESS',
      message: 'App version is up to date',
      current_version: currentVersion,
      required_version: requiredVersion
    });
  } catch (error) {
    console.error('Version check error:', error);
    return res.status(500).json({
      return_code: 'SERVER_ERROR',
      message: 'Internal server error'
    });
  }
});

/**
 * Compare semantic versions (e.g., "1.2.3")
 * Returns true if current version >= required version
 */
function isVersionValid(current, required) {
  const currentParts = current.split('.').map(Number);
  const requiredParts = required.split('.').map(Number);

  // Pad arrays to same length
  while (currentParts.length < requiredParts.length) currentParts.push(0);
  while (requiredParts.length < currentParts.length) requiredParts.push(0);

  for (let i = 0; i < currentParts.length; i++) {
    if (currentParts[i] > requiredParts[i]) return true;
    if (currentParts[i] < requiredParts[i]) return false;
  }

  return true; // Versions are equal
}

// Placeholder API routes structure
app.post('/api/menu', (req, res) => {
  res.json({ return_code: 'SUCCESS', message: 'Menu routes - Coming Soon' });
});

app.post('/api/orders', (req, res) => {
  res.json({ return_code: 'SUCCESS', message: 'Orders routes - Coming Soon' });
});

app.post('/api/users', (req, res) => {
  res.json({ return_code: 'SUCCESS', message: 'Users routes - Coming Soon' });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Route not found',
    path: req.originalUrl,
    method: req.method
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;