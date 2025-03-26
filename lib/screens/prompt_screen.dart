import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inkspire/models/chat.dart';
import 'package:inkspire/utils/ink_painter.dart';

class PromptScreen extends StatefulWidget {
  final Function(Chat) onNewChat;
  final Function(String)? onImageGenerated;

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
        final imageUrl = responseData["images"]?[0]["url"];

        if (imageUrl != null) {
          saveChat(prompt, imageUrl: imageUrl);
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
      widget.onImageGenerated!(imageUrl);
    }

    setState(() {
      isLoading = false;
      generatedImageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('InkSpire')),
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: InkPainter(0.8),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _promptController,
                  maxLines: 5,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter your prompt...',
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                    filled: true,
                    fillColor: isDarkMode ? Colors.black54 : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: generateImage,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: RadialGradient(
                        colors: [Colors.indigo.shade900, Colors.black],
                        center: const Alignment(-0.3, -0.3),
                        radius: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.shade800.withOpacity(0.7),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Generate Image',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading) const CircularProgressIndicator(),
                if (errorMessage != null) Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                if (generatedImageUrl != null) Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(generatedImageUrl!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}