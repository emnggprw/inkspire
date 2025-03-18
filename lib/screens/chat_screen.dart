import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inkspire/utils/fetch_image_bytes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _promptController = TextEditingController(); // To get user input
  String? generatedImageUrl; // Stores the generated image URL
  bool isLoading = false; // Controls loading state
  String? errorMessage; // Stores error messages

  final String apiKey = 'V_OqA3P49bgkpCZwCBFtfUpgfn-8IQ'; // API key for image generation

  // Function to generate an image based on the user prompt
  Future<void> generateImage() async {
    final prompt = _promptController.text.trim(); // Get the user input
    if (prompt.isEmpty) {
      // Show error if the prompt is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt cannot be empty!')),
      );
      return;
    }

    // Update UI to show loading state
    setState(() {
      isLoading = true;
      errorMessage = null;
      generatedImageUrl = null;
    });

    const String createUrl = 'https://api.starryai.com/creations/';

    try {
      // Send POST request to the image generation API
      print('$prompt');
      final response = await http.post(
        Uri.parse(createUrl),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'X-API-Key': 'V_OqA3P49bgkpCZwCBFtfUpgfn-8IQ'
        },
        body: jsonEncode({
          'prompt': '$prompt',
          'model': 'realvisxl',
          'aspectRatio': 'square',
          'highResolution': false,
          'images': 1,
          'steps': 10,
          'initialImageMode': "color"
        }),
      );

      print('$response');

      // Check if the image generation request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final creationId = responseData["id"];
        final status = responseData["status"];
        final imageUrl = responseData["images"]?[0]["url"];

        if (status == "completed" && imageUrl != null) {
          // Image generated successfully
          String urlWithCacheBuster = "$imageUrl?cache_buster=${DateTime.now().millisecondsSinceEpoch}";

          setState(() {
            generatedImageUrl = urlWithCacheBuster;
          });

          await Future.delayed(const Duration(seconds: 2)); // Delay for user experience

          setState(() {
            isLoading = false;
          });
        } else {
          // If not completed, start polling to check the status
          await pollForImage(creationId);
        }
      } else {
        // Handle failure
        throw Exception('Failed to start image generation: ${response.body}');
      }
    } catch (e) {
      // Show error message if something goes wrong
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Function to check the status of image generation
  Future<void> pollForImage(int creationId) async {
    final String pollUrl = 'https://cors-anywhere.herokuapp.com/https://api.starryai.com/creations/$creationId';

    try {
      int retryCount = 0;
      const int maxRetries = 10; // Maximum number of retries

      while (retryCount < maxRetries) {
        final response = await http.get(
          Uri.parse(pollUrl),
          headers: {
            'accept': 'application/json',
            'X-API-Key': apiKey,
          },
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final status = responseData['status'];
          final imageUrl = responseData['images']?[0]['url'];

          if (status == 'completed' && imageUrl != null && imageUrl.isNotEmpty) {
            // Image is ready
            setState(() {
              generatedImageUrl = imageUrl;
              isLoading = false;
            });
            break;
          } else if (status == 'failed') {
            throw Exception('Image generation failed.');
          }
        }

        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 5)); // Delay before retry
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error while polling for image: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The user interface of the app
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text field for user input (prompt)
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

              // Button to generate the image
              ElevatedButton(
                onPressed: generateImage,
                child: const Text('Generate Image', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 24),

              // Show loading indicator while generating the image
              if (isLoading)
                Column(
                  children: const [
                    Text('Generating...', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    CircularProgressIndicator(color: Colors.black),
                  ],
                )
              // Show error message if something goes wrong
              else if (errorMessage != null)
                Text(errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16))
              // Display the generated image
              else if (generatedImageUrl != null)
                  FutureBuilder(
                    future: fetchImageBytes(generatedImageUrl!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading image: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return const Text('No image data available.');
                      }
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}