import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  double progress = 0.0;
  String? errorMessage;

  Future<void> generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt cannot be empty!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      progress = 0.0;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse('https://api.example.com/generate-image');
      final request = http.MultipartRequest('POST', uri)
        ..fields['prompt'] = prompt;

      final streamedResponse = await request.send();
      final contentLength = streamedResponse.contentLength ?? 0;
      int bytesReceived = 0;

      streamedResponse.stream.listen((chunk) {
        bytesReceived += chunk.length;
        setState(() {
          progress = (bytesReceived / contentLength).clamp(0.0, 1.0);
        });
      }, onDone: () async {
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            generatedImageUrl = data['image_url'];
            progress = 1.0;
          });
        } else {
          throw Exception('Failed to generate image. Please try again.');
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
            if (isLoading)
              Column(
                children: [
                  const Text('Generating...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toStringAsFixed(0)}% completed',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              )
            else if (errorMessage != null)
              Column(
                children: [
                  Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: generateImage,
                    child: const Text('Retry'),
                  ),
                ],
              )
            else if (generatedImageUrl != null)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      generatedImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}