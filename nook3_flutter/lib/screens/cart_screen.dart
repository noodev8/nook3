/*
=======================================================================================================================================
Cart Screen - The Nook of Welshpool
=======================================================================================================================================
This screen shows the user's cart with all selected items, allows quantity modifications,
and provides navigation to delivery options and checkout.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'delivery_options_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const CartScreen({
    super.key,
    required this.items,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.items);
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      if (item['type'] == 'Buffet') {
        total += item['totalPrice'] ?? 0;
      } else {
        // Share Box - price would be set from API
        total += (item['price'] ?? 15.0) * (item['quantity'] ?? 1);
      }
    }
    return total;
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  int _getTotalBuffetPortions() {
    int total = 0;
    for (var item in _cartItems) {
      if (item['type'] == 'Buffet') {
        total += item['numberOfPeople'] as int;
      }
    }
    return total;
  }

  void _proceedToDelivery() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    // Check minimum buffet requirement
    int totalBuffetPortions = _getTotalBuffetPortions();
    bool hasBuffets = _cartItems.any((item) => item['type'] == 'Buffet');

    if (hasBuffets && totalBuffetPortions < 5) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Minimum Order Required'),
          content: Text(
            'Buffet orders require a minimum of 5 portions total.\n\nYou currently have $totalBuffetPortions buffet portions.\nPlease add ${5 - totalBuffetPortions} more portions or remove buffet items.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryOptionsScreen(
          cartItems: _cartItems,
          totalAmount: _calculateTotal(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _cartItems.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item['type']} - ${item['variant']}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (item['type'] == 'Buffet') ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item['numberOfPeople']} people × £${item['pricePerHead'].toStringAsFixed(2)}',
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ] else ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Quantity: ${item['quantity']}',
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeItem(index),
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                                
                                if (item['departmentLabel'] != null && item['departmentLabel'].isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Department: ${item['departmentLabel']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                
                                if (item['notes'] != null && item['notes'].isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Notes: ${item['notes']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                                
                                if (item['deluxeFormat'] != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Format: ${item['deluxeFormat']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                
                                if (item['includedItems'] != null) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Included Items:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: (item['includedItems'] as List<String>).map((itemName) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          itemName,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.green,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '£${item['type'] == 'Buffet' ? item['totalPrice'].toStringAsFixed(2) : ((item['price'] ?? 15.0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
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
                        );
                      },
                    ),
                  ),
                  
                  // Total and Checkout
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Buffet Summary
                        if (_getTotalBuffetPortions() > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getTotalBuffetPortions() >= 5
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getTotalBuffetPortions() >= 5
                                    ? Colors.green.shade200
                                    : Colors.orange.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getTotalBuffetPortions() >= 5
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: _getTotalBuffetPortions() >= 5
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Buffet Portions: ${_getTotalBuffetPortions()} ${_getTotalBuffetPortions() >= 5 ? '(Minimum met)' : '(Need ${5 - _getTotalBuffetPortions()} more)'}',
                                    style: TextStyle(
                                      color: _getTotalBuffetPortions() >= 5
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '£${_calculateTotal().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _proceedToDelivery,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Proceed to Delivery Options',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
