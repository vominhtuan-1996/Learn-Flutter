import 'dart:math';
import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../core/particle_pool.dart';
import '../physics/gravity.dart';
import '../physics/velocity.dart';

class SnowEmitter extends ParticleEmitter {
  SnowEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    final p = pool.obtain();
    // Tuyết rơi từ trên màn hình, position truyền vào thường là Offset(x ngẫu nhiên, 0)
    p.x = position.dx + random.nextDouble() * 40 - 20;
    p.y = position.dy;
    
    // Vận tốc ngang (gió thổi), vận tốc rơi chậm
    p.vx = random.nextDouble() * 40 - 20;
    p.vy = random.nextDouble() * 20 + 20; 
    
    p.maxLife = 5.0 + random.nextDouble() * 5.0; // Sống lâu để rơi hết màn hình
    p.life = p.maxLife;
    p.size = 1.0 + random.nextDouble() * 3.0;
    
    p.color = Colors.white;
  }
}

void updateSnowPhysics(p, double dt) {
  // Trọng lực nhẹ
  GravityPhysics.update(p, dt, gravity: 10);
  
  // Gió tạt qua lại (Sine wave)
  p.vx += sin(p.life * 2) * 50 * dt;
  
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
