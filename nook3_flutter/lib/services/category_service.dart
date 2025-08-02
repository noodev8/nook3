import 'dart:convert';
import '../../config/app_config.dart';

class CategoryService {
  // Server configuration using AppConfig
  static String get baseUrl => '${AppConfig.baseUrl}/categories';
  
  /// Get all product categories
  static Future<CategoryResult> getCategories() async {
    try {
      final response = await AppConfig.get(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
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

  /// Get specific category by name
  static Future<CategoryResult> getCategoryByName(String name) async {
    try {
      final response = await AppConfig.get(
        Uri.parse('$baseUrl/name/$name'),
        headers: {'Content-Type': 'application/json'},
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

  /// Get categories for share boxes specifically
  static Future<Map<String, double>> getShareBoxPrices() async {
    final result = await getCategories();
    
    if (!result.success || result.categories == null) {
      // Return default prices if API fails
      return {
        'Traditional': 12.50,
        'Vegetarian': 11.50,
      };
    }

    final Map<String, double> prices = {};
    
    for (final category in result.categories!) {
      if (category.name.contains('Traditional Share Box')) {
        prices['Traditional'] = category.pricePerHead ?? 12.50;
      } else if (category.name.contains('Vegetarian Share Box')) {
        prices['Vegetarian'] = category.pricePerHead ?? 11.50;
      }
    }

    // Ensure we have both prices, use defaults if missing
    prices['Traditional'] ??= 12.50;
    prices['Vegetarian'] ??= 11.50;

    return prices;
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