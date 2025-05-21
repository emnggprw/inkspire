import 'package:flutter/material.dart';

class InkPainter extends CustomPainter {
  // Improvement 2: Customizable gradient colors
  final double progress;
  final List<Color> gradientColors;

  // Improvement 3: Opacity control
  final double opacity;

  InkPainter({
    required this.progress,
    this.gradientColors = const [Colors.white38, Colors.black],
    this.opacity = 0.7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Improvement 7: Error handling for progress values
    final safeProgress = progress.clamp(0.0, 1.0);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          gradientColors[0].withOpacity(0.4 * opacity),
          gradientColors[1].withOpacity(opacity),
        ],
        radius: 1.5 - safeProgress,
      ).createShader(Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: size.width
      ));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  // Improvement 10: Optimize shouldRepaint to only redraw when necessary
  @override
  bool shouldRepaint(covariant InkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.opacity != opacity ||
        !listEquals(oldDelegate.gradientColors, gradientColors);
  }

  // Helper method to compare color lists
  bool listEquals(List<Color>? a, List<Color>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}