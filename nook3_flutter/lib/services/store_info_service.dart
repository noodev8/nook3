import 'dart:convert';
import '../config/app_config.dart';

class StoreInfoService {
  // Server configuration using AppConfig
  static String get baseUrl => '${AppConfig.baseUrl}/store-info';
  
  // Cache for store info to avoid repeated API calls
  static Map<String, dynamic>? _cachedStoreInfo;
  static DateTime? _lastFetchTime;
  
  /// Get all store information
  static Future<Map<String, dynamic>?> getAllStoreInfo({bool forceRefresh = false}) async {
    // Use cache if available and not forcing refresh and cache is less than 1 hour old
    if (!forceRefresh && 
        _cachedStoreInfo != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inHours < 1) {
      return _cachedStoreInfo;
    }
    
    try {
      final response = await AppConfig.get(Uri.parse(baseUrl));
      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        _cachedStoreInfo = data['store_info'];
        _lastFetchTime = DateTime.now();
        return _cachedStoreInfo;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  
  /// Get specific store information by key
  static Future<String?> getStoreInfoValue(String key) async {
    try {
      final storeInfo = await getAllStoreInfo();
      return storeInfo?[key];
    } catch (e) {
      return null;
    }
  }
  
  /// Convenience methods for commonly used store info
  static Future<String> getStoreName() async {
    return await getStoreInfoValue('business_name') ?? 'The Nook of Welshpool';
  }
  
  static Future<String> getStoreAddress() async {
    return await getStoreInfoValue('business_address') ?? '42 High Street, Welshpool, SY21 7JQ';
  }
  
  static Future<String> getStorePhone() async {
    return await getStoreInfoValue('store_phone') ?? '01938 123456';
  }
  
  static Future<String> getStoreEmail() async {
    return await getStoreInfoValue('store_email') ?? 'info@nookofwelshpool.co.uk';
  }
  
  static Future<Map<String, String>> getOpeningHours() async {
    final storeInfo = await getAllStoreInfo();
    return {
      'Monday - Friday': storeInfo?['opening_hours_mon_fri'] ?? '10:00 AM - 5:00 PM',
      'Saturday': storeInfo?['opening_hours_saturday'] ?? '10:00 AM - 4:00 PM',
      'Sunday': storeInfo?['opening_hours_sunday'] ?? 'Closed',
    };
  }
  
  static Future<String> getCollectionInstructions() async {
    return await getStoreInfoValue('collection_instructions') ?? 
           'Please arrive at the stated collection time. Ring bell if shop appears closed.';
  }
  
  static Future<String> getBusinessDescription() async {
    return await getStoreInfoValue('business_description') ?? 
           'Local food business specializing in buffets and share boxes for groups and events.';
  }
  
  /// Promotional settings - server controlled  
  static Future<String> getPromotionalImagePath() async {
    return await getStoreInfoValue('promotional_image_path') ?? 'assets/images/Leaflet-1.png';
  }
  
  static Future<int> getPromotionalDelayMs() async {
    final value = await getStoreInfoValue('promotional_delay_ms');
    return int.tryParse(value ?? '500') ?? 500;
  }
  
  static Future<int> getPromotionalSlideAnimationMs() async {
    final value = await getStoreInfoValue('promotional_slide_animation_ms');
    return int.tryParse(value ?? '800') ?? 800;
  }
  
  static Future<int> getPromotionalWobbleAnimationMs() async {
    final value = await getStoreInfoValue('promotional_wobble_animation_ms');
    return int.tryParse(value ?? '1200') ?? 1200;
  }
  
  static Future<String> getPromotionalText() async {
    final value = await getStoreInfoValue('promotion');
    // Only show if the 'promotion' setting_key exists in database
    if (value == null) {
      return '';
    }
    return value;
  }
  
  /// Clear cache to force refresh on next request
  static void clearCache() {
    _cachedStoreInfo = null;
    _lastFetchTime = null;
  }
}