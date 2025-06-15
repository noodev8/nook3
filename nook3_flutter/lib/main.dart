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
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}


