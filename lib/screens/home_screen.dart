import 'package:flutter/material.dart';
import 'package:inkspire/models/chat.dart';
import 'package:inkspire/screens/prompt_screen.dart';
import 'package:inkspire/utils/animated_background.dart';
import 'package:inkspire/widgets/chat_list_view.dart';
import 'package:inkspire/widgets/custom_fab.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Chat> chats = [];

  void addNewChat(Chat chat) {
    setState(() {
      chats.insert(0, chat);
    });
  }

  Future<void> _refreshChats() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackground(),
          RefreshIndicator(
            onRefresh: _refreshChats,
            child: ChatListView(chats: chats, onRemoveChat: _removeChat),
          ),
        ],
      ),
      floatingActionButton: CustomFAB(onPressed: _navigateToPromptScreen),
    );
  }

  void _removeChat(int index) {
    setState(() {
      chats.removeAt(index);
    });
  }

  void _navigateToPromptScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromptScreen(
          onNewChat: addNewChat,
          onToggleTheme: widget.onToggleTheme, // Ensure this is passed
        ),
      ),
    );

  }
}



