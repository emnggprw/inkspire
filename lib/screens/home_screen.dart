import 'package:flutter/material.dart';
import 'package:inkspire/models/chat.dart';
import 'package:inkspire/screens/prompt_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Chat> chats = [];

  // Function to handle new chat additions
  void addNewChat(Chat chat) {
    setState(() {
      chats.insert(0, chat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InkSpire')),
      body: chats.isEmpty
          ? const Center(child: Text('No conversations yet.'))
          : ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            title: Text(chat.title),
            subtitle: Text(chat.prompt, maxLines: 1, overflow: TextOverflow.ellipsis),
            leading: chat.imageUrl != null
                ? Image.network(chat.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PromptScreen(onNewChat: addNewChat),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
