import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/render_layer.dart';

/// Sét đánh ngẫu nhiên — vẽ jagged line từ trên xuống, flash trắng nhanh.
class LightningLayer extends RenderLayer {
  LightningLayer({
    this.color = const Color(0xFFE0F2FE),
    this.flashColor = const Color(0x33FFFFFF),
    this.intervalMin = 1.2,
    this.intervalMax = 3.5,
    this.flashDuration = 0.18,
    this.segments = 14,
    this.jitter = 28,
    int seed = 11,
  }) : _rng = math.Random(seed);

  Color color;
  Color flashColor;
  double intervalMin;
  double intervalMax;
  double flashDuration;
  int segments;

  /// Độ lệch trái/phải mỗi segment (px).
  double jitter;

  final math.Random _rng;
  double _t = 0;
  double _next = 1.5;
  double _flashLeft = 0;
  List<Offset> _path = const [];

  @override
  void update(double dt) {
    _t += dt;
    if (_flashLeft > 0) _flashLeft -= dt;
    if (_t >= _next) {
      _t = 0;
      _next = intervalMin + _rng.nextDouble() * (intervalMax - intervalMin);
      _flashLeft = flashDuration;
      _path = _generate();
    }
  }

  List<Offset> _generate() {
    final pts = <Offset>[];
    final startX = 0.2 + _rng.nextDouble() * 0.6;
    pts.add(Offset(startX, 0));
    for (var i = 1; i <= segments; i++) {
      final progress = i / segments;
      final dx = (_rng.nextDouble() - 0.5) * 2;
      pts.add(Offset((startX + dx * 0.05 * i).clamp(0.0, 1.0), progress));
    }
    return pts;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_flashLeft <= 0) return;

    // Flash overlay
    final alpha = (_flashLeft / flashDuration).clamp(0.0, 1.0);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = flashColor.withOpacity(flashColor.opacity * alpha),
    );

    if (_path.isEmpty) return;
    final path = Path();
    for (var i = 0; i < _path.length; i++) {
      final p = _path[i];
      final x = p.dx * size.width + (i == 0 ? 0 : (_rng.nextDouble() - 0.5) * jitter * 0.0);
      final y = p.dy * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final paint = Paint()
      ..color = color.withOpacity(alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1.5);
    canvas.drawPath(path, paint);
  }
}
