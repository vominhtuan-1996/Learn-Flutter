import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:learnflutter/modules/indicator/pages/drop_water_refresh_indicator.dart';

class DropWaterIndicatorScreen extends StatelessWidget {
  const DropWaterIndicatorScreen({super.key});

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: DropWaterRefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 30,
          itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
        ),
      ),
    );
  }
}

class DropWaterShape extends StatelessWidget {
  final double progress;
  final Color color;

  const DropWaterShape({
    super.key,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final easedProgress = Curves.elasticOut.transform(progress.clamp(0.0, 1.0));
    // Curves.elasticOut
    return CustomPaint(
      painter: _DropWaterPainter(easedProgress, color),
      size: const Size(40, 40),
    );
  }
}

class _DropWaterPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DropWaterPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final width = size.width;
    final height = size.height * (0.6 + 0.4 * progress); // tăng từ 60% đến 100%
    final radius = width / 2;

    final path = Path();

    // Đỉnh (nhọn)
    path.moveTo(width / 2, 0);

    // Vòng cung trái
    path.quadraticBezierTo(
      0, height * 0.4, // control point
      width / 2, height, // end point
    );

    // Vòng cung phải (đối xứng)
    path.quadraticBezierTo(
      width,
      height * 0.4,
      width / 2,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DropWaterPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
