import 'package:flutter/material.dart';
import '../core/render_layer.dart';

/// Lớp nền cơ bản hỗ trợ vẽ solid color.
class BackgroundLayer extends RenderLayer {
  final Color color;

  BackgroundLayer({this.color = Colors.black});

  @override
  void update(double dt) {
    // Không có animation cho solid background.
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRect(Offset.zero & size, paint);
  }
}
