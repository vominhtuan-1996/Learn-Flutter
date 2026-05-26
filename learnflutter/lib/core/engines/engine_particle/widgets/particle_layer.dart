import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../core/particle_pool.dart';
import '../core/emitter.dart';
import '../core/particle.dart';
import '../physics/gravity.dart';
import '../physics/velocity.dart';

class ParticleLayer extends StatefulWidget {
  final ParticleEmitter Function(ParticlePool) emitterBuilder;
  final void Function(Particle, double)? customPhysicsUpdate;
  final int poolCapacity;
  final bool autoEmitOnTouch;

  /// Bội số tần suất emit khi `autoEmitOnTouch == true`.
  /// - `1.0` → emit 1 lần / frame (mặc định).
  /// - `2.0` → emit 2 lần / frame.
  /// - `0.25` → emit ~1 lần / 4 frame.
  final double intensity;

  const ParticleLayer({
    super.key,
    required this.emitterBuilder,
    this.customPhysicsUpdate,
    this.poolCapacity = 1000,
    this.autoEmitOnTouch = true,
    this.intensity = 1.0,
  });

  @override
  State<ParticleLayer> createState() => ParticleLayerState();
}

class ParticleLayerState extends State<ParticleLayer> with SingleTickerProviderStateMixin {
  late ParticlePool _pool;
  late ParticleEmitter _emitter;
  late Ticker _ticker;
  double _lastTime = 0.0;
  double _emitAccumulator = 0.0;
  Offset _touchPosition = Offset.zero;
  bool _isEmitting = false;

  // Dùng ChangeNotifier để báo cho RenderBox vẽ lại thay vì gọi setState
  final ChangeNotifier _paintNotifier = ChangeNotifier();

  /// Số particle đang sống — listen để hiển thị counter realtime.
  final ValueNotifier<int> aliveCount = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pool = ParticlePool(initialCapacity: widget.poolCapacity);
    _emitter = widget.emitterBuilder(_pool);

    _ticker = createTicker((elapsed) {
      final double currentTime = elapsed.inMicroseconds / 1000000.0;
      double dt = currentTime - _lastTime;
      if (dt > 0.1) dt = 0.016; // Prevent jump after pausing
      _lastTime = currentTime;

      if (_isEmitting && widget.autoEmitOnTouch) {
        _emitAccumulator += widget.intensity;
        while (_emitAccumulator >= 1.0) {
          _emitter.emit(position: _touchPosition);
          _emitAccumulator -= 1.0;
        }
      }

      _updateParticles(dt);
    });
    _ticker.start();
  }

  void emitAt(Offset position) {
    _emitter.emit(position: position);
  }

  /// Kill toàn bộ particle ngay lập tức.
  void clearAll() {
    for (final p in _pool.particles) {
      p.alive = false;
      p.life = 0;
    }
    aliveCount.value = 0;
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    _paintNotifier.notifyListeners();
  }

  void _updateParticles(double dt) {
    int alive = 0;
    for (final p in _pool.particles) {
      if (!p.alive) continue;
      alive++;

      if (widget.customPhysicsUpdate != null) {
        widget.customPhysicsUpdate!(p, dt);
      } else {
        GravityPhysics.update(p, dt);
        VelocityPhysics.update(p, dt);
        p.life -= dt;
      }

      // Lưu lịch sử vị trí cho effect trail/comet.
      if (p.maxTrail > 0) {
        (p.trail ??= <Offset>[]).add(Offset(p.x, p.y));
        if (p.trail!.length > p.maxTrail) p.trail!.removeAt(0);
      }

      if (p.life <= 0) {
        p.alive = false;
        alive--;
      }
    }

    if (aliveCount.value != alive) {
      aliveCount.value = alive;
    }

    if (alive > 0) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      _paintNotifier.notifyListeners();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _paintNotifier.dispose();
    aliveCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = _ParticleRenderWidget(
      pool: _pool,
      paintNotifier: _paintNotifier,
    );

    if (widget.autoEmitOnTouch) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (details) {
          _touchPosition = details.localPosition;
          _isEmitting = true;
        },
        onPanStart: (details) {
          _touchPosition = details.localPosition;
          _isEmitting = true;
        },
        onPanUpdate: (details) {
          _touchPosition = details.localPosition;
        },
        onPanEnd: (_) => _isEmitting = false,
        onPanCancel: () => _isEmitting = false,
        onTapDown: (details) {
          _touchPosition = details.localPosition;
          _isEmitting = true;
        },
        onTapUp: (_) => _isEmitting = false,
        onTapCancel: () => _isEmitting = false,
        child: child,
      );
    }
    
    return child;
  }
}

class _ParticleRenderWidget extends LeafRenderObjectWidget {
  final ParticlePool pool;
  final ChangeNotifier paintNotifier;

  const _ParticleRenderWidget({
    required this.pool,
    required this.paintNotifier,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderParticleLayer(pool: pool, paintNotifier: paintNotifier);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderParticleLayer renderObject) {
    renderObject
      ..pool = pool
      ..paintNotifier = paintNotifier;
  }
}

class _RenderParticleLayer extends RenderBox {
  ParticlePool _pool;
  ChangeNotifier _paintNotifier;
  final Paint _paint = Paint();
  final Paint _trailPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  _RenderParticleLayer({
    required ParticlePool pool,
    required ChangeNotifier paintNotifier,
  })  : _pool = pool,
        _paintNotifier = paintNotifier {
    _paintNotifier.addListener(_onPaintRequested);
  }

  set pool(ParticlePool value) {
    if (_pool == value) return;
    _pool = value;
    markNeedsPaint();
  }

  set paintNotifier(ChangeNotifier value) {
    if (_paintNotifier == value) return;
    _paintNotifier.removeListener(_onPaintRequested);
    _paintNotifier = value;
    _paintNotifier.addListener(_onPaintRequested);
  }

  void _onPaintRequested() {
    if (attached) markNeedsPaint();
  }

  @override
  void dispose() {
    _paintNotifier.removeListener(_onPaintRequested);
    super.dispose();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    for (final p in _pool.particles) {
      if (!p.alive) continue;

      double opacity = (p.life / p.maxLife).clamp(0.0, 1.0);

      // Vẽ vệt đuôi trước (đặt sau particle để không che đầu).
      final trail = p.trail;
      if (p.maxTrail > 0 && trail != null && trail.length > 1) {
        final path = Path()..moveTo(offset.dx + trail[0].dx, offset.dy + trail[0].dy);
        for (int i = 1; i < trail.length; i++) {
          path.lineTo(offset.dx + trail[i].dx, offset.dy + trail[i].dy);
        }
        _trailPaint.color = p.color.withOpacity(opacity * 0.5);
        _trailPaint.strokeWidth = p.size * 0.8;
        canvas.drawPath(path, _trailPaint);
      }

      _paint.color = p.color.withOpacity(opacity);
      canvas.drawCircle(offset + Offset(p.x, p.y), p.size, _paint);
    }
  }
}
