import 'package:uuid/uuid.dart';

class Chat {
  final String id; // Unique identifier
  final String title;
  final String prompt;
  final String? imageUrl;
  final String? lastMessage;
  final DateTime timestamp;

  Chat({
    this.lastMessage,
    required this.title,
    required this.prompt,
    this.imageUrl,
    DateTime? timestamp,
    String? id, // Allows passing a custom ID if needed
  })  : id = id ?? const Uuid().v4(), // Generate unique ID if none is provided
        timestamp = timestamp ?? DateTime.now();
}
