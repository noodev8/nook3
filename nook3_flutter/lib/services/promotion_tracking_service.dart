import 'package:shared_preferences/shared_preferences.dart';

class PromotionTrackingService {
  static const String _seenPromotionsKey = 'seen_promotions';
  static const String _lastAppStartKey = 'last_app_start';
  
  /// Generate a simple hash for promotional content
  static String _generateHash(String content) {
    int hash = 0;
    for (int i = 0; i < content.length; i++) {
      hash = ((hash << 5) - hash + content.codeUnitAt(i)) & 0xffffffff;
    }
    return hash.toString();
  }
  
  /// Check if a promotional message has been seen (user clicked "I have seen this")
  static Future<bool> hasSeenPromotion(String promotionalText) async {
    if (promotionalText.isEmpty) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final seenPromotions = prefs.getStringList(_seenPromotionsKey) ?? [];
    final contentHash = _generateHash(promotionalText);
    
    return seenPromotions.contains(contentHash);
  }
  
  /// Mark a promotional message as seen
  static Future<void> markPromotionAsSeen(String promotionalText) async {
    if (promotionalText.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final seenPromotions = prefs.getStringList(_seenPromotionsKey) ?? [];
    final contentHash = _generateHash(promotionalText);
    
    if (!seenPromotions.contains(contentHash)) {
      seenPromotions.add(contentHash);
      await prefs.setStringList(_seenPromotionsKey, seenPromotions);
    }
  }
  
  /// Check if this is a fresh app start (not just resume from background)
  static Future<bool> isAppStart() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAppStart = prefs.getInt(_lastAppStartKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Consider it a fresh start if more than 30 seconds have passed
    // This helps distinguish between app start and quick resume
    const threshold = 30 * 1000; // 30 seconds in milliseconds
    return (now - lastAppStart) > threshold;
  }
  
  /// Record that the app has started
  static Future<void> recordAppStart() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_lastAppStartKey, now);
  }
  
  /// Determine if promotional popup should be shown
  static Future<bool> shouldShowPromotion(String promotionalText) async {
    if (promotionalText.isEmpty) return false;
    
    // Always show if user hasn't seen this specific content
    final hasSeenThis = await hasSeenPromotion(promotionalText);
    return !hasSeenThis;
  }
  
  /// Clear all seen promotions (for testing or reset purposes)
  static Future<void> clearSeenPromotions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seenPromotionsKey);
  }
  
  /// Get debug info about seen promotions
  static Future<List<String>> getSeenPromotionsDebug() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_seenPromotionsKey) ?? [];
  }
}