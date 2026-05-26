import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/velocity.dart';

/// Bong bóng bay lên, dao động ngang nhẹ, lớn dần rồi vỡ.
class BubbleEmitter extends ParticleEmitter {
  BubbleEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    final p = pool.obtain();
    p.x = position.dx + random.nextDouble() * 16 - 8;
    p.y = position.dy;
    p.vx = random.nextDouble() * 30 - 15;
    p.vy = -random.nextDouble() * 60 - 40;
    p.maxLife = 2.0 + random.nextDouble() * 1.0;
    p.life = p.maxLife;
    p.size = 4.0 + random.nextDouble() * 6.0;
    // Xanh nhạt trong veo
    p.color = Color.lerp(
      const Color(0xFF81D4FA),
      const Color(0xFFB3E5FC),
      random.nextDouble(),
    )!;
  }
}

void updateBubblePhysics(p, double dt) {
  // Dao động ngang theo sin để giả vật lý nước
  p.vx += sin(p.life * 4) * 30 * dt;
  // Bay lên giảm dần (lực nổi)
  p.vy += 20 * dt;
  // Lớn dần theo tuổi đời
  p.size += 1.5 * dt;

  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
