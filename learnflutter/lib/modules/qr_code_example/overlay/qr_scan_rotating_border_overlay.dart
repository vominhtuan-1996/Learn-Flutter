import 'dart:math';

import 'package:flutter/material.dart';

class RotatingBorderOverlay extends StatefulWidget {
  final double width;
  final double height;

  const RotatingBorderOverlay({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<RotatingBorderOverlay> createState() => _RotatingBorderOverlayState();
}

class _RotatingBorderOverlayState extends State<RotatingBorderOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(); // xoay liên tục
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
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: RotatingBorderPainter(2 * pi * _controller.value),
        );
      },
    );
  }
}

class RotatingBorderPainter extends CustomPainter {
  final double angle; // Góc xoay hiện tại (radian)

  RotatingBorderPainter(this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = 16.0;

    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    // Cắt để không vẽ ngoài khung
    canvas.save();
    canvas.clipPath(path);

    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        tileMode: TileMode.clamp,
        colors: [Colors.blue, Colors.blue.withValues(alpha: 0.1)],
        stops: [0.0, 0.6],
        transform: GradientRotation(angle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RotatingBorderPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
