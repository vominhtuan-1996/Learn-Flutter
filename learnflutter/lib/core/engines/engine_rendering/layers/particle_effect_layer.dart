import 'package:flutter/material.dart';

import '../../engine_particle/core/emitter.dart';
import '../../engine_particle/core/particle.dart';
import '../../engine_particle/core/particle_pool.dart';
import '../../engine_particle/physics/gravity.dart';
import '../../engine_particle/physics/velocity.dart';
import '../core/render_layer.dart';

/// Adapter bridge: dùng lại các [ParticleEmitter] của `core/engines/engine_particle`
/// (Fire, Snow, Comet, Confetti, Sparkle, ...) như một [RenderLayer] của
/// `engine_rendering`.
///
/// Khác với [ParticleLayer] (widget standalone với Ticker + RenderBox riêng),
/// layer này KHÔNG có Ticker — nó được drive bởi [RenderLayerController.update]
/// của engine_rendering → tận dụng cùng 1 tick cho mọi layer trong controller.
class ParticleEffectLayer extends RenderLayer {
  ParticleEffectLayer({
    required ParticleEmitter Function(ParticlePool) emitterBuilder,
    this.poolCapacity = 600,
    this.intensity = 1.0,
    this.emitPosition,
    this.customPhysicsUpdate,
    this.autoEmit = true,
  }) {
    _pool = ParticlePool(initialCapacity: poolCapacity);
    _emitter = emitterBuilder(_pool);
  }

  final int poolCapacity;
  final void Function(Particle, double)? customPhysicsUpdate;

  /// >0 emit liên tục theo nhịp tick. = 0 → đứng yên, gọi [emitAt] thủ công.
  double intensity;

  /// Vị trí emit (toạ độ canvas). Null = giữa canvas (tính theo size trong paint).
  Offset? emitPosition;

  /// Nếu false → bỏ qua auto emit, chỉ update physics + paint.
  bool autoEmit;

  late final ParticlePool _pool;
  late final ParticleEmitter _emitter;
  double _acc = 0;
  Size _lastSize = Size.zero;

  /// Emit một burst tại vị trí cụ thể (vd: tap effect).
  void emitAt(Offset position) {
    _emitter.emit(position: position);
  }

  /// Số particle đang sống — debug / HUD.
  int get aliveCount {
    var n = 0;
    for (final p in _pool.particles) {
      if (p.alive) n++;
    }
    return n;
  }

  @override
  void update(double dt) {
    if (autoEmit && intensity > 0) {
      final pos = emitPosition ?? _lastSize.center(Offset.zero);
      _acc += intensity;
      while (_acc >= 1.0) {
        _emitter.emit(position: pos);
        _acc -= 1.0;
      }
    }

    for (final p in _pool.particles) {
      if (!p.alive) continue;
      if (customPhysicsUpdate != null) {
        customPhysicsUpdate!(p, dt);
      } else {
        GravityPhysics.update(p, dt);
        VelocityPhysics.update(p, dt);
        p.life -= dt;
      }
      if (p.maxTrail > 0) {
        (p.trail ??= <Offset>[]).add(Offset(p.x, p.y));
        if (p.trail!.length > p.maxTrail) p.trail!.removeAt(0);
      }
      if (p.life <= 0) p.alive = false;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _lastSize = size;
    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final paint = Paint();
    for (final p in _pool.particles) {
      if (!p.alive) continue;
      final o = (p.life / p.maxLife).clamp(0.0, 1.0);
      final trail = p.trail;
      if (p.maxTrail > 0 && trail != null && trail.length > 1) {
        final path = Path()..moveTo(trail[0].dx, trail[0].dy);
        for (var i = 1; i < trail.length; i++) {
          path.lineTo(trail[i].dx, trail[i].dy);
        }
        trailPaint
          ..color = p.color.withOpacity(o * 0.5)
          ..strokeWidth = p.size * 0.8;
        canvas.drawPath(path, trailPaint);
      }
      paint.color = p.color.withOpacity(o);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }
}
