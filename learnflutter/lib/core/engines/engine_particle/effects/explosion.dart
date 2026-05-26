import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../core/particle_pool.dart';
import '../physics/velocity.dart';

class ExplosionEmitter extends ParticleEmitter {
  ExplosionEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    // Vụ nổ bắn ra hàng chục hạt theo mọi hướng
    for (int i = 0; i < 50; i++) {
      final p = pool.obtain();
      p.x = position.dx;
      p.y = position.dy;
      
      // Radial velocity
      double angle = random.nextDouble() * 2 * pi;
      double speed = random.nextDouble() * 300 + 100;
      
      p.vx = cos(angle) * speed;
      p.vy = sin(angle) * speed; 
      
      p.maxLife = 0.3 + random.nextDouble() * 0.4;
      p.life = p.maxLife;
      p.size = 2.0 + random.nextDouble() * 4.0;
      
      final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.grey];
      p.color = colors[random.nextInt(colors.length)];
    }
  }
}

void updateExplosionPhysics(p, double dt) {
  // Vận tốc giảm dần (drag/friction)
  p.vx -= p.vx * 3 * dt;
  p.vy -= p.vy * 3 * dt;
  
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
