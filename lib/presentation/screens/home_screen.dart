import 'package:flutter/material.dart';
import 'package:inkspire/providers/theme_provider.dart';
import 'package:inkspire/providers/chat_provider.dart';
import 'package:inkspire/data/services/animated_background.dart';
import 'package:inkspire/presentation/screens/prompt_screen.dart';
import 'package:inkspire/presentation/widgets/chat_list_view.dart';
import 'package:inkspire/presentation/widgets/custom_fab.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access ThemeProvider and ChatProvider through the context
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: themeProvider.toggleTheme, // Toggle theme
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackground(), // Custom animated background widget
          RefreshIndicator(
            onRefresh: () async {
              // Add refresh logic here if needed
            },
            child: ChatListView(
              chats: chatProvider.chats, // Display the list of chats from ChatProvider
              onRemoveChat: (id) {
                chatProvider.removeChat(id); // Removes chat by ID
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFAB(
        onPressed: () {
          // Navigate to PromptScreen to create a new chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PromptScreen(
                onNewChat: (chat) {
                  chatProvider.addChat(chat); // Add new chat to provider
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
