import '../core/particle.dart';

class VelocityPhysics {
  static void update(Particle p, double dt) {
    p.x += p.vx * dt;
    p.y += p.vy * dt;
  }
}
