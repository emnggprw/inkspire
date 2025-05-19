import 'package:flutter/material.dart';
import 'package:inkspire/data/models/chat.dart';

class ChatProvider extends ChangeNotifier {
  final List<Chat> _chats = [];
  bool _isLoading = false;
  String? _error;

  List<Chat> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  // Refresh chats - simulates fetching new data
  Future<void> refreshChats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Ideally would fetch data from an API or local database here
      // For now just simulate a network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      // For an API call:
      // final freshChats = await apiService.getChats();
      // _chats.clear();
      // _chats.addAll(freshChats);

      // For now keep the existing chats
      // Could add logic here to refresh them from data source
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}