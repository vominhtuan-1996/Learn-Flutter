import 'package:flutter/material.dart';

import '../core/render_layer.dart';

/// Lưới ô vuông trôi theo phương dx/dy — minh hoạ background kiểu "techy".
class GridLayer extends RenderLayer {
  GridLayer({
    this.cellSize = 40,
    this.color = const Color(0x22FFFFFF),
    this.strokeWidth = 1,
    this.dx = 12,
    this.dy = 0,
  });

  double cellSize;
  Color color;
  double strokeWidth;

  /// Tốc độ trôi theo px/giây.
  double dx;
  double dy;

  double _ox = 0;
  double _oy = 0;

  @override
  void update(double dt) {
    _ox = (_ox + dx * dt) % cellSize;
    _oy = (_oy + dy * dt) % cellSize;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (double x = _ox - cellSize; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = _oy - cellSize; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
}
