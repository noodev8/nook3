/*
=======================================================================================================================================
Buffet Selection Screen - The Nook of Welshpool
=======================================================================================================================================
This screen shows the three buffet options (Classic, Enhanced, Deluxe) for 5+ people.
Users can see pricing and what's included in each buffet type.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'buffet_customization_screen.dart';

class BuffetSelectionScreen extends StatelessWidget {
  const BuffetSelectionScreen({super.key});

  void _selectBuffet(BuildContext context, String buffetType, double price) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuffetCustomizationScreen(
          buffetType: buffetType,
          pricePerHead: price,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Buffet'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Buffet Options',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'For 5 or more people • Mix and match different buffets',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: ListView(
                  children: [
                    // Classic Buffet
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => _selectBuffet(context, 'Classic', 9.90),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant_menu,
                                      size: 30,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Classic Buffet',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '£9.90 per head',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Main Items:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text('Sandwiches: Egg Mayo & Cress, Ham Salad, Cheese & Onion, Tuna Mayo, Beef Salad'),
                              const SizedBox(height: 12),
                              const Text(
                                'Sides:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text('Quiche, Cocktail Sausages, Sausage Rolls, Cheese & Onion Rolls, Pork Pies, Scotch Eggs, Tortillas/Dips, Assortment of Cakes'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Enhanced Buffet
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => _selectBuffet(context, 'Enhanced', 10.90),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      size: 30,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Enhanced Buffet',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '£10.90 per head',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Everything in Classic PLUS:',
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Additional Sandwiches:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text('Coronation Chicken'),
                              const SizedBox(height: 12),
                              const Text(
                                'Additional Sides:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text('Vegetable sticks & Dips, Cheese/Pineapple/Grapes, Bread Sticks, Pickles, Coleslaw'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Deluxe Buffet
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () => _selectBuffet(context, 'Deluxe', 13.90),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade100,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.diamond,
                                      size: 30,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Deluxe Buffet',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '£13.90 per head',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Premium Selection:',
                                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.purple),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sandwiches:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text('Ham & Mustard, Coronation Chicken & Baby Gem, Egg & Cress, Beef/Horseradish/Tomato/Rocket, Cheese & Onion, Turkey & Cranberry, Chicken/Bacon/Chive Mayo'),
                              const SizedBox(height: 12),
                              const Text(
                                'Premium Sides:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              const Text('Greek Salad, Potato Salad, Tomato & Mozzarella Skewers, Fresh Vegetables, Premium Dips, and much more...'),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Choose: Mixed (75% Sandwiches), All Sandwiches, or All Wraps',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
