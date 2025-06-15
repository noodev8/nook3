# The Nook of Welshpool - Wireframe Summary

## Project Overview
A mobile application for ordering buffets and share boxes from The Nook of Welshpool. The app allows customers to order for collection or delivery with customization options.

## Business Requirements (from project brief)
- **Share Box**: For 1-4 people (Traditional or Vegetarian)
- **Buffet**: For 5+ people with three tiers:
  - Classic Buffet: £9.90 per head
  - Enhanced Buffet: £10.90 per head  
  - Deluxe Buffet: £13.90 per head
- **Features**: Item removal, department labeling, collection/delivery options
- **Deluxe Options**: Mixed (75% Sandwiches), All Sandwiches, or All Wraps

## Wireframe Screens Created

### 1. Welcome Screen (`welcome_screen.dart`)
- **Purpose**: App landing page with branding
- **Features**: 
  - App logo and business information
  - Login/Register button
  - Continue as Guest option
  - Contact information display

### 2. Login Screen (`login_screen.dart`)
- **Purpose**: User authentication
- **Features**:
  - Toggle between Login/Register modes
  - Email, password, and name fields
  - Skip option for guest users
  - Form validation placeholders

### 3. Main Menu Screen (`main_menu_screen.dart`)
- **Purpose**: Choose between Share Box or Buffet
- **Features**:
  - Two main options with detailed descriptions
  - Pricing information
  - Visual icons and cards
  - Eco-friendly messaging

### 4. Share Box Screen (`share_box_screen.dart`)
- **Purpose**: Select Traditional or Vegetarian share box
- **Features**:
  - Two share box options with descriptions
  - Quantity selector (1-10)
  - Visual selection indicators
  - Add to cart functionality

### 5. Buffet Selection Screen (`buffet_selection_screen.dart`)
- **Purpose**: Choose buffet type (Classic/Enhanced/Deluxe)
- **Features**:
  - Three buffet options with full descriptions
  - Pricing per head display
  - Detailed ingredient lists
  - Navigation to customization

### 6. Buffet Customization Screen (`buffet_customization_screen.dart`)
- **Purpose**: Customize selected buffet
- **Features**:
  - Number of people selector (minimum 5)
  - Item removal with minimum 1 requirement
  - Department labeling
  - Special notes field
  - Deluxe format selection (Mixed/Sandwiches/Wraps)
  - Real-time price calculation

### 7. Cart Screen (`cart_screen.dart`)
- **Purpose**: Review selected items
- **Features**:
  - Item list with details and pricing
  - Remove items functionality
  - Department labels and notes display
  - Total calculation
  - Proceed to delivery options

### 8. Delivery Options Screen (`delivery_options_screen.dart`)
- **Purpose**: Choose collection or delivery
- **Features**:
  - Collection option with store details
  - Delivery option with address input
  - Date and time selection
  - Contact phone number field
  - Store hours display

### 9. Order Confirmation Screen (`order_confirmation_screen.dart`)
- **Purpose**: Final order review before submission
- **Features**:
  - Complete order summary
  - Delivery/collection details
  - Important information display
  - Submit order button
  - Total cost confirmation

### 10. Order Status Screen (`order_status_screen.dart`)
- **Purpose**: Order confirmation and tracking
- **Features**:
  - Order number display
  - Estimated time
  - Status timeline (Received → Preparing → Ready)
  - Contact information for changes
  - Place another order option

## Technical Implementation

### Architecture
- **Framework**: Flutter with Material Design 3
- **Structure**: Individual screen files with self-contained logic
- **Navigation**: Standard Flutter navigation with MaterialPageRoute
- **State Management**: StatefulWidget for interactive screens

### Design Principles
- **Clean UI**: Material Design 3 with green color scheme
- **Accessibility**: Clear labels and intuitive navigation
- **Responsive**: Proper spacing and sizing for mobile devices
- **User-Friendly**: Visual feedback and clear call-to-action buttons

### Data Flow
1. User selects items → Cart
2. Cart → Delivery Options
3. Delivery Options → Order Confirmation
4. Order Confirmation → Order Status
5. Order Status → Back to Main Menu

## Key Features Implemented

### Business Logic Placeholders
- ✅ Share Box selection (Traditional/Vegetarian)
- ✅ Buffet tier selection with pricing
- ✅ Item customization and removal
- ✅ Department labeling
- ✅ Special notes
- ✅ Deluxe format options
- ✅ Collection vs Delivery
- ✅ Date/time selection
- ✅ Order tracking status

### UI/UX Features
- ✅ Consistent branding and colors
- ✅ Visual selection indicators
- ✅ Real-time price calculations
- ✅ Form validation feedback
- ✅ Loading states and confirmations
- ✅ Responsive card layouts
- ✅ Icon-based navigation

## Next Steps for Development

### Backend Integration
- API endpoints for menu items and pricing
- User authentication system
- Order management system
- Payment processing integration
- Real-time order tracking

### Enhanced Features
- User profiles and order history
- Push notifications for order updates
- GPS delivery tracking
- Loyalty program integration
- Admin panel for order management

### Testing
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows
- Performance testing

## File Structure
```
nook3_flutter/lib/
├── main.dart                           # App entry point
└── screens/
    ├── welcome_screen.dart             # Landing page
    ├── login_screen.dart               # Authentication
    ├── main_menu_screen.dart           # Main options
    ├── share_box_screen.dart           # Share box selection
    ├── buffet_selection_screen.dart    # Buffet type selection
    ├── buffet_customization_screen.dart # Buffet customization
    ├── cart_screen.dart                # Cart review
    ├── delivery_options_screen.dart    # Delivery/collection
    ├── order_confirmation_screen.dart  # Final review
    └── order_status_screen.dart        # Order tracking
```

This wireframe provides a complete user journey from app launch to order completion, covering all requirements from the project brief while maintaining a clean, intuitive user experience.
