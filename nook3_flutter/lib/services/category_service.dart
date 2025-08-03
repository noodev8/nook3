import 'dart:convert';
import '../config/app_config.dart';

class CategoryService {
  // Server configuration using AppConfig
  static String get baseUrl => '${AppConfig.baseUrl}/categories';
  
  /// Get all product categories
  static Future<CategoryResult> getCategories() async {
    try {
      final response = await AppConfig.post(
        Uri.parse(baseUrl),
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
    try {
      final response = await AppConfig.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get_by_id',
          'category_id': id,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final category = ProductCategory.fromJson(data['category']);
        
        return CategoryResult(
          success: true,
          message: data['message'],
          categories: [category],
        );
      } else {
        return CategoryResult(
          success: false,
          message: data['message'] ?? 'Category not found',
        );
      }
    } catch (e) {
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
        Uri.parse(baseUrl),
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
    try {
      // Fetch Classic Buffet (ID: 3), Enhanced Buffet (ID: 4), and Deluxe Buffet (ID: 5)
      final classicResult = await getCategoryById(3);
      final enhancedResult = await getCategoryById(4);
      final deluxeResult = await getCategoryById(5);
      
      final Map<String, double> prices = {};
      
      // Get Classic price
      if (classicResult.success && classicResult.categories != null && classicResult.categories!.isNotEmpty) {
        prices['Classic'] = classicResult.categories!.first.pricePerHead ?? 9.90;
      } else {
        prices['Classic'] = 9.90; // Fallback price
      }
      
      // Get Enhanced price
      if (enhancedResult.success && enhancedResult.categories != null && enhancedResult.categories!.isNotEmpty) {
        prices['Enhanced'] = enhancedResult.categories!.first.pricePerHead ?? 10.90;
      } else {
        prices['Enhanced'] = 10.90; // Fallback price
      }
      
      // Get Deluxe price
      if (deluxeResult.success && deluxeResult.categories != null && deluxeResult.categories!.isNotEmpty) {
        prices['Deluxe'] = deluxeResult.categories!.first.pricePerHead ?? 13.90;
      } else {
        prices['Deluxe'] = 13.90; // Fallback price
      }
      
      return prices;
    } catch (e) {
      // Return fallback prices if anything goes wrong
      return {
        'Classic': 9.90,
        'Enhanced': 10.90,
        'Deluxe': 13.90,
      };
    }
  }

  /// Get buffet items for customization by buffet type
  static Future<List<BuffetItem>> getBuffetItemsWithIds(String buffetType) async {
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
        final List<BuffetItem> items = [];
        for (var item in data['items']) {
          items.add(BuffetItem.fromJson(item));
        }
        return items;
      } else {
        throw Exception('Failed to load buffet items: API returned error');
      }
    } catch (e) {
      throw Exception('Failed to load buffet items: $e');
    }
  }

  /// Get buffet items for customization by buffet type (legacy method)
  static Future<Map<String, bool>> getBuffetItems(String buffetType) async {
    final items = await getBuffetItemsWithIds(buffetType);
    final Map<String, bool> itemMap = {};
    for (var item in items) {
      itemMap[item.name] = item.isDefault;
    }
    return itemMap;
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

  /// Fallback buffet items with IDs when database is unavailable
  static List<BuffetItem> getFallbackBuffetItemsWithIds() {
    return [
      BuffetItem(id: 1000, name: 'Sandwiches', isDefault: true),
      BuffetItem(id: 1001, name: 'Quiche', isDefault: true),
      BuffetItem(id: 1002, name: 'Cocktail Sausages', isDefault: true),
      BuffetItem(id: 1003, name: 'Sausage Rolls', isDefault: true),
      BuffetItem(id: 1004, name: 'Pork Pies', isDefault: true),
      BuffetItem(id: 1005, name: 'Scotch Eggs', isDefault: true),
      BuffetItem(id: 1006, name: 'Tortillas/Dips', isDefault: true),
      BuffetItem(id: 1007, name: 'Cakes', isDefault: true),
    ];
  }
}

/// Product Category model
class ProductCategory {
  final int id;
  final String name;
  final String? description;
  final double? pricePerHead;
  final bool isActive;
  final DateTime createdAt;

  ProductCategory({
    required this.id,
    required this.name,
    this.description,
    this.pricePerHead,
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

/// Buffet item model
class BuffetItem {
  final int id;
  final String name;
  final String? description;
  final String? itemType;
  final bool isVegetarian;
  final bool isDefault;

  BuffetItem({
    required this.id,
    required this.name,
    this.description,
    this.itemType,
    this.isVegetarian = false,
    this.isDefault = true,
  });

  factory BuffetItem.fromJson(Map<String, dynamic> json) {
    return BuffetItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      itemType: json['item_type'],
      isVegetarian: json['is_vegetarian'] ?? false,
      isDefault: json['is_default'] ?? true,
    );
  }
}