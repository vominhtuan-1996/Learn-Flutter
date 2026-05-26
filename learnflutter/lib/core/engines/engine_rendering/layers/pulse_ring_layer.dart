import 'package:flutter/material.dart';

import '../core/render_layer.dart';

/// N vòng tròn lan ra từ tâm, fade dần theo thời gian — kiểu radar / sonar.
class PulseRingLayer extends RenderLayer {
  PulseRingLayer({
    this.color = const Color(0xFF22D3EE),
    this.ringCount = 3,
    this.maxRadius = 180,
    this.duration = 2.4,
    this.strokeWidth = 2,
    this.center,
  });

  Color color;

  /// Số ring đồng thời (stagger theo phase).
  int ringCount;

  /// Bán kính lớn nhất ring đạt được trước khi reset.
  double maxRadius;

  /// Thời gian (giây) ring đi từ 0 → maxRadius.
  double duration;

  double strokeWidth;

  /// Null = vẽ ở giữa canvas.
  Offset? center;

  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = center ?? size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (var i = 0; i < ringCount; i++) {
      final phase = ((_t / duration) + i / ringCount) % 1.0;
      final r = phase * maxRadius;
      final a = (1 - phase).clamp(0.0, 1.0);
      paint.color = color.withOpacity(a);
      canvas.drawCircle(c, r, paint);
    }
  }
}
