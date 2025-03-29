import 'package:flutter/material.dart';

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
