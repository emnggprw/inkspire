import 'package:flutter/material.dart';
import 'package:inkspire/providers/theme_provider.dart';
import 'package:inkspire/providers/chat_provider.dart';
import 'package:inkspire/data/models/chat.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:inkspire/presentation/widgets/ink_painter.dart';
import 'package:provider/provider.dart';

class PromptScreen extends StatefulWidget {
  final Function(Chat) onNewChat;

  const PromptScreen({
    super.key,
    required this.onNewChat,
  });

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
        } else {
          throw Exception('Image URL missing in response.');
        }
      } else if (response.statusCode == 400) {
        throw Exception('Bad request: Please check your prompt and try again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied: Invalid API key.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error: Please try again later.');
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
      saveChat(prompt);
    } finally {
      setState(() {
        isLoading = false;
      });
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

    setState(() {
      isLoading = false;
      generatedImageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
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
                    child: const Center(
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
