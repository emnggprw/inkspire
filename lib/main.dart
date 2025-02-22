import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt cannot be empty!')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      generatedImageUrl = null;
    });

    const String createUrl = 'https://cors-anywhere.herokuapp.com/https://api.starryai.com/creations/';

    try {
      print('Sending POST request to create image...');
      final response = await http.post(
        Uri.parse(createUrl),
        headers: {
          'accept': 'application/json',
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "prompt": prompt,  // Add this line
          "model": "realvisxl",
          "aspectRatio": "square",
          "highResolution": false,
          "images": 1,
          "steps": 20,
          "initialImageMode": "color"
        }),
      );

      print('POST response status: ${response.statusCode}');
      print('POST response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        // Assuming responseData is a map and not a list
        final creationId = responseData["id"];
        final status = responseData["status"];

        // Extract the image URL (if it exists)
        final imageUrl = responseData["images"]?[0]["url"];

        if (status == "completed" && imageUrl != null) {
          print('Image generated successfully: $imageUrl');
          setState(() {
            generatedImageUrl = imageUrl;
            isLoading = false;
          });
        } else {
          // Proceed with polling for image using creationId
          await pollForImage(creationId);
        }
      } else {
        throw Exception('Failed to start image generation: ${response.body}');
      }
    } catch (e) {
      print('Error during image generation: $e');
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> pollForImage(int creationId) async {
    final String pollUrl = 'https://api.starryai.com/creations/$creationId';

    try {
      print('Polling for image with ID: $creationId');
      int retryCount = 0;
      const int maxRetries = 10;

      while (retryCount < maxRetries) {
        final response = await http.get(
          Uri.parse(pollUrl),
          headers: {
            'accept': 'application/json',
            'X-API-Key': apiKey,
          },
        );

        print('GET response status: ${response.statusCode}');
        print('GET response body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final status = responseData['status'];
          print('Current status: $status');

          if (status == 'completed') {
            final imageUrl = responseData['images']?[0]['url'];

            if (imageUrl != null) {
              print('Image generated successfully: $imageUrl');
              setState(() {
                generatedImageUrl = imageUrl;
                isLoading = false;
              });
              break;
            } else {
              throw Exception('Image URL not found.');
            }
          } else if (status == 'failed') {
            throw Exception('Image generation failed.');
          } else if (status == 'submitted') {
            print('Image is still processing...');
          }
        } else {
          print('Error response: ${response.statusCode}');
          print('Error response body: ${response.body}');
          throw Exception('Failed to fetch job status: ${response.body}');
        }

        retryCount++;
        if (retryCount < maxRetries) {
          print('Retrying in ${retryCount * 5} seconds...');
          await Future.delayed(Duration(seconds: retryCount * 5));  // Increase delay after each retry
        } else {
          throw Exception('Max retries reached.');
        }
      }
    } catch (e) {
      print('Error while polling for image: $e');
      setState(() {
        errorMessage = 'Error while polling for image: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                  children: const [
                    Text('Generating...', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    CircularProgressIndicator(color: Colors.black),
                  ],
                )
              else if (errorMessage != null)
                Text(errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16))
              else if (generatedImageUrl != null)
                  Image.network(
                    generatedImageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Failed to load image',
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
