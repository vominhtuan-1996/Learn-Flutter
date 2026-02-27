import 'dart:ui';

import 'package:flutter/material.dart';

class ArrowDownPainter extends CustomPainter {
  final Color color;
  final double progress;
  ArrowDownPainter(this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lerpDouble(2.0, 3.5, progress)!
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final path = Path()
      ..moveTo(centerX, size.height * 0.2)
      ..lineTo(centerX, size.height * 0.8) // vertical
      ..moveTo(centerX - 6, size.height * 0.6)
      ..lineTo(centerX, size.height * 0.8)
      ..lineTo(centerX + 6, size.height * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ArrowDownPainter oldDelegate) => false;
}
