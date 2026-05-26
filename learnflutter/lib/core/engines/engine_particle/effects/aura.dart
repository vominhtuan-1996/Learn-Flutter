import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/velocity.dart';

/// Aura — vòng tròn lan toả: 24 hạt phân bố đều quanh điểm chạm,
/// bay ra với speed bằng nhau → tạo "ring expand" giống ma thuật.
class AuraEmitter extends ParticleEmitter {
  AuraEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    const ringCount = 24;
    const baseSpeed = 220.0;
    for (int i = 0; i < ringCount; i++) {
      final p = pool.obtain();
      p.x = position.dx;
      p.y = position.dy;
      final angle = (i / ringCount) * 2 * pi;
      p.vx = cos(angle) * baseSpeed;
      p.vy = sin(angle) * baseSpeed;
      p.maxLife = 0.8 + random.nextDouble() * 0.2;
      p.life = p.maxLife;
      p.size = 3.5 + random.nextDouble() * 1.5;
      // Tím-xanh ma thuật
      p.color = Color.lerp(
        const Color(0xFFA855F7),
        const Color(0xFF22D3EE),
        i / ringCount,
      )!;
    }
  }
}

void updateAuraPhysics(p, double dt) {
  // Hạt giảm tốc đều — tạo cảm giác "sóng" tan
  p.vx -= p.vx * 1.8 * dt;
  p.vy -= p.vy * 1.8 * dt;
  // Nhỏ dần khi sắp tan
  if (p.life < p.maxLife * 0.4) {
    p.size -= 6 * dt;
    if (p.size < 0) p.size = 0.0;
  }
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
