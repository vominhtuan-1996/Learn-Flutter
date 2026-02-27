import 'package:flutter/material.dart';

class ZigZagLaserOverlay extends StatefulWidget {
  final double width;
  final double height;

  const ZigZagLaserOverlay({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<ZigZagLaserOverlay> createState() => _ZigZagLaserOverlayState();
}

class _ZigZagLaserOverlayState extends State<ZigZagLaserOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _position = Tween<double>(begin: 0, end: widget.height).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _position,
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: ZigZagLaserPainter(yOffset: _position.value),
        );
      },
    );
  }
}

class ZigZagLaserPainter extends CustomPainter {
  final double yOffset;
  final Color color;
  final double amplitude;
  final double frequency;

  ZigZagLaserPainter({
    required this.yOffset,
    this.color = Colors.red,
    this.amplitude = 10,
    this.frequency = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    double x = 0;
    bool up = true;

    path.moveTo(x, yOffset);

    while (x < size.width) {
      x += frequency;
      double y = yOffset + (up ? -amplitude : amplitude);
      path.lineTo(x, y);
      up = !up;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); // Glow effect

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ZigZagLaserPainter oldDelegate) {
    return oldDelegate.yOffset != yOffset;
  }
}
