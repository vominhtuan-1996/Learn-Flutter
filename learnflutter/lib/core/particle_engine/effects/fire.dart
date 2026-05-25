import 'package:flutter/material.dart';
import '../core/emitter.dart';
import '../core/particle_pool.dart';
import '../physics/gravity.dart';
import '../physics/velocity.dart';

class FireEmitter extends ParticleEmitter {
  FireEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    // Lửa có nhiều hạt sinh ra liên tục
    for (int i = 0; i < 3; i++) {
      final p = pool.obtain();
      p.x = position.dx + random.nextDouble() * 20 - 10;
      p.y = position.dy + random.nextDouble() * 10 - 5;
      
      // Vận tốc hướng lên (lửa bay lên)
      p.vx = random.nextDouble() * 20 - 10;
      p.vy = -random.nextDouble() * 50 - 50; 
      
      p.maxLife = 0.5 + random.nextDouble() * 0.5;
      p.life = p.maxLife;
      p.size = 3.0 + random.nextDouble() * 5.0;
      
      // Màu từ vàng đến đỏ
      final isRed = random.nextBool();
      p.color = isRed ? Colors.red : Colors.orangeAccent;
    }
  }
}

// Custom update cho Fire
void updateFirePhysics(p, dt) {
  // Lửa bay lên, không bị trọng lực hút xuống, có thể thêm drag (cản gió)
  VelocityPhysics.update(p, dt);
  
  // Hạt lửa nhỏ dần khi sắp tàn
  if (p.life < p.maxLife / 2) {
    p.size -= dt * 5;
    if (p.size < 0) p.size = 0.0;
  }
  
  p.life -= dt;
}
