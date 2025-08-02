import 'dart:convert';
import '../config/app_config.dart';

class CartService {
  // Server configuration using AppConfig
  static String get baseUrl => '${AppConfig.baseUrl}/cart';
  
  /// Add item to cart
  static Future<CartResult> addToCart({
    int? userId,
    String? sessionId,
    required int categoryId,
    required int quantity,
    required double unitPrice,
    String? departmentLabel,
    String? notes,
    String? deluxeFormat,
    required List<int> includedItemIds,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'add',
          'user_id': userId,
          'session_id': sessionId,
          'category_id': categoryId,
          'quantity': quantity,
          'unit_price': unitPrice,
          'department_label': departmentLabel,
          'notes': notes,
          'deluxe_format': deluxeFormat,
          'included_items': includedItemIds,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final List<CartItem> cartItems = (data['cart_items'] as List)
            .map((itemJson) => CartItem.fromJson(itemJson))
            .toList();
        
        return CartResult(
          success: true,
          message: data['message'],
          cartItems: cartItems,
          totalAmount: double.tryParse(data['total_amount']?.toString() ?? '0.0') ?? 0.0,
        );
      } else {
        return CartResult(
          success: false,
          message: data['message'] ?? 'Failed to add item to cart',
        );
      }
    } catch (e) {
      return CartResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get cart items
  static Future<CartResult> getCart({
    int? userId,
    String? sessionId,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'get',
          'user_id': userId,
          'session_id': sessionId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final List<CartItem> cartItems = (data['cart_items'] as List)
            .map((itemJson) => CartItem.fromJson(itemJson))
            .toList();
        
        return CartResult(
          success: true,
          message: data['message'],
          cartItems: cartItems,
          totalAmount: double.tryParse(data['total_amount']?.toString() ?? '0.0') ?? 0.0,
        );
      } else {
        return CartResult(
          success: false,
          message: data['message'] ?? 'Failed to load cart',
        );
      }
    } catch (e) {
      return CartResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Delete item from cart
  static Future<CartResult> deleteCartItem({
    int? userId,
    String? sessionId,
    required int orderCategoryId,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'delete',
          'user_id': userId,
          'session_id': sessionId,
          'order_category_id': orderCategoryId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final List<CartItem> cartItems = (data['cart_items'] as List)
            .map((itemJson) => CartItem.fromJson(itemJson))
            .toList();
        
        return CartResult(
          success: true,
          message: data['message'],
          cartItems: cartItems,
          totalAmount: double.tryParse(data['total_amount']?.toString() ?? '0.0') ?? 0.0,
        );
      } else {
        return CartResult(
          success: false,
          message: data['message'] ?? 'Failed to remove item from cart',
        );
      }
    } catch (e) {
      return CartResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Clear entire cart
  static Future<CartResult> clearCart({
    int? userId,
    String? sessionId,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'clear',
          'user_id': userId,
          'session_id': sessionId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        return CartResult(
          success: true,
          message: data['message'],
          cartItems: [],
          totalAmount: 0.0,
        );
      } else {
        return CartResult(
          success: false,
          message: data['message'] ?? 'Failed to clear cart',
        );
      }
    } catch (e) {
      return CartResult(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Generate session ID for guest users
  static String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'guest_${timestamp}_$random';
  }
}

/// Cart item model
class CartItem {
  final int orderCategoryId;
  final int categoryId;
  final String categoryName;
  final String? categoryDescription;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;
  final List<MenuItem> includedItems;

  CartItem({
    required this.orderCategoryId,
    required this.categoryId,
    required this.categoryName,
    this.categoryDescription,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
    required this.includedItems,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final List<MenuItem> items = [];
    
    if (json['included_items'] != null) {
      for (var itemJson in json['included_items']) {
        if (itemJson != null && itemJson['id'] != null) {
          items.add(MenuItem.fromJson(itemJson));
        }
      }
    }

    return CartItem(
      orderCategoryId: json['order_category_id'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryDescription: json['category_description'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      totalPrice: double.parse(json['total_price'].toString()),
      notes: json['notes'],
      includedItems: items,
    );
  }

  // Extract metadata from notes field
  Map<String, dynamic> get metadata {
    if (notes == null || !notes!.contains('Metadata:')) {
      return {};
    }
    
    try {
      final metadataStart = notes!.indexOf('Metadata:') + 9;
      final metadataJson = notes!.substring(metadataStart).trim();
      return jsonDecode(metadataJson);
    } catch (e) {
      return {};
    }
  }

  String? get departmentLabel => metadata['department_label'];
  String? get deluxeFormat => metadata['deluxe_format'];
}

/// Menu item model for cart
class MenuItem {
  final int id;
  final String name;
  final String? description;
  final bool isVegetarian;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.isVegetarian,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isVegetarian: json['is_vegetarian'] ?? false,
    );
  }
}

/// Cart result model
class CartResult {
  final bool success;
  final String message;
  final List<CartItem>? cartItems;
  final double? totalAmount;

  CartResult({
    required this.success,
    this.message = '',
    this.cartItems,
    this.totalAmount,
  });
}