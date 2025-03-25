import 'package:flutter/material.dart';
import 'package:inkspire/models/chat.dart';
import 'package:inkspire/screens/prompt_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Chat> chats = [];
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void addNewChat(Chat chat) {
    setState(() {
      chats.insert(0, chat);
    });
  }

  Future<void> _refreshChats() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('InkSpire')),
      body: Stack(
        children: [
          AnimatedBackground(), // Dynamic ink-like background
          RefreshIndicator(
            onRefresh: _refreshChats,
            child: chats.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('No images yet'),
                  Text("Tap ' + ' below to start generating an image"),
                ],
              ),
            )
                : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Dismissible(
                  key: Key(chat.title),
                  onDismissed: (direction) {
                    setState(() {
                      chats.removeAt(index);
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(chat.title),
                    subtitle: Text(chat.prompt, maxLines: 1, overflow: TextOverflow.ellipsis),
                    leading: chat.imageUrl != null
                        ? Image.network(chat.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + (_fabController.value * 0.1),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PromptScreen(onNewChat: addNewChat),
                  ),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.indigo.shade900, Colors.black],
                    center: const Alignment(-0.3, -0.3),
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
                child: const Icon(Icons.add, size: 32, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: InkPainter(_controller.value),
        );
      },
    );
  }
}

class InkPainter extends CustomPainter {
  final double progress;
  InkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white38.withOpacity(0.4), Colors.black.withOpacity(0.7)],
        radius: 1.5 - progress,
      ).createShader(Rect.fromCircle(center: size.center(Offset.zero), radius: size.width));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
