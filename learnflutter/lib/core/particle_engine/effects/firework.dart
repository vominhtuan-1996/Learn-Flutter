import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/gravity.dart';
import '../physics/velocity.dart';

const _fireworkPalette = <Color>[
  Color(0xFFFFD700),
  Color(0xFFFF6F61),
  Color(0xFFEC4899),
  Color(0xFF60A5FA),
  Color(0xFF34D399),
  Color(0xFFA855F7),
  Color(0xFFFFFFFF),
];

/// Firework — vụ nổ pháo bông: 60 hạt toả 360° kèm gravity nhẹ và drag,
/// kèm rơi xuống như tàn pháo.
class FireworkEmitter extends ParticleEmitter {
  FireworkEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    // Mỗi lần emit → 1 vụ nổ trọn vẹn. Hold không spam liên tục vì cost cao.
    final hueBase = random.nextDouble() * 360;
    for (int i = 0; i < 60; i++) {
      final p = pool.obtain();
      p.x = position.dx;
      p.y = position.dy;

      final angle = (i / 60) * 2 * pi + random.nextDouble() * 0.1;
      final speed = 180 + random.nextDouble() * 180;
      p.vx = cos(angle) * speed;
      p.vy = sin(angle) * speed;

      p.maxLife = 1.0 + random.nextDouble() * 0.8;
      p.life = p.maxLife;
      p.size = 1.5 + random.nextDouble() * 2.5;

      // Mỗi vụ chọn 1 hue base + random palette để đa dạng
      p.color = random.nextBool()
          ? _fireworkPalette[random.nextInt(_fireworkPalette.length)]
          : HSVColor.fromAHSV(1, (hueBase + random.nextDouble() * 60) % 360, 0.9, 1.0)
              .toColor();
    }
  }
}

void updateFireworkPhysics(p, double dt) {
  // Drag mạnh để hạt chậm dần — gợi cảm giác nổ rồi rơi
  p.vx -= p.vx * 1.5 * dt;
  p.vy -= p.vy * 1.5 * dt;
  // Gravity nhẹ cho tàn rơi
  GravityPhysics.update(p, dt, gravity: 120);
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
