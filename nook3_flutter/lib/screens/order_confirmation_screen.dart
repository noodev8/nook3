/*
=======================================================================================================================================
Order Confirmation Screen - The Nook of Welshpool
=======================================================================================================================================
This screen shows the final order summary with all details before submission.
Users can review everything and submit their order.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'order_status_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;
  final String deliveryOption;
  final String? deliveryAddress;
  final String phoneNumber;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const OrderConfirmationScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.deliveryOption,
    this.deliveryAddress,
    required this.phoneNumber,
    required this.selectedDate,
    required this.selectedTime,
  });

  void _submitOrder(BuildContext context) {
    // TODO: Submit order to API
    // For wireframe, just navigate to order status
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderStatusScreen(
          orderNumber: 'NK001234',
          estimatedTime: '45 minutes',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  const Text(
                    'Review Your Order',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Order Items
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Items:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...cartItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item['type']} - ${item['variant']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '£${item['type'] == 'Buffet' ? item['totalPrice'].toStringAsFixed(2) : ((item['price'] ?? 15.0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item['type'] == 'Buffet') ...[
                                    Text(
                                      '${item['numberOfPeople']} people × £${item['pricePerHead'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Quantity: ${item['quantity']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                  if (item['departmentLabel'] != null && item['departmentLabel'].isNotEmpty)
                                    Text(
                                      'Department: ${item['departmentLabel']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  if (item['notes'] != null && item['notes'].isNotEmpty)
                                    Text(
                                      'Notes: ${item['notes']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '£${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Delivery Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$deliveryOption Details:',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (deliveryOption == 'Delivery') ...[
                            const Row(
                              children: [
                                Icon(Icons.delivery_dining, color: Colors.orange),
                                SizedBox(width: 8),
                                Text(
                                  'Delivery Address:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(deliveryAddress ?? ''),
                          ] else ...[
                            const Row(
                              children: [
                                Icon(Icons.store, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Collection Address:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text('The Nook of Welshpool\n42 High Street, Welshpool, SY21 7JQ'),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.schedule, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                '${deliveryOption == 'Delivery' ? 'Delivery' : 'Collection'} Time:',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year} at ${selectedTime.format(context)}'),
                          if (phoneNumber.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Icon(Icons.phone, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Contact Number:',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(phoneNumber),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Important Notes
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Important Information:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• All packaging is recyclable\n• Fresh ingredients prepared daily\n• Please have payment ready for collection/delivery\n• Contact us on 07551428162 for any changes',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Submit Order Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _submitOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Order',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
