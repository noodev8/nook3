/*
=======================================================================================================================================
Delivery Options Screen - The Nook of Welshpool
=======================================================================================================================================
This screen allows users to choose between Collection or Delivery options.
For delivery, users can enter their address. For collection, shows store address and hours.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'order_status_screen.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';

class DeliveryOptionsScreen extends StatefulWidget {
  final List<dynamic> cartItems; // Temporary fix - will need proper CartItem integration
  final double totalAmount;

  const DeliveryOptionsScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<DeliveryOptionsScreen> createState() => _DeliveryOptionsScreenState();
}

class _DeliveryOptionsScreenState extends State<DeliveryOptionsScreen> {
  String _selectedOption = '';
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmittingOrder = false;

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _confirmOrder() async {
    // Validation checks
    if (_selectedOption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select delivery or collection')),
      );
      return;
    }
    
    if (_selectedOption == 'Delivery' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }
    
    // Email and phone validation
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    
    // If user is logged in, get email from their profile
    if (AuthService.isLoggedIn && AuthService.currentUser?.email != null) {
      email = AuthService.currentUser!.email!;
    }
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required for order confirmation')),
      );
      return;
    }
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required for order updates')),
      );
      return;
    }
    
    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    
    setState(() {
      _isSubmittingOrder = true;
    });
    
    try {
      // TODO: Create order submission API
      // For now, show confirmation dialog then navigate to order status
      
      bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirm Order',
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
                'Order Total: £${widget.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF27AE60),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Delivery: $_selectedOption',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              if (_selectedOption == 'Delivery') ...[
                const SizedBox(height: 4),
                Text(
                  'Address: ${_addressController.text}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: const Color(0xFF7F8C8D),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Time: ${_selectedTime!.format(context)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Confirmation will be sent to: $email',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: const Color(0xFF7F8C8D),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7F8C8D),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Confirm Order',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // Navigate to order status screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderStatusScreen(
              orderNumber: 'NK001234', // TODO: Get from API response
              estimatedTime: '45 minutes',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit order: $e')),
      );
    } finally {
      setState(() {
        _isSubmittingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Soft off-white background
      appBar: AppBar(
        title: Text(
          'Delivery Options',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How would you like to receive your order?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C3E50), // Deep charcoal
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              
              Expanded(
                child: ListView(
                  children: [
                    // Collection Option with sophisticated styling
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedOption == 'Collection'
                              ? const Color(0xFF3498DB)
                              : const Color(0xFF3498DB).withOpacity( 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _selectedOption == 'Collection'
                                ? const Color(0xFF3498DB).withOpacity( 0.25)
                                : const Color(0xFF3498DB).withOpacity( 0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                            spreadRadius: 0,
                          ),
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
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedOption = 'Collection';
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3498DB).withOpacity( 0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: const Color(0xFF3498DB).withOpacity( 0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.store_outlined,
                                        size: 28,
                                        color: Color(0xFF3498DB),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Collection',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2C3E50),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                    if (_selectedOption == 'Collection')
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF27AE60),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
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
                                  'Collect from our store:',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'The Nook of Welshpool\n42 High Street, Welshpool, SY21 7JQ',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF7F8C8D),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Opening Hours:',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Mon-Fri: 8:00 AM - 5:00 PM\nSat: 9:00 AM - 4:00 PM\nSun: Closed',
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Delivery Option with sophisticated styling
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedOption == 'Delivery'
                              ? const Color(0xFFE67E22)
                              : const Color(0xFFE67E22).withOpacity( 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _selectedOption == 'Delivery'
                                ? const Color(0xFFE67E22).withOpacity( 0.25)
                                : const Color(0xFFE67E22).withOpacity( 0.15),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                            spreadRadius: 0,
                          ),
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
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedOption = 'Delivery';
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE67E22).withOpacity( 0.1),
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: const Color(0xFFE67E22).withOpacity( 0.2),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.local_shipping_outlined,
                                        size: 28,
                                        color: Color(0xFFE67E22),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Delivery',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2C3E50),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                    if (_selectedOption == 'Delivery')
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF27AE60),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
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
                                  'We deliver to your location',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Delivery charges may apply based on distance',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF7F8C8D),
                                    height: 1.5,
                                  ),
                                ),
                                if (_selectedOption == 'Delivery') ...[
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: _addressController,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Delivery Address *',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: const Color(0xFF7F8C8D),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color(0xFFE0E6ED),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: const Color(0xFFE67E22),
                                          width: 2,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        color: const Color(0xFFE67E22),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFFAFAFA),
                                    ),
                                    maxLines: 3,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Date and Time Selection with sophisticated styling
                    if (_selectedOption.isNotEmpty) ...[
                      Text(
                        'Select Date & Time:',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity( 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: _selectDate,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3498DB).withOpacity( 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.calendar_today_outlined,
                                            color: const Color(0xFF3498DB),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _selectedDate == null
                                              ? 'Select Date'
                                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2C3E50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity( 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: _selectTime,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE67E22).withOpacity( 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.access_time_outlined,
                                            color: const Color(0xFFE67E22),
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _selectedTime == null
                                              ? 'Select Time'
                                              : _selectedTime!.format(context),
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2C3E50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Email Address with sophisticated styling
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: const Color(0xFF2C3E50),
                        ),
                        decoration: InputDecoration(
                          labelText: AuthService.isLoggedIn && AuthService.currentUser?.email != null 
                              ? 'Email (from account: ${AuthService.currentUser!.email!})'
                              : 'Email Address',
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: const Color(0xFF7F8C8D),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFFE0E6ED),
                              width: 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFFE0E6ED),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF3498DB),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: const Color(0xFF7F8C8D),
                          ),
                        ),
                        enabled: !(AuthService.isLoggedIn && AuthService.currentUser?.email != null),
                      ),
                      const SizedBox(height: 16),

                      // Phone Number with sophisticated styling
                      TextField(
                        controller: _phoneController,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: const Color(0xFF2C3E50),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Contact Phone Number',
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            color: const Color(0xFF7F8C8D),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFFE0E6ED),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: const Color(0xFF3498DB),
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: const Color(0xFF3498DB),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button with sophisticated styling
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedOption.isNotEmpty
                          ? const Color(0xFF3498DB).withOpacity( 0.3)
                          : Colors.black.withOpacity( 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _selectedOption.isNotEmpty && !_isSubmittingOrder ? _confirmOrder : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption.isNotEmpty
                        ? const Color(0xFF3498DB)
                        : const Color(0xFFBDC3C7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isSubmittingOrder 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          Icons.check_circle_outlined,
                          size: 20,
                        ),
                  label: Text(
                    _isSubmittingOrder
                        ? 'Confirming Order...'
                        : _selectedOption.isEmpty
                            ? 'Select an option above'
                            : 'Confirm Order',
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
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
