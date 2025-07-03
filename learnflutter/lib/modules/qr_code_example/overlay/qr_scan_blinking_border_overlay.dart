import 'package:flutter/material.dart';

class BlinkingBorderOverlay extends StatefulWidget {
  final double width;
  final double height;

  const BlinkingBorderOverlay({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<BlinkingBorderOverlay> createState() => _BlinkingBorderOverlayState();
}

class _BlinkingBorderOverlayState extends State<BlinkingBorderOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(begin: 0.2, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: BlinkingBorderPainter(_opacityAnim.value),
        );
      },
    );
  }
}

class BlinkingBorderPainter extends CustomPainter {
  final double opacity;

  BlinkingBorderPainter(this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(opacity)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // canvas.drawRect(rect, borderPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(16)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BlinkingBorderPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
