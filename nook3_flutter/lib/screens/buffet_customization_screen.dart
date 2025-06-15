/*
=======================================================================================================================================
Buffet Customization Screen - The Nook of Welshpool
=======================================================================================================================================
This screen allows users to customize their selected buffet by:
- Setting number of people
- Removing items (minimum 1 must remain)
- Adding department labels and notes
- Choosing deluxe buffet format (Mixed/Sandwiches/Wraps)
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'cart_screen.dart';

class BuffetCustomizationScreen extends StatefulWidget {
  final String buffetType;
  final double pricePerHead;

  const BuffetCustomizationScreen({
    super.key,
    required this.buffetType,
    required this.pricePerHead,
  });

  @override
  State<BuffetCustomizationScreen> createState() => _BuffetCustomizationScreenState();
}

class _BuffetCustomizationScreenState extends State<BuffetCustomizationScreen> {
  int _numberOfPeople = 5;
  String _departmentLabel = '';
  String _notes = '';
  String _deluxeFormat = 'Mixed'; // For Deluxe buffet only
  
  // Sample items that can be removed (this would come from API in real app)
  final Map<String, bool> _includedItems = {
    'Sandwiches': true,
    'Quiche': true,
    'Cocktail Sausages': true,
    'Sausage Rolls': true,
    'Pork Pies': true,
    'Scotch Eggs': true,
    'Tortillas/Dips': true,
    'Cakes': true,
  };

  void _addToCart() {
    final selectedItems = _includedItems.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one item must be selected')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          items: [
            {
              'type': 'Buffet',
              'variant': widget.buffetType,
              'numberOfPeople': _numberOfPeople,
              'pricePerHead': widget.pricePerHead,
              'totalPrice': _numberOfPeople * widget.pricePerHead,
              'includedItems': selectedItems,
              'departmentLabel': _departmentLabel,
              'notes': _notes,
              'deluxeFormat': widget.buffetType == 'Deluxe' ? _deluxeFormat : null,
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
        title: Text('${widget.buffetType} Buffet'),
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
              Text(
                'Customize Your ${widget.buffetType} Buffet',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                '£${widget.pricePerHead.toStringAsFixed(2)} per person',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: ListView(
                  children: [
                    // Number of People
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Number of People:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _numberOfPeople > 5 ? () {
                                    setState(() {
                                      _numberOfPeople--;
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
                                    '$_numberOfPeople',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _numberOfPeople < 50 ? () {
                                    setState(() {
                                      _numberOfPeople++;
                                    });
                                  } : null,
                                  icon: const Icon(Icons.add_circle_outline),
                                  iconSize: 32,
                                ),
                                const Spacer(),
                                Text(
                                  'Total: £${(_numberOfPeople * widget.pricePerHead).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
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
                    
                    // Deluxe Format Selection (only for Deluxe buffet)
                    if (widget.buffetType == 'Deluxe') ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Deluxe Format:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...['Mixed (75% Sandwiches)', 'All Sandwiches', 'All Wraps'].map((format) {
                                return RadioListTile<String>(
                                  title: Text(format),
                                  value: format.split(' ')[0],
                                  groupValue: _deluxeFormat,
                                  onChanged: (value) {
                                    setState(() {
                                      _deluxeFormat = value!;
                                    });
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Remove Items
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Customize Items:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Uncheck items you don\'t want (minimum 1 required)',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ..._includedItems.entries.map((entry) {
                              return CheckboxListTile(
                                title: Text(entry.key),
                                value: entry.value,
                                onChanged: (value) {
                                  final selectedCount = _includedItems.values.where((v) => v).length;
                                  if (selectedCount > 1 || value == true) {
                                    setState(() {
                                      _includedItems[entry.key] = value!;
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('At least one item must remain selected')),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Department Label
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Department Label (Optional):',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: (value) {
                                _departmentLabel = value;
                              },
                              decoration: const InputDecoration(
                                hintText: 'e.g., Marketing Team, Sales Department',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Special Notes (Optional):',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              onChanged: (value) {
                                _notes = value;
                              },
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Any special requirements or notes...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
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
                    'Add to Cart - £${(_numberOfPeople * widget.pricePerHead).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
