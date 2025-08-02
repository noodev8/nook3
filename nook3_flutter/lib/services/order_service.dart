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
        message: 'Network error. Please check your connection.',
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