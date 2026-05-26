import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/velocity.dart';

/// Comet — sao chổi với vệt đuôi dài (sử dụng `maxTrail` của engine).
/// Tự bay với hướng ngẫu nhiên, nhỏ dần, vệt đuôi mờ dần theo opacity.
class CometEmitter extends ParticleEmitter {
  CometEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    final p = pool.obtain();
    p.x = position.dx;
    p.y = position.dy;
    final angle = random.nextDouble() * 2 * pi;
    final speed = 220 + random.nextDouble() * 180;
    p.vx = cos(angle) * speed;
    p.vy = sin(angle) * speed;
    p.maxLife = 1.5 + random.nextDouble() * 0.8;
    p.life = p.maxLife;
    p.size = 3.0 + random.nextDouble() * 2.0;
    p.maxTrail = 14;
    // Trắng-vàng-cam tuỳ random
    final palette = [
      const Color(0xFFFFFFFF),
      const Color(0xFFFFD166),
      const Color(0xFFFF9F1C),
      const Color(0xFFCDB4DB),
    ];
    p.color = palette[random.nextInt(palette.length)];
  }
}

void updateCometPhysics(p, double dt) {
  // Bay chậm dần (drag nhẹ)
  p.vx -= p.vx * 0.6 * dt;
  p.vy -= p.vy * 0.6 * dt;
  // Nhỏ dần đều
  p.size -= 1.2 * dt;
  if (p.size < 0) p.size = 0.0;
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
