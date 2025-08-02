import 'dart:convert';
import '../config/app_config.dart';

class CategoryService {
  // Server configuration using AppConfig
  static String get baseUrl => '${AppConfig.baseUrl}/categories';
  
  /// Get all product categories
  static Future<CategoryResult> getCategories() async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_all',
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final List<ProductCategory> categories = (data['categories'] as List)
            .map((categoryJson) => ProductCategory.fromJson(categoryJson))
            .toList();
        
        return CategoryResult(
          success: true,
          message: data['message'],
          categories: categories,
        );
      } else {
        return CategoryResult(
          success: false,
          message: data['message'] ?? 'Failed to load categories',
        );
      }
    } catch (e) {
      return CategoryResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get category by ID
  static Future<CategoryResult> getCategoryById(int id) async {
    print('[DEBUG] getCategoryById($id) - Starting API call');
    final stopwatch = Stopwatch()..start();
    
    try {
      print('[DEBUG] Making POST request to: $baseUrl');
      final response = await AppConfig.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_by_id',
          'category_id': id,
        }),
      );
      
      stopwatch.stop();
      print('[DEBUG] getCategoryById($id) - API response received in ${stopwatch.elapsedMilliseconds}ms');
      print('[DEBUG] Response status: ${response.statusCode}');
      print('[DEBUG] Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final category = ProductCategory.fromJson(data['category']);
        print('[DEBUG] Category $id parsed successfully: ${category.name}, price: ${category.pricePerHead}');
        
        return CategoryResult(
          success: true,
          message: data['message'],
          categories: [category],
        );
      } else {
        print('[DEBUG] API returned error for category $id: ${data['message']}');
        return CategoryResult(
          success: false,
          message: data['message'] ?? 'Category not found',
        );
      }
    } catch (e) {
      stopwatch.stop();
      print('[DEBUG] getCategoryById($id) - Exception after ${stopwatch.elapsedMilliseconds}ms: $e');
      return CategoryResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get categories by type
  static Future<CategoryResult> getCategoriesByType(String type) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_by_type',
          'category_type': type,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final List<ProductCategory> categories = (data['categories'] as List)
            .map((categoryJson) => ProductCategory.fromJson(categoryJson))
            .toList();
        
        return CategoryResult(
          success: true,
          message: data['message'],
          categories: categories,
        );
      } else {
        return CategoryResult(
          success: false,
          message: data['message'] ?? 'Failed to load categories',
        );
      }
    } catch (e) {
      return CategoryResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get categories for share boxes specifically using IDs
  static Future<Map<String, double>> getShareBoxPrices() async {
    try {
      // Fetch Traditional Share Box (ID: 1) and Vegetarian Share Box (ID: 2)
      final traditionalResult = await getCategoryById(1);
      final vegetarianResult = await getCategoryById(2);
      
      final Map<String, double> prices = {};
      
      // Get Traditional price
      if (traditionalResult.success && traditionalResult.categories != null && traditionalResult.categories!.isNotEmpty) {
        prices['Traditional'] = traditionalResult.categories!.first.pricePerHead ?? 5.00;
      } else {
        prices['Traditional'] = 5.00; // Fallback price
      }
      
      // Get Vegetarian price
      if (vegetarianResult.success && vegetarianResult.categories != null && vegetarianResult.categories!.isNotEmpty) {
        prices['Vegetarian'] = vegetarianResult.categories!.first.pricePerHead ?? 4.00;
      } else {
        prices['Vegetarian'] = 4.00; // Fallback price
      }
      
      return prices;
    } catch (e) {
      // Return fallback prices if anything goes wrong
      return {
        'Traditional': 5.00,
        'Vegetarian': 4.00,
      };
    }
  }

  /// Get categories for buffets specifically using IDs
  static Future<Map<String, double>> getBuffetPrices() async {
    print('[DEBUG] getBuffetPrices() - Starting buffet price fetch');
    final stopwatch = Stopwatch()..start();
    
    try {
      print('[DEBUG] Fetching Classic Buffet (ID: 3)');
      final classicStart = Stopwatch()..start();
      final classicResult = await getCategoryById(3);
      classicStart.stop();
      print('[DEBUG] Classic fetch took: ${classicStart.elapsedMilliseconds}ms');
      
      print('[DEBUG] Fetching Enhanced Buffet (ID: 4)');
      final enhancedStart = Stopwatch()..start();
      final enhancedResult = await getCategoryById(4);
      enhancedStart.stop();
      print('[DEBUG] Enhanced fetch took: ${enhancedStart.elapsedMilliseconds}ms');
      
      print('[DEBUG] Fetching Deluxe Buffet (ID: 5)');
      final deluxeStart = Stopwatch()..start();
      final deluxeResult = await getCategoryById(5);
      deluxeStart.stop();
      print('[DEBUG] Deluxe fetch took: ${deluxeStart.elapsedMilliseconds}ms');
      
      final Map<String, double> prices = {};
      
      // Get Classic price
      if (classicResult.success && classicResult.categories != null && classicResult.categories!.isNotEmpty) {
        prices['Classic'] = classicResult.categories!.first.pricePerHead ?? 9.90;
        print('[DEBUG] Classic price from DB: ${prices['Classic']}');
      } else {
        prices['Classic'] = 9.90; // Fallback price
        print('[DEBUG] Classic using fallback price: ${prices['Classic']}');
      }
      
      // Get Enhanced price
      if (enhancedResult.success && enhancedResult.categories != null && enhancedResult.categories!.isNotEmpty) {
        prices['Enhanced'] = enhancedResult.categories!.first.pricePerHead ?? 10.90;
        print('[DEBUG] Enhanced price from DB: ${prices['Enhanced']}');
      } else {
        prices['Enhanced'] = 10.90; // Fallback price
        print('[DEBUG] Enhanced using fallback price: ${prices['Enhanced']}');
      }
      
      // Get Deluxe price
      if (deluxeResult.success && deluxeResult.categories != null && deluxeResult.categories!.isNotEmpty) {
        prices['Deluxe'] = deluxeResult.categories!.first.pricePerHead ?? 13.90;
        print('[DEBUG] Deluxe price from DB: ${prices['Deluxe']}');
      } else {
        prices['Deluxe'] = 13.90; // Fallback price
        print('[DEBUG] Deluxe using fallback price: ${prices['Deluxe']}');
      }
      
      stopwatch.stop();
      print('[DEBUG] getBuffetPrices() - Total time: ${stopwatch.elapsedMilliseconds}ms');
      print('[DEBUG] Final prices: $prices');
      
      return prices;
    } catch (e) {
      stopwatch.stop();
      print('[DEBUG] getBuffetPrices() - Error after ${stopwatch.elapsedMilliseconds}ms: $e');
      // Return fallback prices if anything goes wrong
      return {
        'Classic': 9.90,
        'Enhanced': 10.90,
        'Deluxe': 13.90,
      };
    }
  }

  /// Get buffet items for customization by buffet type
  static Future<Map<String, bool>> getBuffetItems(String buffetType) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('${AppConfig.baseUrl}/buffet-items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_by_buffet_type',
          'buffet_type': buffetType,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final Map<String, bool> items = {};
        for (var item in data['items']) {
          items[item['name']] = true; // Default all items to included
        }
        return items;
      } else {
        return getFallbackBuffetItems();
      }
    } catch (e) {
      return getFallbackBuffetItems();
    }
  }

  /// Fallback buffet items when database is unavailable
  static Map<String, bool> getFallbackBuffetItems() {
    return {
      'Sandwiches': true,
      'Quiche': true,
      'Cocktail Sausages': true,
      'Sausage Rolls': true,
      'Pork Pies': true,
      'Scotch Eggs': true,
      'Tortillas/Dips': true,
      'Cakes': true,
    };
  }
}

/// Product Category model
class ProductCategory {
  final int id;
  final String name;
  final String? description;
  final double? pricePerHead;
  final int minimumQuantity;
  final bool isActive;
  final DateTime createdAt;

  ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.pricePerHead,
    required this.minimumQuantity,
    required this.isActive,
    required this.createdAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pricePerHead: json['price_per_head'] != null 
          ? double.parse(json['price_per_head'].toString())
          : null,
      minimumQuantity: json['minimum_quantity'] ?? 1,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price_per_head': pricePerHead,
      'minimum_quantity': minimumQuantity,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Category result model
class CategoryResult {
  final bool success;
  final String message;
  final List<ProductCategory>? categories;

  CategoryResult({
    required this.success,
    this.message = '',
    this.categories,
  });
}