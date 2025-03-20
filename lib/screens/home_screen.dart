import 'package:flutter/material.dart';
import 'package:inkspire/screens/prompt_screen.dart';
import 'package:inkspire/models/chat.dart';
import 'package:inkspire/widgets/conversation_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Chat> _conversations = [
    Chat(
      title: 'Cyberpunk City at Night',
      prompt: 'A futuristic city glowing with neon lights under the night sky.',
      lastMessage: 'AI: Here is your generated image...',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Chat(
      title: 'A Samurai in a Neon Future',
      prompt: 'A cybernetic samurai standing in the rain-soaked streets of Tokyo.',
      lastMessage: 'You: Show me more variations!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Chat(
      title: 'Fantasy Castle in the Clouds',
      prompt: 'A majestic floating castle surrounded by a golden sunset.',
      lastMessage: 'AI: What do you think about this version?',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  // Function to add a new conversation
  void _addNewConversation(Chat newConvo) {
    setState(() {
      _conversations.insert(0, newConvo); // Add new chat at the top
    });
  }

  // Function to format timestamps
  String _formatTimestamp(DateTime timestamp) {
    final Duration difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InkSpire', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            final convo = _conversations[index];
            return ConversationItem(
              title: convo.title,
              lastMessage: convo.lastMessage ?? 'No messages yet...',
              timestamp: _formatTimestamp(convo.timestamp),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PromptScreen(onNewChat: _addNewConversation),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newConvo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PromptScreen(onNewChat: _addNewConversation),
            ),
          );

          if (newConvo is Chat) {
            _addNewConversation(newConvo); // Only add if newConvo is a valid Chat
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.edit, color: Colors.white),
      ),

    );
  }
}
