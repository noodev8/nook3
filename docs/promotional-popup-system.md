# Promotional Popup System - Technical Documentation

A smart, user-friendly promotional popup system for Flutter apps with intelligent content tracking and lifecycle management.

## 🎯 Overview

This system displays promotional messages to users in a beautiful popup while respecting user preferences and avoiding annoyance. It only shows content users haven't explicitly acknowledged and automatically handles new content detection.

## ✨ Key Features

- **User-Controlled Dismissal**: "I have seen this" button for explicit acknowledgment
- **Content Change Detection**: Automatically shows popup when promotional content changes
- **Persistent Memory**: Remembers seen content across app sessions
- **Warm Restart Support**: Shows new content when app resumes from background
- **Database-Driven**: Content managed through database settings
- **Elegant UI**: Modern blue-themed design with animations

## 🏗️ Architecture

### Components Added

1. **PromotionTrackingService** - Core tracking logic
2. **Modified MainMenuScreen** - UI and lifecycle integration
3. **Updated StoreInfoService** - Database content fetching
4. **SharedPreferences** - Local storage for seen content

## 📁 File Structure

```
lib/
├── services/
│   ├── promotion_tracking_service.dart    # NEW: Core tracking logic
│   ├── store_info_service.dart           # UPDATED: Added getPromotionalText()
│   └── ...
├── screens/
│   ├── main_menu_screen.dart             # UPDATED: UI + lifecycle integration
│   └── ...
```

## 🔧 Implementation Details

### 1. Database Schema

The system reads from a `system_settings` table:

```sql
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Control the popup:**
- **Enable**: `INSERT INTO system_settings (setting_key, setting_value) VALUES ('promotion', 'Your message here');`
- **Update**: `UPDATE system_settings SET setting_value = 'New message' WHERE setting_key = 'promotion';`
- **Disable**: `DELETE FROM system_settings WHERE setting_key = 'promotion';`

### 2. PromotionTrackingService

**Core tracking logic** (`lib/services/promotion_tracking_service.dart`):

```dart
class PromotionTrackingService {
  // Generate content hash for change detection
  static String _generateHash(String content) { ... }
  
  // Check if user has seen specific content
  static Future<bool> hasSeenPromotion(String text) { ... }
  
  // Mark content as seen (called by "I have seen this" button)
  static Future<void> markPromotionAsSeen(String text) { ... }
  
  // Determine if popup should show
  static Future<bool> shouldShowPromotion(String text) { ... }
}
```

**Key Methods:**
- `shouldShowPromotion()` - Main logic: show if content exists and hasn't been seen
- `markPromotionAsSeen()` - Records user acknowledgment
- `hasSeenPromotion()` - Checks against stored hash list

### 3. Content Hash System

**How it works:**
1. Generate unique hash from promotional text content
2. Store hash in SharedPreferences when user clicks "I have seen this"
3. Compare incoming content hash against stored hashes
4. Show popup only if hash is new (content changed)

**Benefits:**
- Detects any content changes (typo fixes, new offers, etc.)
- Efficient storage (hashes instead of full text)
- Cross-session persistence

### 4. UI Implementation

**Updated MainMenuScreen** with:

```dart
class _MainMenuScreenState extends State<MainMenuScreen> 
    with TickerProviderStateMixin, WidgetsBindingObserver {
  
  // Lifecycle detection for warm restart
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPromotionalOnResume();
    }
  }
  
  // Smart loading with tracking
  Future<void> _loadPromotionalSettings() async {
    final text = await StoreInfoService.getPromotionalText();
    final shouldShow = await PromotionTrackingService.shouldShowPromotion(text);
    setState(() {
      _showAdvert = text.isNotEmpty && shouldShow;
    });
  }
}
```

**New UI Elements:**
- Removed tap-to-dismiss from promotional text
- Added prominent "I have seen this" button
- Kept X button and background tap for quick dismiss (but these don't mark as seen)

### 5. Warm Restart Detection

**App Lifecycle Integration:**
```dart
// Monitors app state changes
WidgetsBinding.instance.addObserver(this);

// Checks for new content when app resumes
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _checkPromotionalOnResume();
  }
}
```

## 🎮 User Experience Flow

### First Visit
1. App loads → checks database for 'promotion' key
2. If found → generates content hash
3. Compares against seen hashes (empty initially)
4. Shows popup with slide + wobble animation
5. User clicks "I have seen this" → hash stored locally

### Return Visit (Same Content)
1. App loads → checks database
2. Generates hash for same content
3. Finds hash in seen list → popup hidden
4. User continues to main menu

### Content Update
1. Admin updates promotional message in database
2. App loads → generates new hash for changed content
3. New hash not in seen list → popup shows again
4. User sees updated message

### Warm Restart
1. App backgrounded, then resumed
2. `didChangeAppLifecycleState` triggered
3. Checks for new promotional content
4. Shows popup if content changed while backgrounded

## 🔧 Dependencies Required

Add to `pubspec.yaml`:
```yaml
dependencies:
  shared_preferences: ^2.5.3  # For local storage
  http: ^1.1.0               # For API calls (likely already present)
```

## 🚀 Deployment to Another Project

### Step 1: Copy Core Files
```bash
# Copy the tracking service
cp lib/services/promotion_tracking_service.dart [target_project]/lib/services/

# Copy relevant parts of store_info_service.dart
# Focus on getPromotionalText() method
```

### Step 2: Database Setup
```sql
-- Add to your database schema
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add promotional content
INSERT INTO system_settings (setting_key, setting_value, description) 
VALUES ('promotion', 'Your promotional message here', 'Main promotional popup content');
```

### Step 3: Integrate with Target Screen
```dart
// Add to your main screen's imports
import '../services/promotion_tracking_service.dart';

// Make screen lifecycle-aware
class _YourScreenState extends State<YourScreen> with WidgetsBindingObserver {
  
  bool _showPromotion = false;
  String _promotionText = '';
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPromotionalSettings();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  // Core integration method
  Future<void> _loadPromotionalSettings() async {
    final text = await YourApiService.getPromotionalText();
    final shouldShow = await PromotionTrackingService.shouldShowPromotion(text);
    
    setState(() {
      _showPromotion = text.isNotEmpty && shouldShow;
      _promotionText = text;
    });
  }
}
```

### Step 4: Copy UI Components
- Copy the `_buildLeafletOverlay()` method
- Copy the `_markAsSeenAndDismiss()` method
- Add the popup overlay to your screen's Stack
- Customize colors/styling to match your app

## 🎨 Customization Options

### Visual Styling
```dart
// Change theme colors
const Color primaryColor = Color(0xFF3498DB);  // Blue theme
const Color accentColor = Color(0xFF2980B9);   // Darker blue

// Modify button text
child: Text('I have seen this'),  // Change to your preference

// Adjust animations
duration: Duration(milliseconds: 800),  // Slide speed
angle: 0.05,  // Wobble intensity
```

### Behavior Tuning
```dart
// Change content hash algorithm (in PromotionTrackingService)
static String _generateHash(String content) {
  // Use different hashing method if needed
}

// Modify warm restart sensitivity
const threshold = 30 * 1000;  // 30 seconds between app sessions
```

## 🛠️ Advanced Features

### Analytics Integration
```dart
// Add to _markAsSeenAndDismiss()
await AnalyticsService.trackEvent('promotion_acknowledged', {
  'content_hash': PromotionTrackingService._generateHash(_promotionalText),
  'timestamp': DateTime.now().toIso8601String(),
});
```

### A/B Testing Support
```dart
// Modify getPromotionalText() to include variant
static Future<Map<String, dynamic>> getPromotionalContent() async {
  return {
    'text': await getStoreInfoValue('promotion'),
    'variant': await getStoreInfoValue('promotion_variant') ?? 'default',
  };
}
```

### Multiple Promotion Types
```dart
// Support different promotion categories
static Future<bool> shouldShowPromotion(String text, String category) async {
  final key = 'seen_promotions_$category';
  // Category-specific tracking
}
```

## 🔍 Debugging

**Debug prints included:**
```dart
print('DEBUG: promotionalText = $promotionalText');
print('DEBUG: shouldShow = $shouldShow');
print('DEBUG: App resumed from background');
```

**Common troubleshooting:**
- **Popup not showing**: Check database has 'promotion' key with content
- **Always showing**: Clear SharedPreferences: `PromotionTrackingService.clearSeenPromotions()`
- **Not showing on resume**: Verify WidgetsBindingObserver is properly set up

## 📊 Benefits

1. **User-Friendly**: Explicit consent model respects user choice
2. **Efficient**: Content hashing prevents unnecessary storage
3. **Flexible**: Easy to update content without app updates
4. **Smart**: Automatic new content detection
5. **Persistent**: Works across app sessions and updates
6. **Performance**: Minimal overhead, caching built-in

This system provides a robust foundation for promotional content delivery that can be easily adapted to different apps and use cases! 🚀

## 🔄 Implementation Summary for Nook Project

### Files Created/Modified

1. **NEW**: `lib/services/promotion_tracking_service.dart`
   - Content hashing and tracking logic
   - SharedPreferences integration
   - Smart showing logic

2. **UPDATED**: `lib/services/store_info_service.dart`
   - Added `getPromotionalText()` method
   - Database field validation

3. **UPDATED**: `lib/screens/main_menu_screen.dart`
   - Added WidgetsBindingObserver for lifecycle detection
   - Integrated promotion tracking service
   - Updated UI with "I have seen this" button
   - Warm restart detection logic

### Database Changes

```sql
-- Control promotional popup through this table
-- setting_key = 'promotion' controls visibility
-- setting_value = the message content
```

### User Flow in Nook App

1. **App Start**: Checks for 'promotion' in system_settings
2. **First View**: Shows popup if content exists and unseen
3. **User Action**: "I have seen this" marks content as acknowledged
4. **Content Update**: New database content triggers popup again
5. **App Resume**: Checks for new content when returning from background

This implementation is specifically tailored for The Nook of Welshpool project but can be easily extracted for other Flutter applications.