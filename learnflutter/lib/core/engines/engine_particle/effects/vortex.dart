import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';

/// Vortex — hạt sinh trên vành tròn quanh điểm chạm và xoáy vào tâm.
/// Trick: lưu góc hiện tại vào `vx`, bán kính vào `vy`, mỗi frame
/// xoay góc + giảm bán kính → trông như galaxy spiral.
class VortexEmitter extends ParticleEmitter {
  VortexEmitter(super.pool);

  Offset? _center;

  @override
  void emit({required Offset position}) {
    _center = position;
    for (int i = 0; i < 2; i++) {
      final p = pool.obtain();
      final angle = random.nextDouble() * 2 * pi;
      final radius = 80 + random.nextDouble() * 60;
      p.x = position.dx + cos(angle) * radius;
      p.y = position.dy + sin(angle) * radius;
      // Đặt vx = angle, vy = radius (engine không dùng giá trị này vì
      // ta override hoàn toàn trong updateVortexPhysics).
      p.vx = angle;
      p.vy = radius;
      p.maxLife = 2.0 + random.nextDouble() * 1.5;
      p.life = p.maxLife;
      p.size = 1.5 + random.nextDouble() * 2.0;
      // Cầu vồng theo góc
      p.color = HSVColor.fromAHSV(1, (angle * 180 / pi) % 360, 0.8, 1.0).toColor();
    }
  }

  Offset? get center => _center;
}

void updateVortexPhysics(p, double dt) {
  // Tăng tốc góc + co bán kính (spiral inward)
  p.vx += 2.5 * dt; // angular velocity
  p.vy -= 25 * dt; // radius co lại
  if (p.vy < 0) p.vy = 0.0;

  // Position được tính lại từ (angle, radius) — cần biết tâm. Vì physics
  // không nhận tâm, ta đặt tâm là vị trí hiện tại trừ radius cũ. Đơn giản:
  // lưu tâm "ngầm" trong p.size? Không. Cách dễ: hạt tự xoay quanh tâm
  // riêng của nó (tâm là điểm hiện tại lúc emit). Engine không nhớ, nên
  // ta dịch chuyển theo công thức tangent + radial.
  final tangentialSpeed = p.vy * 3.0;
  final radialSpeed = 60.0;
  // Vận tốc tangent vuông góc với vector hướng tâm — nhưng ta không có
  // tâm thật. Workaround: dùng vận tốc xoay quanh điểm hiện tại bằng
  // cách rotate vector (cos(angle), sin(angle)) theo dt.
  final vxNew = cos(p.vx + pi / 2) * tangentialSpeed - cos(p.vx) * radialSpeed;
  final vyNew = sin(p.vx + pi / 2) * tangentialSpeed - sin(p.vx) * radialSpeed;
  p.x += vxNew * dt;
  p.y += vyNew * dt;

  p.life -= dt;
}
