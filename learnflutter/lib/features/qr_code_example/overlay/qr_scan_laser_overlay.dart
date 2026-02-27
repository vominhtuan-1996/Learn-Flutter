import 'package:flutter/material.dart';

class QRScanLaserOverlay extends StatefulWidget {
  final Size size;

  const QRScanLaserOverlay({super.key, required this.size});

  @override
  State<QRScanLaserOverlay> createState() => QRScanLaserOverlayState();
}

class QRScanLaserOverlayState extends State<QRScanLaserOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: widget.size.height).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  void stop() {
    _controller.stop();
  }

  void resume() {
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _LaserPainter(animationValue: _animation.value),
          );
        },
      ),
    );
  }
}

class _LaserPainter extends CustomPainter {
  final double animationValue;

  _LaserPainter({required this.animationValue});

  @override
  @override
  @override
  void paint(Canvas canvas, Size size) {
    final laserY = animationValue;

    final laserHeight = 8.0;
    final shadowHeight = 16.0; // shadow dài hơn laser, mờ hơn
    final laserRect = Rect.fromLTWH(0, laserY, size.width, laserHeight);

    // 🔴 Vẽ shadow phía trên laser
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.withValues(alpha: 0.8), // đậm ở dưới
          Colors.blue.withValues(alpha: 0.7), // đậm ở dưới
          Colors.blue.withValues(alpha: 0.6), // đậm ở dưới
          Colors.blue.withValues(alpha: 0.5), // đậm ở dưới
          Colors.blue.withValues(alpha: 0.4), // đậm ở dưới
          Colors.blue.withValues(alpha: 0.3), // đậm ở dưới
          Colors.blue.withValues(alpha: 0.2), // đậm ở dưới
          Colors.blue.withValues(alpha: 0.1), // đậm ở dưới
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(0, laserY - shadowHeight, size.width, shadowHeight));

    canvas.drawRect(
      Rect.fromLTWH(0, laserY - shadowHeight, size.width, shadowHeight),
      shadowPaint,
    );

    // 🔴 Vẽ laser chính (đậm nét)
    final laserPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.blue, Colors.blue],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(laserRect);

    canvas.drawRect(laserRect, laserPaint);

    // (Tuỳ chọn) Vẽ border vùng quét
    final borderPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  @override
  bool shouldRepaint(_LaserPainter oldDelegate) => oldDelegate.animationValue != animationValue;
}
