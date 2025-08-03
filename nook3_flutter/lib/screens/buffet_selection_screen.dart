/*
=======================================================================================================================================
Buffet Selection Screen - The Nook of Welshpool
=======================================================================================================================================
This screen shows the three buffet options (Classic, Enhanced, Deluxe) for 5+ people.
Users can see pricing and what's included in each buffet type.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'buffet_customisation_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import '../services/category_service.dart';

class BuffetSelectionScreen extends StatefulWidget {
  const BuffetSelectionScreen({super.key});

  @override
  State<BuffetSelectionScreen> createState() => _BuffetSelectionScreenState();
}

class _BuffetSelectionScreenState extends State<BuffetSelectionScreen> {
  bool _isLoadingPrices = true;
  Map<String, double> _buffetPrices = {
    'Classic': 9.90, // Default fallback prices
    'Enhanced': 10.90,
    'Deluxe': 13.90,
  };
  
  @override
  void initState() {
    super.initState();
    _loadBuffetPrices();
  }
  
  Future<void> _loadBuffetPrices() async {
    try {
      final prices = await CategoryService.getBuffetPrices();
      setState(() {
        _buffetPrices = prices;
        _isLoadingPrices = false;
      });
    } catch (e) {
      // Keep default prices if loading fails
      setState(() {
        _isLoadingPrices = false;
      });
    }
  }

  void _selectBuffet(BuildContext context, String buffetType) {
    final price = _buffetPrices[buffetType] ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuffetCustomisationScreen(
          buffetType: buffetType,
          pricePerHead: price,
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
          'Choose Buffet',
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
              // Header with sophisticated styling
              Text(
                'Buffet Options',
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
                'Choose from our premium buffet selection for 5+ people',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7F8C8D), // Muted gray
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Classic Buffet section header
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color.fromARGB(25, 39, 174, 96),
                      const Color.fromARGB(13, 39, 174, 96),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.restaurant_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Classic Buffet - Great Value',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Classic Buffet with enhanced styling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(77, 39, 174, 96),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(38, 39, 174, 96),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
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
                  child: InkWell(
                    onTap: () => _selectBuffet(context, 'Classic'),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Header
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color.fromARGB(204, 52, 152, 219),
                                const Color(0xFF2980B9),
                              ],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/Nook-Buffet-2.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color.fromARGB(204, 52, 152, 219),
                                        const Color(0xFF2980B9),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.restaurant_menu,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Content
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
                                          'Classic Buffet',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF2C3E50),
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _isLoadingPrices
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    const Color(0xFF27AE60),
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                '£${_buffetPrices['Classic']!.toStringAsFixed(2)} per head',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 18,
                                                  color: const Color(0xFF2C3E50),
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                                      color: const Color(0xFF7F8C8D),
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Main Items:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sandwiches: Egg Mayo & Cress, Ham Salad, Cheese & Onion, Tuna Mayo, Beef Salad',
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
                                'Sides:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Quiche, Cocktail Sausages, Sausage Rolls, Cheese & Onion Rolls, Pork Pies, Scotch Eggs, Tortillas/Dips, Assortment of Cakes',
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
              const SizedBox(height: 40),

              // Enhanced Buffet section header
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color.fromARGB(25, 230, 126, 34),
                      const Color.fromARGB(13, 230, 126, 34),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE67E22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.star_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enhanced Buffet - Most Popular',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced Buffet with enhanced styling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(77, 230, 126, 34),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(38, 230, 126, 34),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
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
                  child: InkWell(
                    onTap: () => _selectBuffet(context, 'Enhanced'),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Header
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color.fromARGB(204, 230, 126, 34),
                                const Color(0xFFD35400),
                              ],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/Nook-Buffet-3.jpg',
                              fit: BoxFit.cover,
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
                                      Icons.star,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Content
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
                                          'Enhanced Buffet',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF2C3E50),
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _isLoadingPrices
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    const Color(0xFF27AE60),
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                '£${_buffetPrices['Enhanced']!.toStringAsFixed(2)} per head',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 18,
                                                  color: const Color(0xFF2C3E50),
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                                      color: const Color(0xFF7F8C8D),
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Everything in Classic PLUS:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE67E22),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Additional Sandwiches:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Coronation Chicken',
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
                                'Additional Sides:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Vegetable sticks & Dips, Cheese/Pineapple/Grapes, Bread Sticks, Pickles, Coleslaw',
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
              const SizedBox(height: 40),

              // Deluxe Buffet section header
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color.fromARGB(25, 155, 89, 182),
                      const Color.fromARGB(13, 155, 89, 182),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B59B6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.diamond_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Deluxe Buffet - Premium',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Deluxe Buffet with enhanced styling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(77, 155, 89, 182),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(38, 155, 89, 182),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
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
                  child: InkWell(
                    onTap: () => _selectBuffet(context, 'Deluxe'),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Header
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color.fromARGB(204, 155, 89, 182),
                                const Color(0xFF8E44AD),
                              ],
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/Nook-Buffet-4.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color.fromARGB(204, 155, 89, 182),
                                        const Color(0xFF8E44AD),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.diamond,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Content
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
                                          'Deluxe Buffet',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF2C3E50),
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _isLoadingPrices
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    const Color(0xFF27AE60),
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                '£${_buffetPrices['Deluxe']!.toStringAsFixed(2)} per head',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 18,
                                                  color: const Color(0xFF2C3E50),
                                                  fontWeight: FontWeight.w600,
                                                ),
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
                                      color: const Color(0xFF7F8C8D),
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Premium Selection:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9B59B6),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sandwiches:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ham & Mustard, Coronation Chicken & Baby Gem, Egg & Cress, Beef/Horseradish/Tomato/Rocket, Cheese & Onion, Turkey & Cranberry, Chicken/Bacon/Chive Mayo',
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
                                'Premium Sides:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Greek Salad, Potato Salad, Tomato & Mozzarella Skewers, Fresh Vegetables, Premium Dips, and much more...',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF7F8C8D),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(25, 155, 89, 182),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Choose: Mixed (75% Sandwiches), All Sandwiches, or All Wraps',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF9B59B6),
                                    fontWeight: FontWeight.w500,
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
              ),
              const SizedBox(height: 32), // Extra padding at bottom
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3498DB),
        unselectedItemColor: const Color(0xFF7F8C8D),
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
        currentIndex: 0, // No current selection since this is a sub-screen
        onTap: (index) {
          switch (index) {
            case 0:
              // Home
              Navigator.popUntil(context, (route) => route.isFirst);
              break;
            case 1:
              // Cart
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
              break;
            case 2:
              // Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
            case 3:
              // Store Info - placeholder
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}
