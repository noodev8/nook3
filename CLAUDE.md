# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **The Nook of Welshpool** mobile app project - a Flutter application for ordering buffets and share boxes from a local food business. The project includes both a Flutter mobile client (`nook3_flutter/`) and a server component (`nook3_server/`).

## Core Tech Stack

### Mobile App
- **Flutter** - Cross-platform mobile development framework

### Backend Server
- **Node.js** - JavaScript runtime for server
- **Express.js** - Web framework for Node.js
- **JWT** - JSON Web Tokens for authentication
- **BCrypt** - Password hashing for secure authentication
- **Resend** - Email service for notifications and communications

### Web Platform
- **Next.js** - React framework for website
- **Tailwind CSS** - Utility-first CSS framework for styling

### Development Tools
- **Visual Studio Code** - Primary IDE
- **Claude** - AI development assistant
- **Augment** - AI development tool
- **ChatGPT** - AI development assistant

### Business Context
- Local food business: The Nook of Welshpool (42 High Street, Welshpool, SY21 7JQ)
- Two main offerings:
  - **Share Box**: For 1-4 people (Traditional or Vegetarian daily mix)
  - **Buffet**: For 5+ people (Classic £9.90, Enhanced £10.90, Deluxe £13.90 per head)
- Features: Collection/delivery options, customizable buffets, recyclable packaging

## Development Commands

### Flutter App (nook3_flutter/)
```bash
# Navigate to Flutter project
cd nook3_flutter

# Install dependencies
flutter pub get

# Run the app
flutter run

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Run tests
flutter test

# Analyze code
flutter analyze

# Update dependencies
flutter pub upgrade
```

### Common Flutter Commands
```bash
# Clean build files
flutter clean

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Check for outdated packages
flutter pub outdated

# Hot reload (when running)
r

# Hot restart (when running)
R
```

## Architecture & Code Structure

### Flutter App Structure
- **Entry Point**: `lib/main.dart` - Initializes `NookApp` with Material Design theme
- **Navigation Flow**: Welcome → Main Menu → (Share Box | Buffet Selection) → Cart → Delivery → Confirmation
- **Screen Architecture**: Each screen is a separate StatelessWidget in `lib/screens/`

### Key Screens & Flow
1. `welcome_screen.dart` - App entry with branding
2. `main_menu_screen.dart` - Main hub for choosing Share Box or Buffet
3. `share_box_screen.dart` - Share box selection (Traditional/Vegetarian)
4. `buffet_selection_screen.dart` - Buffet type selection (Classic/Enhanced/Deluxe)
5. `buffet_customization_screen.dart` - Customize buffet contents
6. `cart_screen.dart` - Review and modify order
7. `delivery_options_screen.dart` - Choose collection/delivery
8. `order_confirmation_screen.dart` - Final order summary
9. `order_status_screen.dart` - Track order progress
10. `login_screen.dart` - User authentication

### Design System
- **Color Scheme**: 
  - Primary: Green (from `ColorScheme.fromSeed(seedColor: Colors.green)`)
  - Accent colors: Orange (`#E67E22`), Blue (`#3498DB`), Charcoal (`#2C3E50`)
- **Typography**: Poppins font family (referenced in code, may need font files)
- **Layout**: Material Design 3 with custom styling and gradients
- **Images**: Stored in `assets/images/` including logo and buffet photos

### State Management
- Currently using StatelessWidget architecture
- Navigation using MaterialPageRoute
- No complex state management implemented yet (good opportunity for Provider/Bloc)

### Assets
- **Images**: Logo and buffet photos in `assets/images/`
- **App Icon**: Custom icon at `assets/nook_icon_1024.png`
- **Configuration**: `flutter_launcher_icons` in pubspec.yaml

## Development Notes

### Current Implementation Status
- UI wireframes and screens are mostly complete
- Navigation flow is implemented
- No backend integration yet (server directory exists but appears empty)
- No persistent storage or state management
- Authentication screens exist but not functional

### Key Technical Considerations
- Uses Material Design 3 (`useMaterial3: true`)
- Image error handling implemented with fallback containers
- Responsive design with SafeArea and SingleChildScrollView
- Custom styling with gradients and shadows throughout

### Business Logic Areas
- **Pricing**: Hard-coded in UI (Classic £9.90, Enhanced £10.90, Deluxe £13.90)
- **Menu Items**: Detailed in `docs/project_outline.txt`
- **Validation**: Minimum order quantities (5+ for buffets)
- **Customization**: Remove items but maintain minimums

### Server Development (nook3_server/)
Based on the tech stack, the server should be built with:
```bash
# Navigate to server directory
cd nook3_server

# Initialize Node.js project (if not done)
npm init -y

# Install core dependencies
npm install express bcryptjs jsonwebtoken resend

# Install development dependencies
npm install --save-dev nodemon

# Run development server
npm run dev
```

### Expected Server Structure
```
nook3_server/
├── package.json
├── server.js (or app.js)
├── routes/
├── middleware/
├── models/
├── controllers/
└── config/
```

### Next Development Steps
When extending this codebase:
1. **Backend Setup**: Initialize Node.js/Express server with JWT auth and BCrypt
2. **Email Integration**: Set up Resend for order confirmations and notifications
3. **State Management**: Add Provider/Bloc/Riverpod to Flutter app
4. **API Integration**: Connect Flutter app to Express.js backend
5. **Authentication**: Implement JWT-based login system
6. **Data Persistence**: Add database (MongoDB/PostgreSQL) for orders and users
7. **Payment Processing**: Integrate payment gateway
8. **Order Management**: Real-time order tracking system
9. **Website**: Develop Next.js website with Tailwind CSS
10. **Push Notifications**: Mobile notifications for order updates

### Testing
- Test files exist in `test/` directory
- Run `flutter test` to execute tests
- Consider widget tests for complex UI components
- Integration tests for user flows

### Deployment
- Android: Uses Kotlin for MainActivity
- iOS: Swift-based with proper provisioning setup needed
- App icons configured via flutter_launcher_icons
- No CI/CD pipeline currently configured

## Development Environment

### Server Configuration
- Express port is 3013