import 'package:flutter/material.dart';
import 'package:inkspire/models/chat.dart';
import 'package:inkspire/screens/prompt_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Chat> chats = [];

  // Function to handle new chat additions
  void addNewChat(Chat chat) {
    setState(() {
      chats.insert(0, chat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InkSpire')),
      body: chats.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('No creations yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            const Text("Tap '+' below to bring your ideas to life!", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.black.withOpacity(0.8), // Dark ink feel
              child: ListTile(
                title: Text(chat.title, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  chat.prompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                leading: chat.imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(chat.imageUrl!, width: 50, height: 50, fit: BoxFit.cover),
                )
                    : const Icon(Icons.image, color: Colors.white70),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ),
            ),
          );
        },
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PromptScreen(onNewChat: addNewChat),
            ),
          );
        },
        borderRadius: BorderRadius.circular(50),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.indigo.shade900, // Deep ink-like blue
                Colors.black,           // Rich dark ink
              ],
              center: Alignment(-0.3, -0.3),
              radius: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.shade800.withOpacity(0.7),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const RadialGradient(
                  colors: [Colors.white, Colors.grey],
                  center: Alignment.center,
                  radius: 1.0,
                ).createShader(bounds);
              },
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
