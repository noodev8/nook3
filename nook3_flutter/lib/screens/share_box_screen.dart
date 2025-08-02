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
import '../services/category_service.dart';

class ShareBoxScreen extends StatefulWidget {
  const ShareBoxScreen({super.key});

  @override
  State<ShareBoxScreen> createState() => _ShareBoxScreenState();
}

class _ShareBoxScreenState extends State<ShareBoxScreen> {
  String _selectedType = '';
  int _quantity = 1;
  bool _isLoadingPrices = true;
  Map<String, double> _shareBoxPrices = {
    'Traditional': 12.50, // Default fallback prices
    'Vegetarian': 11.50,
  };
  
  double get _totalPrice {
    if (_selectedType.isEmpty) return 0.0;
    return (_shareBoxPrices[_selectedType] ?? 0.0) * _quantity;
  }
  
  @override
  void initState() {
    super.initState();
    _loadShareBoxPrices();
  }
  
  Future<void> _loadShareBoxPrices() async {
    try {
      final prices = await CategoryService.getShareBoxPrices();
      setState(() {
        _shareBoxPrices = prices;
        _isLoadingPrices = false;
      });
    } catch (e) {
      // Keep default prices if loading fails
      setState(() {
        _isLoadingPrices = false;
      });
    }
  }

  void _addToCart() {
    if (_selectedType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a share box type')),
      );
      return;
    }
    
    // TODO: Implement share box cart integration similar to buffet system
    // For now, navigate to empty cart - share box integration pending
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(
          sessionId: 'temp_session_${DateTime.now().millisecondsSinceEpoch}',
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
          'Share Box',
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
        shadowColor: Colors.black.withAlpha( 25),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with sophisticated styling
              Text(
                'Share Box Options',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50), // Deep charcoal
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Perfect for 1-4 people • Daily fresh mix',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7F8C8D), // Muted gray
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Traditional Option with enhanced selection styling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedType == 'Traditional'
                        ? const Color(0xFF81C784)
                        : const Color(0xFFE0E6ED),
                    width: _selectedType == 'Traditional' ? 3 : 1,
                  ),
                  color: _selectedType == 'Traditional' 
                      ? const Color.fromARGB(13, 129, 199, 132)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _selectedType == 'Traditional'
                          ? const Color.fromARGB(77, 129, 199, 132)
                          : Colors.black.withAlpha( 20),
                      blurRadius: _selectedType == 'Traditional' ? 20 : 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha( 20),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha( 10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = 'Traditional';
                        _quantity = 1; // Reset quantity when switching
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Header with sophisticated styling
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                child: Image.asset(
                                  'assets/images/Nook-Buffet-1.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color.fromARGB(204, 230, 126, 34),
                                            const Color(0xFFD35400),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.lunch_dining,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Sophisticated gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withAlpha( 77),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content with sophisticated styling
                        Padding(
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Traditional Share Box',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF2C3E50),
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                            ),
                                            _isLoadingPrices
                                                ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        const Color(0xFFE67E22),
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    '£${_shareBoxPrices['Traditional']!.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF2C3E50),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.people_outline,
                                              size: 16,
                                              color: const Color(0xFF81C784),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Perfect for 1-4 people',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF7F8C8D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

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
                              const SizedBox(height: 20),

                              Text(
                                'Includes:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '• Mixed Sandwiches (various fillings)\n• Assorted Crisps\n• Picky Bits selection\n• Daily specials (Pork Pie, Quiche, etc.)',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF7F8C8D),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Quantity selector for Traditional (appears when selected)
              if (_selectedType == 'Traditional') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(13, 129, 199, 132),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(51, 129, 199, 132),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: _quantity > 1 ? () {
                                setState(() {
                                  _quantity--;
                                });
                              } : null,
                              icon: Icon(
                                Icons.remove,
                                color: _quantity > 1 ? Colors.white : Colors.white.withAlpha(128),
                                size: 20,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF81C784)),
                            ),
                            child: Text(
                              '$_quantity',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),

              // Vegetarian Option with enhanced selection styling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedType == 'Vegetarian'
                        ? const Color(0xFF81C784)
                        : const Color(0xFFE0E6ED),
                    width: _selectedType == 'Vegetarian' ? 3 : 1,
                  ),
                  color: _selectedType == 'Vegetarian' 
                      ? const Color.fromARGB(13, 129, 199, 132)
                      : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: _selectedType == 'Vegetarian'
                          ? const Color.fromARGB(77, 129, 199, 132)
                          : Colors.black.withAlpha( 20),
                      blurRadius: _selectedType == 'Vegetarian' ? 20 : 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha( 20),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha( 10),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedType = 'Vegetarian';
                        _quantity = 1; // Reset quantity when switching
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Header with sophisticated styling
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                child: Image.asset(
                                  'assets/images/Nook-Buffet-3.jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color.fromARGB(204, 39, 174, 96),
                                            const Color(0xFF229954),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.eco,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Sophisticated gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withAlpha( 77),
                                    ],
                                    stops: const [0.6, 1.0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Content with sophisticated styling
                        Padding(
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Vegetarian Share Box',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF2C3E50),
                                                  letterSpacing: -0.3,
                                                ),
                                              ),
                                            ),
                                            _isLoadingPrices
                                                ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        const Color(0xFF81C784),
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    '£${_shareBoxPrices['Vegetarian']!.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w700,
                                                      color: const Color(0xFF2C3E50),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.eco_outlined,
                                              size: 16,
                                              color: const Color(0xFF81C784),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Plant-based & fresh',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF7F8C8D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

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
                              const SizedBox(height: 20),

                              Text(
                                'Includes:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '• Vegetarian Sandwiches\n• Assorted Crisps\n• Vegetarian Picky Bits\n• Vegetarian daily specials (Quiche, etc.)',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF7F8C8D),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Quantity selector for Vegetarian (appears when selected)
              if (_selectedType == 'Vegetarian') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(13, 129, 199, 132),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(51, 129, 199, 132),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: _quantity > 1 ? () {
                                setState(() {
                                  _quantity--;
                                });
                              } : null,
                              icon: Icon(
                                Icons.remove,
                                color: _quantity > 1 ? Colors.white : Colors.white.withAlpha(128),
                                size: 20,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF81C784)),
                            ),
                            child: Text(
                              '$_quantity',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),

              // Add to Cart Button with sophisticated styling
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedType.isNotEmpty
                          ? const Color.fromARGB(77, 52, 152, 219)  // Blue shadow
                          : Colors.black.withAlpha( 25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _selectedType.isNotEmpty ? _addToCart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType.isNotEmpty
                        ? const Color(0xFF3498DB)  // Blue as requested
                        : const Color(0xFFBDC3C7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _selectedType.isEmpty
                      ? 'Select an option above'
                      : 'Add to Cart - £${_totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
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
