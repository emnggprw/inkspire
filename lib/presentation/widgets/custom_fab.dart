import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
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
    );
  }
}