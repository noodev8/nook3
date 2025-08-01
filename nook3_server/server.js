const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Basic health check route
app.get('/', (req, res) => {
  res.json({ 
    message: 'The Nook of Welshpool API Server',
    status: 'Running',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// API health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    service: 'nook3-api',
    timestamp: new Date().toISOString()
  });
});

// Placeholder API routes structure
app.get('/api/auth', (req, res) => {
  res.json({ message: 'Auth routes - Coming Soon' });
});

app.get('/api/menu', (req, res) => {
  res.json({ message: 'Menu routes - Coming Soon' });
});

app.get('/api/orders', (req, res) => {
  res.json({ message: 'Orders routes - Coming Soon' });
});

app.get('/api/users', (req, res) => {
  res.json({ message: 'Users routes - Coming Soon' });
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