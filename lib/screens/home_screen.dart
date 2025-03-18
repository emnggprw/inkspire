import 'package:flutter/material.dart';
import 'package:inkspire/screens/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder conversations
    final List<Map<String, String>> conversations = [
      {'title': 'Conversation 1', 'subtitle': 'Last message preview...'},
      {'title': 'Conversation 2', 'subtitle': 'Another preview...'},
      {'title': 'Conversation 3', 'subtitle': 'Yet another one...'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return ListTile(
            title: Text(conversation['title']!),
            subtitle: Text(conversation['subtitle']!),
            leading: const Icon(Icons.chat_bubble_outline),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
