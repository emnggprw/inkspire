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

  /// Flexible API Call Function
  Future<Map<String, dynamic>?> callApi({
    required String apiUrl,
    required Map<String, dynamic> parameters,
    String method = 'POST',
    Map<String, String>? headers,
  }) async {
    headers ??= {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_API_KEY_HERE',
    };

    try {
      final uri = Uri.parse(apiUrl);
      http.Response response;

      if (method.toUpperCase() == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(parameters),
        );
      } else if (method.toUpperCase() == 'GET') {
        final queryString = Uri(queryParameters: parameters).query;
        final getUri = Uri.parse('$apiUrl?$queryString');
        response = await http.get(getUri, headers: headers);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'API call failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('API call error: $e');
      return null;
    }
  }

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

    final apiUrl = 'https://api.openai.com/v1/images/generations';
    final parameters = {
      'prompt': prompt,
      'n': 1,
      'size': '1024x1024',
    };

    final response = await callApi(apiUrl: apiUrl, parameters: parameters);

    if (response != null && response['data'] != null) {
      setState(() {
        generatedImageUrl = response['data'][0]['url'];
        progress = 1.0;
      });
    } else {
      setState(() {
        errorMessage = 'Failed to generate image. Please try again.';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire', style: TextStyle(fontFamily: 'ComicSans', fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _promptController,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                maxLines: 5,
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
                    const Text('Generating...', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress, color: Colors.black, minHeight: 8),
                    Text('${(progress * 100).toStringAsFixed(0)}% completed', style: const TextStyle(fontSize: 14)),
                  ],
                )
              else if (errorMessage != null)
                Column(
                  children: [
                    Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: generateImage,
                      child: const Text('Retry', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                )
              else if (generatedImageUrl != null)
                  Image.network(
                    generatedImageUrl!,
                    fit: BoxFit.cover,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
