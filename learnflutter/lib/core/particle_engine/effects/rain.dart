import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/velocity.dart';

/// Mưa rơi thẳng nhanh, hạt nhỏ màu xanh dương.
class RainEmitter extends ParticleEmitter {
  RainEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    for (int i = 0; i < 2; i++) {
      final p = pool.obtain();
      p.x = position.dx + random.nextDouble() * 40 - 20;
      p.y = position.dy;
      p.vx = random.nextDouble() * 10 - 5;
      p.vy = 300 + random.nextDouble() * 200;
      p.maxLife = 1.5 + random.nextDouble() * 0.8;
      p.life = p.maxLife;
      p.size = 1.0 + random.nextDouble() * 1.5;
      p.color = const Color(0xFF60A5FA);
    }
  }
}

void updateRainPhysics(p, double dt) {
  // Tăng tốc nhẹ — mô phỏng rơi tự do nhưng đã gần terminal velocity
  p.vy += 80 * dt;
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
