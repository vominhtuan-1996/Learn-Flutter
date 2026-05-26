import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../physics/velocity.dart';

/// Rainbow Trail — mỗi hạt đổi màu theo HSV hue chạy qua life,
/// tạo dải cầu vồng khi kéo tay.
class RainbowTrailEmitter extends ParticleEmitter {
  RainbowTrailEmitter(super.pool);

  double _hueSeed = 0;

  @override
  void emit({required Offset position}) {
    _hueSeed = (_hueSeed + 4) % 360;
    for (int i = 0; i < 2; i++) {
      final p = pool.obtain();
      p.x = position.dx + random.nextDouble() * 8 - 4;
      p.y = position.dy + random.nextDouble() * 8 - 4;
      p.vx = random.nextDouble() * 40 - 20;
      p.vy = random.nextDouble() * 40 - 20;
      p.maxLife = 1.2 + random.nextDouble() * 0.6;
      p.life = p.maxLife;
      p.size = 3.0 + random.nextDouble() * 2.0;
      p.color = HSVColor.fromAHSV(1, _hueSeed, 0.9, 1.0).toColor();
    }
  }
}

void updateRainbowTrailPhysics(p, double dt) {
  // Hue dịch chuyển theo % life đã trôi qua.
  final progress = 1 - p.life / p.maxLife;
  final baseHue = HSVColor.fromColor(p.color).hue;
  final hue = (baseHue + progress * 6) % 360;
  p.color = HSVColor.fromAHSV(1, hue, 0.9, 1.0).toColor();

  // Dao động nhẹ
  p.vx += sin(p.life * 8) * 30 * dt;
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
