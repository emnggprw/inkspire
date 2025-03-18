import 'package:flutter/material.dart';
import 'package:inkspire/screens/home_screen.dart';

class InkSpireApp extends StatelessWidget {
  const InkSpireApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root of the app, providing navigation and theming
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner from the app
      title: 'InkSpire',
      theme: ThemeData(
        brightness: Brightness.light, // Light theme for the app
        scaffoldBackgroundColor: Colors.white, // Background color for pages
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // AppBar background color
          foregroundColor: Colors.black, // AppBar text color
          elevation: 0, // Removes shadow under the AppBar
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100], // Background color for text fields
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Button background color
            foregroundColor: Colors.white, // Button text color
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded button shape
            ),
          ),
        ),
      ),
      home: const HomeScreen(), // Main page of the app
    );
  }
}