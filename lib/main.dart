import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const InkSpireApp());
}

class InkSpireApp extends StatelessWidget {
  const InkSpireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InkSpire',
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
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const InkSpireHomePage(),
    );
  }
}

class InkSpireHomePage extends StatefulWidget {
  const InkSpireHomePage({super.key});

  @override
  State<InkSpireHomePage> createState() => _InkSpireHomePageState();
}

class _InkSpireHomePageState extends State<InkSpireHomePage> {
  final TextEditingController _promptController = TextEditingController();
  String? generatedImageUrl;
  bool isLoading = false;

  Future<void> generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Replace with your API endpoint
      const apiUrl = 'https://api.example.com/generate-image';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() => generatedImageUrl = data['image_url']);
      } else {
        throw Exception('Failed to generate image.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire', style: TextStyle(fontFamily: 'ComicSans', fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _promptController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Enter your prompt... (like describing a manga panel)',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: generateImage,
              child: const Text('Generate Image', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : generatedImageUrl != null
                ? Expanded(
              child: Image.network(
                generatedImageUrl!,
                fit: BoxFit.cover,
              ),
            )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
