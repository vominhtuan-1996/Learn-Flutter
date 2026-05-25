import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/velocity.dart';

/// Khói xám bay lên, phình to và mờ dần.
class SmokeEmitter extends ParticleEmitter {
  SmokeEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    final p = pool.obtain();
    p.x = position.dx + random.nextDouble() * 20 - 10;
    p.y = position.dy;
    p.vx = random.nextDouble() * 20 - 10;
    p.vy = -random.nextDouble() * 30 - 20;
    p.maxLife = 2.5 + random.nextDouble() * 1.5;
    p.life = p.maxLife;
    p.size = 6.0 + random.nextDouble() * 4.0;
    final shade = 120 + random.nextInt(80);
    p.color = Color.fromARGB(220, shade, shade, shade);
  }
}

void updateSmokePhysics(p, double dt) {
  // Khói tản ra ngang chậm, bay lên chậm dần (drag)
  p.vx -= p.vx * 0.4 * dt;
  p.vy += 8 * dt;
  // Phình to theo thời gian
  p.size += 8 * dt;

  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
