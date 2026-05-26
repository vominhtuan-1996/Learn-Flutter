import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../core/particle_pool.dart';
import '../physics/velocity.dart';

class SparkleEmitter extends ParticleEmitter {
  SparkleEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    // Bắn ra vài tia sáng ngẫu nhiên
    for (int i = 0; i < 5; i++) {
      final p = pool.obtain();
      p.x = position.dx;
      p.y = position.dy;
      
      p.vx = random.nextDouble() * 100 - 50;
      p.vy = random.nextDouble() * 100 - 50; 
      
      p.maxLife = 0.2 + random.nextDouble() * 0.3; // Tuổi thọ cực ngắn
      p.life = p.maxLife;
      p.size = 2.0 + random.nextDouble() * 2.0;
      
      p.color = Colors.amberAccent;
    }
  }
}

void updateSparklePhysics(p, double dt) {
  // Sparkle chỉ văng ra và biến mất nhanh, không có trọng lực
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
