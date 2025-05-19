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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('InkSpire'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 4,
        shadowColor: isDarkMode ? Colors.white10 : Colors.black12,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
              // color: isDarkMode ? Colors.yellow : Colors.indigo,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          RefreshIndicator(
            onRefresh: () async {
              // Show a loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Refreshing your inspiration...'),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[700],
                ),
              );

              // Call the refresh method in the provider
              await chatProvider.refreshChats();

              // Show completion message if there were no errors
              if (context.mounted && chatProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Your gallery is up to date!'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (context.mounted && chatProvider.error != null) {
                // Show error message if there was a problem
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${chatProvider.error}'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            color: Theme.of(context).primaryColor,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
            child: ChatListView(
              chats: chatProvider.chats,
              onRemoveChat: (id) {
                chatProvider.removeChat(id);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CustomFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PromptScreen(
                onNewChat: (chat) {
                  chatProvider.addChat(chat);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}