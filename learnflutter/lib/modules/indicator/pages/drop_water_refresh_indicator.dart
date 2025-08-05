import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

class DropWaterRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color color;

  const DropWaterRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      builder: (context, child, indicator) {
        return Stack(
          children: [
            AnimatedBuilder(
              animation: indicator,
              builder: (context, _) {
                final progress = indicator.value.clamp(0.0, 1.0);
                final isRefreshing = indicator.state == IndicatorState.dragging;
                final bounceOffset = indicator.state == IndicatorState.idle
                    ? 0.0
                    : isRefreshing
                        ? 10.0
                        : -40.0 + 60 * progress;

                return Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, bounceOffset),
                      child: Transform.scale(
                        scale: isRefreshing ? 1.1 : progress,
                        child: _DropWaterShape(color: color),
                      ),
                    ),
                  ),
                );
              },
            ),
            child,
          ],
        );
      },
      child: child,
    );
  }
}

class _DropWaterShape extends StatelessWidget {
  final Color color;

  const _DropWaterShape({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DropWaterPainter(color),
      size: const Size(30, 40),
    );
  }
}

class _DropWaterPainter extends CustomPainter {
  final Color color;

  _DropWaterPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // Tạo hình giọt nước bằng path
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(0, size.height * 0.4, size.width / 2, size.height);
    path.quadraticBezierTo(size.width, size.height * 0.4, size.width / 2, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DropWaterPainter oldDelegate) => false;
}
