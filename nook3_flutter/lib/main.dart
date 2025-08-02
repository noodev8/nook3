/*
=======================================================================================================================================
The Nook of Welshpool - Mobile Buffet Ordering App
=======================================================================================================================================
Main entry point for the wireframe application. This app allows customers to order buffets for collection or delivery.
Two main options: Share Box (1-4 people) or Buffet (5+ people) with various customization options.
=======================================================================================================================================
*/

import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const NookApp());
}

class NookApp extends StatelessWidget {
  const NookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Nook of Welshpool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  Widget _homeScreen = const WelcomeScreen();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user has valid auth token
    if (AuthService.isLoggedIn) {
      // Validate the token with server
      final isValid = await AuthService.validateToken();
      
      if (isValid) {
        // Token is valid - go to main menu
        setState(() {
          _homeScreen = const MainMenuScreen();
          _isLoading = false;
        });
      } else {
        // Token expired - go to login
        await AuthService.logout(); // Clear local data
        setState(() {
          _homeScreen = const LoginScreen();
          _isLoading = false;
        });
      }
    } else {
      // No auth token - go to welcome screen
      setState(() {
        _homeScreen = const WelcomeScreen();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2C3E50),
                      const Color(0xFF34495E),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'The Nook of Welshpool',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF3498DB)),
              ),
            ],
          ),
        ),
      );
    }

    return _homeScreen;
  }
}


