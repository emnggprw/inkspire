import 'package:flutter/material.dart';

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