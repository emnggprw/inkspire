import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inkspire/models/chat.dart';

class PromptScreen extends StatefulWidget {
  final Function(Chat) onNewChat;
  final Function(String)? onImageGenerated; // Optional callback for images

  const PromptScreen({super.key, required this.onNewChat, this.onImageGenerated});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
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
          saveChat(prompt, imageUrl: imageUrl);
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
      });
      saveChat(prompt);
    }
  }

  Future<void> pollForImage(int creationId, String prompt) async {
    final String pollUrl = 'https://api.starryai.com/creations/$creationId';

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

          if (status == 'completed' && imageUrl != null && imageUrl.isNotEmpty) {
            saveChat(prompt, imageUrl: imageUrl);
            return;
          } else if (status == 'failed') {
            throw Exception('Image generation failed.');
          }
        }

        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 5));
      }

      throw Exception('Image generation timed out.');
    } catch (e) {
      setState(() {
        errorMessage = 'Error while polling for image: $e';
        isLoading = false;
      });
      saveChat(prompt);
    }
  }

  String generateTitleFromPrompt(String prompt) {
    List<String> words = prompt.split(' ');
    if (words.isEmpty) return "Untitled Chat";

    List<String> keywords = words.where((word) => word.length > 3).toList();
    if (keywords.length >= 3) {
      return "${keywords[0]} ${keywords[1]} ${keywords[2]}";
    } else if (keywords.isNotEmpty) {
      return keywords.join(' ');
    } else {
      return prompt.length > 15 ? "${prompt.substring(0, 15)}..." : prompt;
    }
  }

  void saveChat(String prompt, {String? imageUrl}) {
    String title = generateTitleFromPrompt(prompt);
    Chat newChat = Chat(title: title, prompt: prompt, imageUrl: imageUrl);
    widget.onNewChat(newChat);

    if (imageUrl != null && widget.onImageGenerated != null) {
      widget.onImageGenerated!(imageUrl); // Notify about the generated image
    }

    setState(() {
      isLoading = false;
      generatedImageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InkSpire')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              maxLines: 5,
              decoration: const InputDecoration(hintText: 'Enter your prompt...'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: generateImage,
              child: const Text('Generate Image'),
            ),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage != null) Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            if (generatedImageUrl != null) Image.network(generatedImageUrl!),
          ],
        ),
      ),
    );
  }
}
