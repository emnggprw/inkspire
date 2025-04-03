import 'package:flutter/material.dart';
import 'package:inkspire/presentation/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:inkspire/providers/theme_provider.dart';

class InkSpireApp extends StatelessWidget {
  const InkSpireApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InkSpire',
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        cardColor: Colors.white,
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.indigo,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Darker gray for better contrast
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white60),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E), // Slightly lighter black for depth
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1E1E), // Matches app bar for consistency
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.deepPurpleAccent, // Stands out in dark mode
          textTheme: ButtonTextTheme.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[900], // Slightly lighter than the background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          hintStyle: const TextStyle(color: Colors.white70),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
