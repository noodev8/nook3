/*
=======================================================================================================================================
Order Status Screen - The Nook of Welshpool
=======================================================================================================================================
This screen shows the order confirmation and status tracking.
Users can see their order number, estimated time, and track progress.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'main_menu_screen.dart';
import '../services/store_info_service.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderNumber;

  const OrderStatusScreen({
    super.key,
    required this.orderNumber,
  });

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {

  String _storePhone = '01938 123456';
  bool _isLoadingContactInfo = true;

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  Future<void> _loadContactInfo() async {
    try {
      final phone = await StoreInfoService.getStorePhone();
      setState(() {
        _storePhone = phone;
        _isLoadingContactInfo = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingContactInfo = false;
      });
    }
  }

  void _goToMainMenu(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Order Status',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
                    // Success Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Success Message
                    Text(
                      'Order Confirmed!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3498DB),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      'Thank you for your order. We\'re preparing your delicious food!',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF7F8C8D),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Order Details Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order Number:',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              widget.orderNumber,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3498DB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Status Timeline
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Status:',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Status Steps
                            _buildStatusStep(
                              icon: Icons.receipt,
                              title: 'Order Received',
                              subtitle: 'We\'ve received your order',
                              isCompleted: true,
                              isActive: false,
                            ),
                            _buildStatusStep(
                              icon: Icons.restaurant,
                              title: 'Preparing',
                              subtitle: 'Your buffet is being prepared',
                              isCompleted: false,
                              isActive: true,
                            ),
                            _buildStatusStep(
                              icon: Icons.local_shipping,
                              title: 'Ready/Out for Delivery',
                              subtitle: 'Ready for collection or delivery',
                              isCompleted: false,
                              isActive: false,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Contact Information
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3498DB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Need to make changes?',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3498DB),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _isLoadingContactInfo
                              ? Text(
                                  'Loading contact information...',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF3498DB),
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Text(
                                  'Call us at $_storePhone with your order number',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: const Color(0xFF3498DB),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                          // Action Buttons
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
                      child: ElevatedButton(
                        onPressed: () => _goToMainMenu(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Place Another Order',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implement order tracking/history
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Order tracking feature coming soon!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: const Color(0xFF3498DB),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3498DB),
                          side: const BorderSide(color: Color(0xFF3498DB), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Track This Order',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Extra bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? const Color(0xFF3498DB)
                    : isActive 
                        ? const Color(0xFFE67E22)
                        : const Color(0xFFBDC3C7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isCompleted 
                      ? const Color(0xFF3498DB)
                      : isActive 
                          ? const Color(0xFFE67E22)
                          : const Color(0xFFBDC3C7),
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: isCompleted || isActive ? Colors.white : const Color(0xFF7F8C8D),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isActive ? const Color(0xFF2C3E50) : const Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isCompleted || isActive ? const Color(0xFF7F8C8D) : const Color(0xFFBDC3C7),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(left: 22),
            width: 2,
            height: 24,
            color: isCompleted ? const Color(0xFF3498DB) : const Color(0xFFE0E6ED),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
