import 'package:flutter/material.dart';
import 'package:inkspire/data/models/chat.dart';

class ChatListView extends StatelessWidget {
  final List<Chat> chats;
  final Function(String) onRemoveChat; // Change: Use String instead of int

  const ChatListView({super.key, required this.chats, required this.onRemoveChat});

  @override
  Widget build(BuildContext context) {
    return chats.isEmpty
        ? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No images yet'),
          Text("Tap ' + ' below to start generating an image"),
        ],
      ),
    )
        : ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Dismissible(
          key: Key(chat.id), // Now using unique ID instead of title
          onDismissed: (direction) => onRemoveChat(chat.id), // Use ID instead of index
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            title: Text(chat.title),
            subtitle: Text(chat.prompt, maxLines: 1, overflow: TextOverflow.ellipsis),
            leading: chat.imageUrl != null
                ? Image.network(chat.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
          ),
        );
      },
    );
  }
}
