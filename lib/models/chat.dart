class Chat {
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
  }) : timestamp = timestamp ?? DateTime.now();
}
