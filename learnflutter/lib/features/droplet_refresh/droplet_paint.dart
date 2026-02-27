import 'package:flutter/material.dart';

class DropPainter extends CustomPainter {
  final double progress;

  DropPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    const double maxRadius = 20;
    final double radius = maxRadius * progress.clamp(0.0, 1.0);

    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(size.width / 2 - radius, radius, size.width / 2, radius * 2)
      ..quadraticBezierTo(size.width / 2 + radius, radius, size.width / 2, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DropPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
