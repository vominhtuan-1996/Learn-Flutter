import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/gravity.dart';
import '../physics/velocity.dart';

const _confettiPalette = <Color>[
  Color(0xFFEF4444),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF3B82F6),
  Color(0xFFA855F7),
  Color(0xFFEC4899),
  Color(0xFFFFFFFF),
];

/// Confetti — giấy nhiều màu bắn lên rồi rơi xuống có trọng lực.
class ConfettiEmitter extends ParticleEmitter {
  ConfettiEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    for (int i = 0; i < 4; i++) {
      final p = pool.obtain();
      p.x = position.dx;
      p.y = position.dy;
      p.vx = random.nextDouble() * 280 - 140;
      p.vy = -random.nextDouble() * 320 - 80;
      p.maxLife = 1.4 + random.nextDouble() * 0.8;
      p.life = p.maxLife;
      p.size = 2.5 + random.nextDouble() * 2.5;
      p.color = _confettiPalette[random.nextInt(_confettiPalette.length)];
    }
  }
}

void updateConfettiPhysics(p, double dt) {
  GravityPhysics.update(p, dt, gravity: 420);
  // Air drag nhẹ để rơi từ tốn
  p.vx -= p.vx * 0.6 * dt;
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
