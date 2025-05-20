import 'package:flutter/material.dart';
import 'package:inkspire/data/models/chat.dart';

class ChatGridView extends StatelessWidget {
  final List<Chat> chats;
  final Function(String) onRemoveChat;

  const ChatGridView({
    Key? key,
    required this.chats,
    required this.onRemoveChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return const Center(
        child: Text(
          'No images yet. Tap + to create your first masterpiece!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return GridTile(
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                Positioned.fill(
                  child: Hero(
                    tag: 'image_${chat.id}',
                    child: Image.network(
                      chat.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Gradient overlay for text readability
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      chat.prompt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Actions on tap
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Navigate to detail view when tapped
                        _showImageDetail(context, chat);
                      },
                      onLongPress: () {
                        // Show delete confirmation
                        _showDeleteConfirmation(context, chat.id);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImageDetail(BuildContext context, Chat chat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              chat.prompt,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing coming soon!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, chat.id);
                },
              ),
            ],
          ),
          body: Center(
            child: Hero(
              tag: 'image_${chat.id}',
              child: Image.network(
                chat.imageUrl!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              onRemoveChat(id);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}