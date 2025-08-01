# The Nook API Server

Express.js backend server for The Nook of Welshpool mobile app.

## Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Start production server
npm start
```

## Environment Setup

1. Copy `.env.example` to `.env`
2. Update environment variables as needed
3. For Resend email service, add your API key to `RESEND_API_KEY`

## API Endpoints

### Health Check
- `GET /` - Server status
- `GET /api/health` - API health check

### Planned Endpoints
- `POST /api/auth/login` - User authentication
- `POST /api/auth/register` - User registration
- `GET /api/menu` - Menu items and pricing
- `POST /api/orders` - Create new order
- `GET /api/orders/:id` - Get order details
- `PUT /api/orders/:id` - Update order status

## Tech Stack

- **Express.js** - Web framework
- **JWT** - Authentication tokens
- **BCrypt** - Password hashing
- **Resend** - Email service
- **CORS** - Cross-origin requests
- **dotenv** - Environment variables

## Development

Server runs on `http://localhost:3000` by default.

Use `npm run dev` for hot-reloading during development.