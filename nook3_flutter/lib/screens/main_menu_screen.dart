/*
=======================================================================================================================================
Main Menu Screen - The Nook of Welshpool
=======================================================================================================================================
This is the main menu where users choose between Share Box (1-4 people) or Buffet (5+ people).
Shows pricing and basic information about each option.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'share_box_screen.dart';
import 'buffet_selection_screen.dart';
import 'login_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _showStoreInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Store Information'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Nook of Welshpool',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('42 High Street, Welshpool, SY21 7JQ'),
            SizedBox(height: 16),
            Text(
              'Opening Hours:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Mon-Fri: 8:00 AM - 5:00 PM'),
            Text('Sat: 9:00 AM - 4:00 PM'),
            Text('Sun: Closed'),
            SizedBox(height: 16),
            Text(
              'Contact:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Phone: 07551428162'),
            Text('Email: NOOKBUFFET@GMAIL.COM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 14,
              color: const Color(0xFFE67E22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF2C3E50),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuffetOption(String name, String price, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Soft off-white background
      appBar: AppBar(
        title: Text(
          'Choose Your Order',
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                // TODO: Navigate to cart with current items
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Cart feature - add items first!'),
                    backgroundColor: const Color(0xFF2C3E50),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag_outlined, size: 22),
              tooltip: 'View Cart',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => _showStoreInfo(context),
              icon: const Icon(Icons.info_outline, size: 22),
              tooltip: 'Store Info',
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2C3E50), // Deep charcoal
                    const Color(0xFF34495E), // Slightly lighter charcoal
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The Nook of Welshpool',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Fresh Buffets & Share Boxes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('View Cart'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cart feature - add items first!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Store Information'),
              onTap: () {
                Navigator.pop(context);
                _showStoreInfo(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Opening Hours'),
              subtitle: const Text('Mon-Fri: 8AM-5PM, Sat: 9AM-4PM'),
              onTap: () {
                Navigator.pop(context);
                _showStoreInfo(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Us'),
              subtitle: const Text('07551428162'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call feature would open phone dialer')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Us'),
              subtitle: const Text('NOOKBUFFET@GMAIL.COM'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email feature would open email app')),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message with sophisticated styling
              Text(
                'What would you like to order today?',
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
                'Choose from our premium selection of fresh buffets and share boxes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7F8C8D), // Muted gray
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // Share Box Option
              Container(
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
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ShareBoxScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Header with sophisticated overlay
                        Container(
                          height: 180,
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
                                            const Color(0xFFE67E22), // Warm burnt orange
                                            const Color(0xFFD35400), // Deeper orange
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.lunch_dining,
                                          size: 60,
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
                                      Colors.black.withValues(alpha: 0.3),
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
                                        Text(
                                          'Share Box',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF2C3E50),
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.people_outline,
                                              size: 16,
                                              color: const Color(0xFFE67E22),
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
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: const Color(0xFF2C3E50),
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
                                'Daily mix including:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Premium feature list
                              _buildFeatureItem('Mixed Sandwiches', Icons.lunch_dining),
                              _buildFeatureItem('Crisps', Icons.cookie),
                              _buildFeatureItem('Picky Bits', Icons.restaurant),
                              _buildFeatureItem('Daily specials like Pork Pie & Quiche', Icons.star_outline),

                              const SizedBox(height: 20),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE67E22).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.eco_outlined,
                                      size: 18,
                                      color: const Color(0xFFE67E22),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Choose Traditional or Vegetarian',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFE67E22),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
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
              const SizedBox(height: 32),

              // Buffet Option
              Container(
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
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BuffetSelectionScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Header with sophisticated overlay
                        Container(
                          height: 180,
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
                                  'assets/images/Nook-Buffet-2.jpg',
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
                                            const Color(0xFF3498DB), // Sophisticated blue
                                            const Color(0xFF2980B9), // Deeper blue
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.restaurant_menu,
                                          size: 60,
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
                                      Colors.black.withValues(alpha: 0.3),
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
                                        Text(
                                          'Buffet',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF2C3E50),
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.groups_outlined,
                                              size: 16,
                                              color: const Color(0xFF3498DB),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'For 5 or more people',
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
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: const Color(0xFF2C3E50),
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
                                'Three options available:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Premium buffet options
                              _buildBuffetOption('Classic Buffet', '£9.90 per head', const Color(0xFF27AE60)),
                              _buildBuffetOption('Enhanced Buffet', '£10.90 per head', const Color(0xFFE67E22)),
                              _buildBuffetOption('Deluxe Buffet', '£13.90 per head', const Color(0xFF8E44AD)),

                              const SizedBox(height: 20),

                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF3498DB).withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.tune,
                                      size: 18,
                                      color: const Color(0xFF3498DB),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Mix and match different buffets for your group',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF3498DB),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
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
              const SizedBox(height: 40),

              // Sophisticated info footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFF8F9FA),
                      const Color(0xFFECF0F1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE0E6ED),
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
                            color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.eco_outlined,
                            color: const Color(0xFF27AE60),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'All packaging is recyclable',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            const Color(0xFFBDC3C7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE67E22).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.restaurant_outlined,
                            color: const Color(0xFFE67E22),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Fresh ingredients prepared daily',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2C3E50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
