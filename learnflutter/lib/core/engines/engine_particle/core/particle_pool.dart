import 'package:flutter/material.dart';
import 'particle.dart';

class ParticlePool {
  final List<Particle> _particles;
  final int initialCapacity;

  ParticlePool({this.initialCapacity = 1000}) 
      : _particles = List.generate(
          initialCapacity,
          (_) => Particle(
            x: 0,
            y: 0,
            vx: 0,
            vy: 0,
            life: 0,
            size: 0,
            color: Colors.white,
            alive: false,
          ),
        );

  List<Particle> get particles => _particles;

  Particle obtain() {
    for (final p in _particles) {
      if (!p.alive) {
        p.alive = true;
        // Reset trail state — emitter có thể set lại nếu cần.
        p.maxTrail = 0;
        p.trail?.clear();
        return p;
      }
    }

    // Allocate new if pool exhausted
    final p = Particle(
      x: 0,
      y: 0,
      vx: 0,
      vy: 0,
      life: 0,
      size: 0,
      color: Colors.white,
      alive: true,
    );
    _particles.add(p);
    return p;
  }
}
