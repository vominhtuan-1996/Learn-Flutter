import 'package:flutter/material.dart';

/// CustomPainter vẽ hiệu ứng Ripple (vòng tròn lan toả).
/// Dùng kết hợp với [AnimatedRepaint] và [CoreAnimController].
class RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double maxRadius;

  RipplePainter({
    required this.progress,
    this.color = Colors.white,
    this.maxRadius = 80.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      size.center(Offset.zero),
      progress * maxRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
