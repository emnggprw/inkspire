import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inkspire/utils/fetch_image_bytes.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final TextEditingController _promptController = TextEditingController();
  List<Map<String, String?>> promptHistory = []; // Stores prompt history
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
      promptHistory.insert(0, {'prompt': prompt, 'status': 'Generating...'});
    });

    const String createUrl = 'https://api.starryai.com/creations/';

    try {
      final response = await http.post(
        Uri.parse(createUrl),
        headers: {
          'accept': 'application/json',
          'content-type': 'application/json',
          'X-API-Key': apiKey
        },
        body: jsonEncode({
          'prompt': prompt,
          'model': 'realvisxl',
          'aspectRatio': 'square',
          'highResolution': false,
          'images': 1,
          'steps': 10,
          'initialImageMode': "color"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final creationId = responseData["id"];
        final status = responseData["status"];
        final imageUrl = responseData["images"]?[0]["url"];

        if (status == "completed" && imageUrl != null) {
          String urlWithCacheBuster = "$imageUrl?cache_buster=${DateTime.now().millisecondsSinceEpoch}";
          setState(() {
            generatedImageUrl = urlWithCacheBuster;
            updatePromptHistory(prompt, 'Completed', urlWithCacheBuster);
          });
        } else {
          await pollForImage(creationId, prompt);
        }
      } else {
        throw Exception('Failed to start image generation: ${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
        updatePromptHistory(prompt, 'Failed', null);
      });
    }
  }

  Future<void> pollForImage(int creationId, String prompt) async {
    final String pollUrl = 'https://cors-anywhere.herokuapp.com/https://api.starryai.com/creations/$creationId';

    try {
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

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final status = responseData['status'];
          final imageUrl = responseData['images']?[0]['url'];

          if (status == 'completed' && imageUrl != null) {
            setState(() {
              generatedImageUrl = imageUrl;
              isLoading = false;
              updatePromptHistory(prompt, 'Completed', imageUrl);
            });
            break;
          } else if (status == 'failed') {
            throw Exception('Image generation failed.');
          }
        }

        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 5));
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error while polling for image: $e';
        isLoading = false;
        updatePromptHistory(prompt, 'Failed', null);
      });
    }
  }

  void updatePromptHistory(String prompt, String status, String? imageUrl) {
    setState(() {
      final index = promptHistory.indexWhere((entry) => entry['prompt'] == prompt);
      if (index != -1) {
        promptHistory[index] = {'prompt': prompt, 'status': status, 'imageUrl': imageUrl};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                ),
              if (errorMessage != null)
                Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
              if (generatedImageUrl != null)
                FutureBuilder(
                  future: fetchImageBytes(generatedImageUrl!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading image: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    } else {
                      return const Text('No image data available.');
                    }
                  },
                ),
              const SizedBox(height: 24),
              Text('Prompt History:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Column(
                children: promptHistory.map((entry) => ListTile(
                  title: Text(entry['prompt']!),
                  subtitle: Text(entry['status']!),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}