import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/render_layer.dart';

/// Sóng sin chạy ngang — phù hợp làm background sống động cho hero / loading.
class WaveLayer extends RenderLayer {
  WaveLayer({
    this.color = const Color(0x553B82F6),
    this.amplitude = 24,
    this.wavelength = 220,
    this.speed = 1.2,
    this.yFactor = 0.7,
    this.strokeWidth = 0,
    this.fill = true,
  });

  Color color;

  /// Biên độ sóng (px).
  double amplitude;

  /// Bước sóng (px).
  double wavelength;

  /// Tốc độ trôi (radian/giây).
  double speed;

  /// Vị trí trục y của baseline (0..1 tính theo chiều cao canvas).
  double yFactor;

  /// >0 → vẽ stroke thay vì fill.
  double strokeWidth;

  /// true: fill xuống dưới baseline; false: chỉ line.
  bool fill;

  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final baseY = size.height * yFactor;
    final k = 2 * math.pi / wavelength;
    path.moveTo(0, baseY);
    for (double x = 0; x <= size.width; x += 4) {
      final y = baseY + math.sin(x * k + _t * speed) * amplitude;
      path.lineTo(x, y);
    }
    if (fill) {
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }
    final paint = Paint()..color = color;
    if (strokeWidth > 0 && !fill) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
    }
    canvas.drawPath(path, paint);
  }
}
