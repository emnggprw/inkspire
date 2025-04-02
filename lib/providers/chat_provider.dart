import 'package:flutter/material.dart';
import 'package:inkspire/data/models/chat.dart';

class ChatProvider extends ChangeNotifier {
  final List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  // Adds a new chat to the list, checks for duplicates based on 'id'
  void addChat(Chat chat) {
    if (!_chats.any((existingChat) => existingChat.id == chat.id)) {
      _chats.add(chat);
      notifyListeners();
    }
  }

  // Removes a chat by its ID
  void removeChat(String id) {
    _chats.removeWhere((chat) => chat.id == id);
    notifyListeners();
  }
}
