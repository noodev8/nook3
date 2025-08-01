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
      backgroundColor: const Color(0xFFFAFAFA), // Soft off-white background
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50), // Deep charcoal
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        shadowColor: Colors.black.withOpacity( 0.1),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _cartItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add some delicious items to get started',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF7F8C8D),
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
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity( 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity( 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
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
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF2C3E50),
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            if (item['type'] == 'Buffet') ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '${item['numberOfPeople']} people × £${item['pricePerHead'].toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF7F8C8D),
                                                ),
                                              ),
                                            ] else ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Quantity: ${item['quantity']}',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF7F8C8D),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FA),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          onPressed: () => _removeItem(index),
                                          icon: const Icon(Icons.delete_outline),
                                          color: const Color(0xFFE74C3C),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (item['departmentLabel'] != null && item['departmentLabel'].isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3498DB).withOpacity( 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF3498DB).withOpacity( 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Department: ${item['departmentLabel']}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: const Color(0xFF3498DB),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],

                                  if (item['notes'] != null && item['notes'].isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE0E6ED),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Notes: ${item['notes']}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: const Color(0xFF7F8C8D),
                                        ),
                                      ),
                                    ),
                                  ],

                                  if (item['deluxeFormat'] != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9B59B6).withOpacity( 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF9B59B6).withOpacity( 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Format: ${item['deluxeFormat']}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: const Color(0xFF9B59B6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],

                                  if (item['includedItems'] != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      'Included Items:',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: (item['includedItems'] as List<String>).map((itemName) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF27AE60).withOpacity( 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: const Color(0xFF27AE60).withOpacity( 0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            itemName,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 11,
                                              color: const Color(0xFF27AE60),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  // Elegant divider
                                  Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          const Color(0xFFE0E6ED),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '£${item['type'] == 'Buffet' ? item['totalPrice'].toStringAsFixed(2) : ((item['price'] ?? 15.0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2C3E50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Total and Checkout with sophisticated styling
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity( 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity( 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Buffet Summary with sophisticated styling
                        if (_getTotalBuffetPortions() > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getTotalBuffetPortions() >= 5
                                  ? const Color(0xFF27AE60).withOpacity( 0.1)
                                  : const Color(0xFFE67E22).withOpacity( 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getTotalBuffetPortions() >= 5
                                    ? const Color(0xFF27AE60).withOpacity( 0.3)
                                    : const Color(0xFFE67E22).withOpacity( 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getTotalBuffetPortions() >= 5
                                        ? const Color(0xFF27AE60)
                                        : const Color(0xFFE67E22),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getTotalBuffetPortions() >= 5
                                        ? Icons.check_circle
                                        : Icons.warning,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Buffet Portions: ${_getTotalBuffetPortions()} ${_getTotalBuffetPortions() >= 5 ? '(Minimum met)' : '(Need ${5 - _getTotalBuffetPortions()} more)'}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: _getTotalBuffetPortions() >= 5
                                          ? const Color(0xFF27AE60)
                                          : const Color(0xFFE67E22),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              '£${_calculateTotal().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3498DB).withOpacity( 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _proceedToDelivery,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: Icon(
                              Icons.local_shipping_outlined,
                              size: 20,
                            ),
                            label: Text(
                              'Proceed to Delivery Options',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
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
