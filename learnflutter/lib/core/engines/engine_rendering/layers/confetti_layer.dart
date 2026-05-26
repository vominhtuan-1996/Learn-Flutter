import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/render_layer.dart';

/// Confetti rơi xuống — mỗi mảnh có màu / kích thước / tốc độ / quay riêng.
class ConfettiLayer extends RenderLayer {
  ConfettiLayer({
    this.count = 60,
    this.colors = const [
      Color(0xFFEF4444),
      Color(0xFFF59E0B),
      Color(0xFF10B981),
      Color(0xFF3B82F6),
      Color(0xFFEC4899),
      Color(0xFFFFFFFF),
    ],
    this.gravity = 80,
    this.windAmplitude = 30,
    int seed = 7,
  }) {
    final rng = math.Random(seed);
    for (var i = 0; i < count; i++) {
      _pieces.add(_Confetti(
        x: rng.nextDouble(),
        y: rng.nextDouble() * -1,
        vy: 40 + rng.nextDouble() * 80,
        size: 4 + rng.nextDouble() * 6,
        rot: rng.nextDouble() * math.pi * 2,
        rotSpeed: (rng.nextDouble() - 0.5) * 6,
        color: colors[rng.nextInt(colors.length)],
        phase: rng.nextDouble() * math.pi * 2,
      ));
    }
  }

  int count;
  List<Color> colors;

  /// Gia tốc rơi (px/s²).
  double gravity;

  /// Biên độ "gió" lắc trái phải (px).
  double windAmplitude;

  final List<_Confetti> _pieces = [];
  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
    for (final p in _pieces) {
      p.vy += gravity * dt * 0.02;
      p.y += p.vy * dt * 0.01;
      p.rot += p.rotSpeed * dt;
      if (p.y > 1.1) {
        p.y = -0.1;
        p.vy = 40;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in _pieces) {
      final wind = math.sin(_t * 1.5 + p.phase) * windAmplitude;
      final px = p.x * size.width + wind;
      final py = p.y * size.height;
      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rot);
      paint.color = p.color;
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 1.6), paint);
      canvas.restore();
    }
  }
}

class _Confetti {
  _Confetti({
    required this.x,
    required this.y,
    required this.vy,
    required this.size,
    required this.rot,
    required this.rotSpeed,
    required this.color,
    required this.phase,
  });
  double x, y, vy, size, rot, rotSpeed, phase;
  Color color;
}
