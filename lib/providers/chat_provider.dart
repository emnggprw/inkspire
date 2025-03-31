import 'package:flutter/material.dart';
import 'package:inkspire/data/models/chat.dart';

class ChatProvider extends ChangeNotifier {
  final List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  void addChat(Chat chat) {
    _chats.add(chat);
    notifyListeners();
  }

  void removeChat(int index) {
    _chats.removeAt(index);
    notifyListeners();
  }
}
