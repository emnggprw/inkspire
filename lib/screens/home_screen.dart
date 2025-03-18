import 'package:flutter/material.dart';
import 'package:inkspire/screens/prompt_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> conversations = [
      {
        'title': 'Cyberpunk City at Night',
        'lastMessage': 'AI: Here is your generated image...',
        'timestamp': '2h ago',
      },
      {
        'title': 'A Samurai in a Neon Future',
        'lastMessage': 'You: Show me more variations!',
        'timestamp': '1d ago',
      },
      {
        'title': 'Fantasy Castle in the Clouds',
        'lastMessage': 'AI: What do you think about this version?',
        'timestamp': '3d ago',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final convo = conversations[index];
            return ConversationItem(
              title: convo['title']!,
              lastMessage: convo['lastMessage']!,
              timestamp: convo['timestamp']!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PromptScreen()),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PromptScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class ConversationItem extends StatelessWidget {
  final String title;
  final String lastMessage;
  final String timestamp;
  final VoidCallback onTap;

  const ConversationItem({
    super.key,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(timestamp, style: const TextStyle(color: Colors.grey)),
        onTap: onTap,
      ),
    );
  }
}
