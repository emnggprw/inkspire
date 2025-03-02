import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

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
  String? errorMessage;
  final String apiKey = 'V_OqA3P49bgkpCZwCBFtfUpgfn-8IQ';

  Future<void> generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _showSnackbar('Prompt cannot be empty!');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      generatedImageUrl = null;
    });

    const String createUrl = 'https://cors-anywhere.herokuapp.com/https://api.starryai.com/creations/';

    try {
      final response = await http.post(
        Uri.parse(createUrl),
        headers: {
          'accept': 'application/json',
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "prompt": prompt,
          "model": "realvisxl",
          "aspectRatio": "square",
          "highResolution": false,
          "images": 1,
          "steps": 20,
          "initialImageMode": "color"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final creationId = responseData["id"];
        final status = responseData["status"];
        final imageUrl = responseData["images"]?[0]["url"];

        if (status == "completed" && imageUrl != null) {
          setState(() {
            generatedImageUrl = "$imageUrl?cache_buster=${DateTime.now().millisecondsSinceEpoch}";
            isLoading = false;
          });
        } else {
          await pollForImage(creationId);
        }
      } else {
        throw Exception('Failed to start image generation: ${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> pollForImage(int creationId) async {
    final String pollUrl = 'https://cors-anywhere.herokuapp.com/https://api.starryai.com/creations/$creationId';
    int retryCount = 0;
    const int maxRetries = 10;

    while (retryCount < maxRetries) {
      try {
        final response = await http.get(
          Uri.parse(pollUrl),
          headers: {'accept': 'application/json', 'X-API-Key': apiKey},
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final status = responseData['status'];
          final imageUrl = responseData['images']?[0]['url'];

          if (status == 'completed' && imageUrl != null) {
            setState(() {
              generatedImageUrl = imageUrl;
              isLoading = false;
            });
            return;
          } else if (status == 'failed') {
            throw Exception('Image generation failed.');
          }
        }
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 5));
      } catch (e) {
        setState(() {
          errorMessage = 'Error while polling for image: $e';
          isLoading = false;
        });
        return;
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InkSpire', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
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
              const Column(children: [
                Text('Generating...', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                CircularProgressIndicator(color: Colors.black),
              ])
            else if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16))
            else if (generatedImageUrl != null)
                Image.network(generatedImageUrl!, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
