import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/velocity.dart';

const _heartPalette = <Color>[
  Color(0xFFEF4444),
  Color(0xFFEC4899),
  Color(0xFFF472B6),
  Color(0xFFFB7185),
];

/// Tim bay lên nhẹ nhàng, dao động ngang, nhỏ dần ở cuối.
/// (Renderer chỉ vẽ hình tròn — coi như "trái tim mờ" 💗)
class HeartEmitter extends ParticleEmitter {
  HeartEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    final p = pool.obtain();
    p.x = position.dx + random.nextDouble() * 16 - 8;
    p.y = position.dy;
    p.vx = random.nextDouble() * 40 - 20;
    p.vy = -random.nextDouble() * 80 - 40;
    p.maxLife = 1.5 + random.nextDouble() * 0.8;
    p.life = p.maxLife;
    p.size = 6.0 + random.nextDouble() * 4.0;
    p.color = _heartPalette[random.nextInt(_heartPalette.length)];
  }
}

void updateHeartPhysics(p, double dt) {
  // Dao động ngang nhẹ
  p.vx += sin(p.life * 6) * 40 * dt;
  // Lực nâng giảm dần
  p.vy += 30 * dt;
  // Nhỏ dần ở nửa cuối life
  if (p.life < p.maxLife / 2) {
    p.size -= 5 * dt;
    if (p.size < 0) p.size = 0.0;
  }
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
