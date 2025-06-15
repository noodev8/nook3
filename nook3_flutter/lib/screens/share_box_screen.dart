/*
=======================================================================================================================================
Share Box Screen - The Nook of Welshpool
=======================================================================================================================================
This screen allows users to select between Traditional and Vegetarian share boxes for 1-4 people.
Shows what's included in each option and allows quantity selection.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'cart_screen.dart';

class ShareBoxScreen extends StatefulWidget {
  const ShareBoxScreen({super.key});

  @override
  State<ShareBoxScreen> createState() => _ShareBoxScreenState();
}

class _ShareBoxScreenState extends State<ShareBoxScreen> {
  String _selectedType = '';
  int _quantity = 1;

  void _addToCart() {
    if (_selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a share box type')),
      );
      return;
    }
    
    // TODO: Add to cart logic
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          items: [
            {
              'type': 'Share Box',
              'variant': _selectedType,
              'quantity': _quantity,
              'price': 0.0, // Price TBD
            }
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Box'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Share Box Options',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Perfect for 1-4 people • Daily fresh mix',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              
              // Traditional Option
              Card(
                elevation: _selectedType == 'Traditional' ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _selectedType == 'Traditional' ? Colors.green : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = 'Traditional';
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.lunch_dining,
                                size: 25,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Traditional Share Box',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_selectedType == 'Traditional')
                              const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Includes:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text('• Mixed Sandwiches (various fillings)\n• Assorted Crisps\n• Picky Bits selection\n• Daily specials (Pork Pie, Quiche, etc.)'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Vegetarian Option
              Card(
                elevation: _selectedType == 'Vegetarian' ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _selectedType == 'Vegetarian' ? Colors.green : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedType = 'Vegetarian';
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(
                                Icons.eco,
                                size: 25,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Vegetarian Share Box',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (_selectedType == 'Vegetarian')
                              const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Includes:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text('• Vegetarian Sandwiches\n• Assorted Crisps\n• Vegetarian Picky Bits\n• Vegetarian daily specials (Quiche, etc.)'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Quantity Selector
              if (_selectedType.isNotEmpty) ...[
                const Text(
                  'Quantity:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      onPressed: _quantity > 1 ? () {
                        setState(() {
                          _quantity--;
                        });
                      } : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 32,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: _quantity < 10 ? () {
                        setState(() {
                          _quantity++;
                        });
                      } : null,
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 32,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // Add to Cart Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedType.isEmpty
                      ? 'Select an option above'
                      : 'Add to Cart',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }
}
