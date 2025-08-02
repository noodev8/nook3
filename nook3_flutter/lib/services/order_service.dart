import 'dart:convert';
import '../config/app_config.dart';

class OrderService {
  // Server configuration using AppConfig
  static String get baseUrl => '${AppConfig.baseUrl}/orders';
  
  /// Submit order - convert cart to confirmed order
  static Future<OrderResult> submitOrder({
    int? userId,
    String? sessionId,
    required String deliveryType,
    String? deliveryAddress,
    required String phoneNumber,
    required String email,
    required DateTime requestedDate,
    required String requestedTime,
    String? specialInstructions,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'session_id': sessionId,
          'delivery_type': deliveryType,
          'delivery_address': deliveryAddress,
          'phone_number': phoneNumber,
          'email': email,
          'requested_date': '${requestedDate.year}-${requestedDate.month.toString().padLeft(2, '0')}-${requestedDate.day.toString().padLeft(2, '0')}',
          'requested_time': requestedTime,
          'special_instructions': specialInstructions,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        return OrderResult(
          success: true,
          message: data['message'],
          orderId: data['order_id'],
          orderNumber: data['order_number'],
          totalAmount: double.tryParse(data['total_amount']?.toString() ?? '0.0') ?? 0.0,
          estimatedTime: data['estimated_time'],
        );
      } else {
        return OrderResult(
          success: false,
          message: data['message'] ?? 'Failed to submit order',
        );
      }
    } catch (e) {
      return OrderResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Get order history for authenticated user
  static Future<OrderHistoryResult> getOrderHistory({
    required int userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl/history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'limit': limit,
          'offset': offset,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final List<OrderSummary> orders = (data['orders'] as List)
            .map((orderJson) => OrderSummary.fromJson(orderJson))
            .toList();
        
        return OrderHistoryResult(
          success: true,
          message: data['message'],
          orders: orders,
        );
      } else {
        return OrderHistoryResult(
          success: false,
          message: data['message'] ?? 'Failed to load order history',
        );
      }
    } catch (e) {
      return OrderHistoryResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Get detailed information for a specific order
  static Future<OrderDetailResult> getOrderDetails({
    required int userId,
    required int orderId,
  }) async {
    try {
      final response = await AppConfig.post(
        Uri.parse('$baseUrl/details'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'order_id': orderId,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['return_code'] == 'SUCCESS') {
        final OrderDetail order = OrderDetail.fromJson(data['order']);
        
        return OrderDetailResult(
          success: true,
          message: data['message'],
          order: order,
        );
      } else {
        return OrderDetailResult(
          success: false,
          message: data['message'] ?? 'Failed to load order details',
        );
      }
    } catch (e) {
      return OrderDetailResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}

/// Order result model
class OrderResult {
  final bool success;
  final String message;
  final int? orderId;
  final String? orderNumber;
  final double? totalAmount;
  final String? estimatedTime;

  OrderResult({
    required this.success,
    this.message = '',
    this.orderId,
    this.orderNumber,
    this.totalAmount,
    this.estimatedTime,
  });
}

/// Order summary model for order history list
class OrderSummary {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final String orderStatus;
  final String deliveryType;
  final DateTime requestedDate;
  final DateTime requestedTime;
  final String? deliveryAddress;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final int itemCount;

  OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.orderStatus,
    required this.deliveryType,
    required this.requestedDate,
    required this.requestedTime,
    this.deliveryAddress,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    required this.itemCount,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: int.parse(json['id'].toString()),
      orderNumber: json['order_number'],
      totalAmount: double.parse(json['total_amount'].toString()),
      orderStatus: json['order_status'],
      deliveryType: json['delivery_type'],
      requestedDate: DateTime.parse(json['requested_date']),
      requestedTime: DateTime.parse(json['requested_time']),
      deliveryAddress: json['delivery_address'],
      createdAt: DateTime.parse(json['created_at']),
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      itemCount: int.parse(json['item_count'].toString()),
    );
  }

  /// Get formatted order status for display
  String get statusDisplay {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return orderStatus.toUpperCase();
    }
  }

  /// Get status color for UI
  String get statusColor {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return '#3498DB'; // Blue
      case 'preparing':
        return '#F39C12'; // Orange
      case 'ready':
        return '#E67E22'; // Dark orange
      case 'completed':
        return '#27AE60'; // Green
      case 'cancelled':
        return '#E74C3C'; // Red
      default:
        return '#7F8C8D'; // Gray
    }
  }
}

/// Detailed order model for order detail screen
class OrderDetail {
  final int id;
  final String orderNumber;
  final double totalAmount;
  final String orderStatus;
  final String deliveryType;
  final DateTime requestedDate;
  final DateTime requestedTime;
  final String? deliveryAddress;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;

  OrderDetail({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.orderStatus,
    required this.deliveryType,
    required this.requestedDate,
    required this.requestedTime,
    this.deliveryAddress,
    this.specialInstructions,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    required this.items,
    required this.statusHistory,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final List<OrderItem> items = (json['items'] as List?)
        ?.map((itemJson) => OrderItem.fromJson(itemJson))
        .toList() ?? [];
    
    final List<OrderStatusHistory> statusHistory = (json['status_history'] as List?)
        ?.map((historyJson) => OrderStatusHistory.fromJson(historyJson))
        .toList() ?? [];

    return OrderDetail(
      id: int.parse(json['id'].toString()),
      orderNumber: json['order_number'],
      totalAmount: double.parse(json['total_amount'].toString()),
      orderStatus: json['order_status'],
      deliveryType: json['delivery_type'],
      requestedDate: DateTime.parse(json['requested_date']),
      requestedTime: DateTime.parse(json['requested_time']),
      deliveryAddress: json['delivery_address'],
      specialInstructions: json['special_instructions'],
      createdAt: DateTime.parse(json['created_at']),
      confirmedAt: json['confirmed_at'] != null ? DateTime.parse(json['confirmed_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      items: items,
      statusHistory: statusHistory,
    );
  }

  /// Get formatted order status for display
  String get statusDisplay {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return orderStatus.toUpperCase();
    }
  }

  /// Get status color for UI
  String get statusColor {
    switch (orderStatus.toLowerCase()) {
      case 'pending':
        return '#3498DB'; // Blue
      case 'preparing':
        return '#F39C12'; // Orange
      case 'ready':
        return '#E67E22'; // Dark orange
      case 'completed':
        return '#27AE60'; // Green
      case 'cancelled':
        return '#E74C3C'; // Red
      default:
        return '#7F8C8D'; // Gray
    }
  }
}

/// Order item model
class OrderItem {
  final int orderCategoryId;
  final int categoryId;
  final String categoryName;
  final String? categoryDescription;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;
  final List<OrderMenuItem> includedItems;

  OrderItem({
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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final List<OrderMenuItem> items = [];
    
    if (json['included_items'] != null) {
      for (var itemJson in json['included_items']) {
        if (itemJson != null && itemJson['id'] != null) {
          items.add(OrderMenuItem.fromJson(itemJson));
        }
      }
    }

    return OrderItem(
      orderCategoryId: int.parse(json['order_category_id'].toString()),
      categoryId: int.parse(json['category_id'].toString()),
      categoryName: json['category_name'],
      categoryDescription: json['category_description'],
      quantity: int.parse(json['quantity'].toString()),
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

/// Order menu item model
class OrderMenuItem {
  final int id;
  final String name;
  final String? description;
  final bool isVegetarian;

  OrderMenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.isVegetarian,
  });

  factory OrderMenuItem.fromJson(Map<String, dynamic> json) {
    return OrderMenuItem(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      description: json['description'],
      isVegetarian: json['is_vegetarian'] ?? false,
    );
  }
}

/// Order status history model
class OrderStatusHistory {
  final String status;
  final String? notes;
  final DateTime createdAt;

  OrderStatusHistory({
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Get formatted status for display
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Order Pending';
      case 'preparing':
        return 'Preparing Your Order';
      case 'ready':
        return 'Ready for Collection/Delivery';
      case 'completed':
        return 'Order Completed';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return status.toUpperCase();
    }
  }
}

/// Order history result model
class OrderHistoryResult {
  final bool success;
  final String message;
  final List<OrderSummary>? orders;

  OrderHistoryResult({
    required this.success,
    this.message = '',
    this.orders,
  });
}

/// Order detail result model
class OrderDetailResult {
  final bool success;
  final String message;
  final OrderDetail? order;

  OrderDetailResult({
    required this.success,
    this.message = '',
    this.order,
  });
}