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
import '../services/category_service.dart';
import '../services/cart_service.dart';

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
  int _numberOfPeople = 1; // Changed to allow 1+ people per buffet
  String _departmentLabel = '';
  String _notes = '';
  String _deluxeFormat = 'Mixed'; // For Deluxe buffet only
  bool _isLoadingItems = true;
  bool _isAddingToCart = false;
  
  // Items loaded from database - now stores item info with IDs
  List<BuffetItem> _availableItems = [];
  Map<int, bool> _selectedItems = {}; // Maps item ID to selected status

  @override
  void initState() {
    super.initState();
    _loadBuffetItems();
  }
  
  Future<void> _loadBuffetItems() async {
    try {
      final items = await CategoryService.getBuffetItemsWithIds(widget.buffetType);
      
      setState(() {
        _availableItems = items;
        _selectedItems = {for (var item in items) item.id: item.isDefault};
        _isLoadingItems = false;
      });
    } catch (e) {
      // Use fallback items if loading fails
      final fallbackItems = CategoryService.getFallbackBuffetItemsWithIds();
      
      setState(() {
        _availableItems = fallbackItems;
        _selectedItems = {for (var item in fallbackItems) item.id: item.isDefault};
        _isLoadingItems = false;
      });
    }
  }

  void _addToCart() async {
    final selectedItemIds = _selectedItems.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    
    if (selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one item must be selected')),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Map buffet type to category ID
      final categoryId = _getCategoryId(widget.buffetType);
      
      // Generate session ID for guest users (we'll add user management later)
      final sessionId = CartService.generateSessionId();
      
      // Add to cart via API
      final result = await CartService.addToCart(
        sessionId: sessionId,
        categoryId: categoryId,
        quantity: _numberOfPeople,
        unitPrice: widget.pricePerHead,
        departmentLabel: _departmentLabel.isNotEmpty ? _departmentLabel : null,
        notes: _notes.isNotEmpty ? _notes : null,
        deluxeFormat: widget.buffetType == 'Deluxe' ? _deluxeFormat : null,
        includedItemIds: selectedItemIds,
      );

      if (result.success) {
        // Navigate to cart screen (it will load from database)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CartScreen(sessionId: sessionId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  int _getCategoryId(String buffetType) {
    switch (buffetType) {
      case 'Classic':
        return 3;
      case 'Enhanced':
        return 4;
      case 'Deluxe':
        return 5;
      default:
        return 3; // Default to Classic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Soft off-white background
      appBar: AppBar(
        title: Text(
          '${widget.buffetType} Buffet',
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
        shadowColor: Colors.black.withAlpha(25),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Number of People
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
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
                        Center(
                          child: Text(
                            'Number of people',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C3E50),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            // Number controls row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: _numberOfPeople > 1
                                        ? const Color.fromARGB(25, 52, 152, 219)
                                        : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: _numberOfPeople > 1 ? () {
                                      setState(() {
                                        _numberOfPeople--;
                                      });
                                    } : null,
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: _numberOfPeople > 1
                                          ? const Color(0xFF3498DB)
                                          : const Color(0xFFBDC3C7),
                                    ),
                                    iconSize: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE9ECEF), width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFF8F9FA),
                                  ),
                                  child: Text(
                                    '$_numberOfPeople',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    color: _numberOfPeople < 50
                                        ? const Color.fromARGB(25, 52, 152, 219)
                                        : const Color(0xFFF8F9FA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: _numberOfPeople < 50 ? () {
                                      setState(() {
                                        _numberOfPeople++;
                                      });
                                    } : null,
                                    icon: Icon(
                                      Icons.add_circle_outline,
                                      color: _numberOfPeople < 50
                                          ? const Color(0xFF3498DB)
                                          : const Color(0xFFBDC3C7),
                                    ),
                                    iconSize: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Total price display
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(25, 39, 174, 96),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Total: £${(_numberOfPeople * widget.pricePerHead).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF27AE60),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Deluxe Format Selection (only for Deluxe buffet)
              if (widget.buffetType == 'Deluxe') ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
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
                          Text(
                            'Deluxe Format:',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2C3E50),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...['Mixed (75% Sandwiches)', 'All Sandwiches', 'All Wraps'].map((format) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _deluxeFormat == format.split(' ')[0]
                                      ? const Color(0xFF9B59B6)
                                      : const Color(0xFFE9ECEF),
                                  width: 2,
                                ),
                                color: _deluxeFormat == format.split(' ')[0]
                                    ? const Color.fromARGB(25, 155, 89, 182)
                                    : Colors.white,
                              ),
                              child: RadioListTile<String>(
                                title: Text(
                                  format,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                                value: format.split(' ')[0],
                                groupValue: _deluxeFormat,
                                activeColor: const Color(0xFF9B59B6),
                                onChanged: (value) {
                                  setState(() {
                                    _deluxeFormat = value!;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Customize Items
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
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
                        Text(
                          'Customize Items:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Uncheck items you don\'t want (minimum 1 required)',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isLoadingItems
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF27AE60),
                                  ),
                                ),
                              )
                            : Column(
                                children: _availableItems.map((item) {
                          final isSelected = _selectedItems[item.id] ?? false;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color.fromARGB(77, 39, 174, 96)
                                    : const Color(0xFFE9ECEF),
                                width: 1,
                              ),
                              color: isSelected
                                  ? const Color.fromARGB(13, 39, 174, 96)
                                  : const Color(0xFFF8F9FA),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              value: isSelected,
                              activeColor: const Color(0xFF27AE60),
                              onChanged: (value) {
                                final selectedCount = _selectedItems.values.where((v) => v).length;
                                if (selectedCount > 1 || value == true) {
                                  setState(() {
                                    _selectedItems[item.id] = value!;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'At least one item must remain selected',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      backgroundColor: const Color(0xFFE74C3C),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Department Label
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
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
                        Text(
                          'Department Label (Optional):',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (value) {
                            _departmentLabel = value;
                          },
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2C3E50),
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g., Marketing Team, Sales Department',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7F8C8D),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: const Color(0xFFE9ECEF)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: const Color(0xFFE9ECEF)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: const Color(0xFF3498DB), width: 2),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Notes
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
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
                        Text(
                          'Special Notes (Optional):',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (value) {
                            _notes = value;
                          },
                          maxLines: 3,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2C3E50),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Any special requirements or notes...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF7F8C8D),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: const Color(0xFFE9ECEF)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: const Color(0xFFE9ECEF)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: const Color(0xFF3498DB), width: 2),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Add to Cart Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(77, 52, 152, 219),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isAddingToCart ? null : _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  icon: _isAddingToCart 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.shopping_cart_outlined,
                        size: 20,
                      ),
                  label: Text(
                    _isAddingToCart 
                      ? 'Adding to Cart...'
                      : 'Add to Cart - £${(_numberOfPeople * widget.pricePerHead).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }
}
