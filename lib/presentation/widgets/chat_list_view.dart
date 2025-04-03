import 'package:flutter/material.dart';
import 'package:inkspire/data/models/chat.dart';
import 'package:provider/provider.dart';
import 'package:inkspire/providers/theme_provider.dart';

class ChatListView extends StatelessWidget {
  final List<Chat> chats;
  final Function(String) onRemoveChat;

  const ChatListView({super.key, required this.chats, required this.onRemoveChat});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return chats.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No images yet',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          Text(
            "Tap ' + ' below to start generating an image",
            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    )
        : ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return Dismissible(
          key: Key(chat.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Delete Chat?"),
                content: const Text("Are you sure you want to delete this chat?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            onRemoveChat(chat.id);
          },
          background: Container(
            color: isDarkMode ? Colors.redAccent.shade700 : Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: Card(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            child: ListTile(
              title: Text(
                chat.title,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              subtitle: Text(
                chat.prompt,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
              leading: chat.imageUrl != null
                  ? Image.network(chat.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                  : Icon(Icons.image, color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
        );
      },
    );
  }
}
