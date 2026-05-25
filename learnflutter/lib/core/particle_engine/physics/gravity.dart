import '../core/particle.dart';

class GravityPhysics {
  static void update(Particle p, double dt, {double gravity = 300}) {
    p.vy += gravity * dt;
  }
}
