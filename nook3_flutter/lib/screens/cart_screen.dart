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
import '../services/cart_service.dart';
import '../services/auth_service.dart';

class CartScreen extends StatefulWidget {
  final int? userId;
  final String? sessionId;

  const CartScreen({
    super.key,
    this.userId,
    this.sessionId,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;
  bool _isDeleting = false;
  double _totalAmount = 0.0;
  String? _errorMessage;
  Map<int, String> _categoryNames = {}; // categoryId -> category name

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      // Determine user ID or session ID based on login status
      int? userId = widget.userId;
      String? sessionId = widget.sessionId;
      
      if (userId == null && sessionId == null) {
        if (AuthService.isLoggedIn) {
          userId = AuthService.currentUser?.id;
        } else {
          sessionId = await CartService.getSessionId();
        }
      }
      
      // Load cart items and validation info concurrently
      final results = await Future.wait([
        CartService.getCart(userId: userId, sessionId: sessionId),
        CartService.getCartValidation(userId: userId, sessionId: sessionId),
      ]);
      
      final cartResult = results[0] as CartResult;
      final validationResult = results[1] as CartValidationResult;

      if (cartResult.success) {
        setState(() {
          _cartItems = cartResult.cartItems ?? [];
          _totalAmount = cartResult.totalAmount ?? 0.0;
          
          // Load validation info if available
          if (validationResult.success) {
            _categoryNames = validationResult.categoryNames ?? {};
          }
          
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = cartResult.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cart: $e';
        _isLoading = false;
      });
    }
  }

  double _calculateTotal() {
    // Use API total if available, otherwise calculate from items
    if (_totalAmount > 0) {
      return _totalAmount;
    }
    
    // Fallback: calculate from cart items
    double total = 0.0;
    for (var item in _cartItems) {
      total += item.totalPrice;
    }
    return total;
  }

  Future<void> _removeItem(int index) async {
    if (_isDeleting) return;

    final item = _cartItems[index];
    
    setState(() {
      _isDeleting = true;
    });

    try {
      // Determine user ID or session ID based on login status
      int? userId = widget.userId;
      String? sessionId = widget.sessionId;
      
      if (userId == null && sessionId == null) {
        if (AuthService.isLoggedIn) {
          userId = AuthService.currentUser?.id;
        } else {
          sessionId = await CartService.getSessionId();
        }
      }
      
      final result = await CartService.deleteCartItem(
        userId: userId,
        sessionId: sessionId,
        orderCategoryId: item.orderCategoryId,
      );

      if (result.success) {
        setState(() {
          _cartItems = result.cartItems ?? [];
          _totalAmount = result.totalAmount ?? 0.0;
          _isDeleting = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        }
        setState(() {
          _isDeleting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: $e')),
        );
      }
      setState(() {
        _isDeleting = false;
      });
    }
  }

  Map<int, int> _getCategoryQuantities() {
    Map<int, int> quantities = {};
    for (var item in _cartItems) {
      quantities[item.categoryId] = (quantities[item.categoryId] ?? 0) + item.quantity;
    }
    return quantities;
  }

  List<String> _getValidationErrors() {
    List<String> errors = [];
    final categoryQuantities = _getCategoryQuantities();
    
    // Calculate total buffet quantities (categories 3, 4, 5)
    final buffetCategoryIds = [3, 4, 5]; // Classic, Enhanced, Deluxe buffets
    int totalBuffetQuantity = 0;
    
    for (int categoryId in buffetCategoryIds) {
      totalBuffetQuantity += categoryQuantities[categoryId] ?? 0;
    }
    
    // Check if there are any buffet items and if they meet minimum of 5
    if (totalBuffetQuantity > 0 && totalBuffetQuantity < 5) {
      errors.add('Buffets require a minimum of 5 people total. You currently have $totalBuffetQuantity people across all buffet selections.');
    }
    
    return errors;
  }

  void _proceedToDelivery() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    // Check minimum quantity requirements for all categories
    final validationErrors = _getValidationErrors();
    
    if (validationErrors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Minimum Order Required',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please ensure all minimum requirements are met:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 12),
              ...validationErrors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $error',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3498DB),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        shadowColor: Colors.black.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF27AE60),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your cart...',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: const Color(0xFFE74C3C),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading cart',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadCart,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _cartItems.isEmpty
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
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
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
                                              'Buffet - ${item.categoryName}',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF2C3E50),
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item.quantity} people × £${item.unitPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF7F8C8D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F9FA),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          onPressed: _isDeleting ? null : () => _removeItem(index),
                                          icon: const Icon(Icons.delete_outline),
                                          color: const Color(0xFFE74C3C),
                                        ),
                                      ),
                                    ],
                                  ),

                                  if (item.departmentLabel != null && item.departmentLabel!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Department: ${item.departmentLabel}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: const Color(0xFF3498DB),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],

                                  if (item.notes != null && item.notes!.isNotEmpty && !item.notes!.contains('Metadata:')) ...[
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
                                        'Notes: ${item.notes}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: const Color(0xFF7F8C8D),
                                        ),
                                      ),
                                    ),
                                  ],

                                  if (item.deluxeFormat != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFF9B59B6).withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Format: ${item.deluxeFormat}',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          color: const Color(0xFF9B59B6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],

                                  if (item.includedItems.isNotEmpty) ...[
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
                                      children: item.includedItems.map((menuItem) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: const Color(0xFF27AE60).withValues(alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            menuItem.name,
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
                                        '£${item.totalPrice.toStringAsFixed(2)}',
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
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -8),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Show validation warnings if any categories don't meet minimums
                        if (_getValidationErrors().isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFD60A),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_outlined,
                                  color: const Color(0xFFB08800),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Minimum requirements not met',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: const Color(0xFFB08800),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                color: const Color(0xFF3498DB).withValues(alpha: 0.3),
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
