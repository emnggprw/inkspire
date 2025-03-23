import 'package:flutter/material.dart';
import 'package:inkspire/models/chat.dart';
import 'package:inkspire/screens/prompt_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                const Center(child: Text('No images yet')),
                const Center(child: Text("Tap ' + ' below to start generating image")),
              ],
            ),
          )
          : ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            title: Text(chat.title),
            subtitle: Text(chat.prompt, maxLines: 1, overflow: TextOverflow.ellipsis),
            leading: chat.imageUrl != null
                ? Image.network(chat.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
          );
        },
      ),
      floatingActionButton: Container(
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
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PromptScreen(onNewChat: addNewChat),
              ),
            );
          },
          backgroundColor: Colors.transparent, // Uses gradient instead
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [Colors.white, Colors.grey.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Icon(
              Icons.add,
              size: 32,
              color: Colors.white, // Stands out against dark ink
            ),
          ),
        ),
      ),

    );
  }
}
