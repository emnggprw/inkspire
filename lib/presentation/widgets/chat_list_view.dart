import 'package:flutter/material.dart';
import 'package:inkspire/data/models/chat.dart';
import 'package:provider/provider.dart';
import 'package:inkspire/providers/theme_provider.dart';

class ChatListView extends StatefulWidget {
  final List<Chat> chats;
  final Function(String) onRemoveChat;

  const ChatListView({
    super.key,
    required this.chats,
    required this.onRemoveChat,
  });

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  List<Chat> _filteredChats = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredChats = List.from(widget.chats);
    _searchController.addListener(_filterChats);
  }

  @override
  void didUpdateWidget(covariant ChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _filterChats();
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredChats = widget.chats.where((chat) {
        return chat.title.toLowerCase().contains(query) ||
            chat.prompt.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _removeChat(String id) {
    widget.onRemoveChat(id);
    _filterChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildChatTile(Chat chat) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

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
      onDismissed: (_) => _removeChat(chat.id),
      background: Container(
        color: isDarkMode ? Colors.redAccent.shade700 : Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          title: Text(
            chat.title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            chat.prompt,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          leading: chat.imageUrl != null
              ? Image.network(
            chat.imageUrl!,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          )
              : Icon(Icons.image, color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search prompts...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        Expanded(
          child: _filteredChats.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No prompts found',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  "Try a different keyword",
                ),
                Text(
                  "OR",
                ),
                Text(
                  "Create a new prompt by pressing ' + ' button",
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _filteredChats.length,
            itemBuilder: (context, index) {
              return _buildChatTile(_filteredChats[index]);
            },
          ),
        ),
      ],
    );
  }
}
