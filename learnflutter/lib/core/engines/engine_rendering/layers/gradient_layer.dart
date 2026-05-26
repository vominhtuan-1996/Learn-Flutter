import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/render_layer.dart';

/// Radial gradient có tâm di chuyển — thay thế / chồng lên BackgroundLayer
/// để có nền "sống động" như aurora.
class GradientLayer extends RenderLayer {
  GradientLayer({
    this.colors = const [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF000000)],
    this.stops,
    this.radiusFactor = 1.2,
    this.speed = 0.4,
    this.orbitRadius = 0.25,
  });

  List<Color> colors;
  List<double>? stops;

  /// Bán kính radial = min(w,h) * radiusFactor.
  double radiusFactor;

  /// Tốc độ quay (radian/giây).
  double speed;

  /// Bán kính quỹ đạo của tâm (tỉ lệ so với canvas).
  double orbitRadius;

  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final orbit = math.min(size.width, size.height) * orbitRadius;
    final center = Offset(
      c.dx + math.cos(_t * speed) * orbit,
      c.dy + math.sin(_t * speed) * orbit,
    );
    final radius = math.min(size.width, size.height) * radiusFactor;
    final paint = Paint()
      ..shader = RadialGradient(colors: colors, stops: stops).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawRect(Offset.zero & size, paint);
  }
}
