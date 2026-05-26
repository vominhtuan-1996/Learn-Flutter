import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../engine_particle/effects/fire.dart';
import '../../engine_particle/effects/snow.dart';
import '../../engine_particle/effects/sparkle.dart';
import '../core/render_layer.dart';
import '../core/render_layer_controller.dart';
import '../layers/background_layer.dart';
import '../layers/confetti_layer.dart';
import '../layers/glow_layer.dart';
import '../layers/gradient_layer.dart';
import '../layers/grid_layer.dart';
import '../layers/lightning_layer.dart';
import '../layers/particle_effect_layer.dart';
import '../layers/pulse_ring_layer.dart';
import '../layers/text_layer.dart';
import '../layers/wave_layer.dart';
import '../widgets/render_layer_view.dart';

/// Demo trực quan engine_rendering với toàn bộ layer built-in + custom layer.
/// Mỗi layer có thể toggle riêng → quan sát từng layer hoạt động.
class EngineRenderingExampleScreen extends StatefulWidget {
  const EngineRenderingExampleScreen({super.key});

  @override
  State<EngineRenderingExampleScreen> createState() => _EngineRenderingExampleScreenState();
}

class _EngineRenderingExampleScreenState extends State<EngineRenderingExampleScreen> with SingleTickerProviderStateMixin {
  late final RenderLayerController _controller;
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  // Layers (mỗi layer 1 instance, toggle qua .visible)
  late final BackgroundLayer _bg;
  late final GradientLayer _gradient;
  late final GridLayer _grid;
  late final WaveLayer _wave;
  late final GlowLayer _glow;
  late final _OrbitGlowLayer _orbit;
  late final PulseRingLayer _pulse;
  late final _StarFieldLayer _stars;
  late final ConfettiLayer _confetti;
  late final LightningLayer _lightning;
  late final TextLayer _text;
  // Reuse particle_engine effects qua adapter ParticleEffectLayer.
  late final ParticleEffectLayer _fire;
  late final ParticleEffectLayer _snow;
  late final ParticleEffectLayer _sparkle;

  // UI state
  double _glowRadius = 120;

  @override
  void initState() {
    super.initState();
    _controller = RenderLayerController();

    _bg = BackgroundLayer(color: const Color(0xFF0F172A));
    _gradient = GradientLayer();
    _grid = GridLayer(cellSize: 50, dx: 14);
    _wave = WaveLayer(color: const Color(0x553B82F6), yFactor: 0.78, amplitude: 28);
    _glow = GlowLayer(radius: _glowRadius, color: const Color(0x553B82F6), blurSigma: 40);
    _orbit = _OrbitGlowLayer();
    _pulse = PulseRingLayer(color: const Color(0xFF22D3EE), maxRadius: 220, ringCount: 4);
    _stars = _StarFieldLayer(count: 100);
    _confetti = ConfettiLayer(count: 50);
    _lightning = LightningLayer();
    _text = TextLayer(
      text: 'ENGINE RENDERING',
      style: const TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 3),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 24),
    );

    // Bridge: dùng emitter của particle_engine qua ParticleEffectLayer.
    _fire = ParticleEffectLayer(
      emitterBuilder: (pool) => FireEmitter(pool),
      poolCapacity: 400,
      intensity: 1.5,
    );
    _snow = ParticleEffectLayer(
      emitterBuilder: (pool) => SnowEmitter(pool),
      poolCapacity: 400,
      intensity: 1.0,
    );
    _sparkle = ParticleEffectLayer(
      emitterBuilder: (pool) => SparkleEmitter(pool),
      poolCapacity: 300,
      intensity: 1.0,
    );

    // Default: chỉ bật một bộ "đẹp" để mở screen đã thấy động.
    _gradient.visible = false;
    _grid.visible = false;
    _confetti.visible = false;
    _lightning.visible = false;
    _fire.visible = false;
    _snow.visible = false;
    _sparkle.visible = false;

    _controller
      ..add(_bg)
      ..add(_gradient)
      ..add(_grid)
      ..add(_wave)
      ..add(_glow)
      ..add(_orbit)
      ..add(_pulse)
      ..add(_stars)
      ..add(_confetti)
      ..add(_lightning)
      ..add(_fire)
      ..add(_snow)
      ..add(_sparkle)
      ..add(_text);

    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      _controller.update(dt);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleLayer(RenderLayer layer, bool v) {
    setState(() => layer.visible = v);
    _controller.update(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        foregroundColor: Colors.white,
        title: const Text('Engine Rendering Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RenderLayerView(controller: _controller),
          ),
          Container(
            color: const Color(0xFF111827),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Layers — tap để bật/tắt',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('Background', _bg),
                    _chip('Gradient', _gradient),
                    _chip('Grid', _grid),
                    _chip('Wave', _wave),
                    _chip('Glow', _glow),
                    _chip('Orbit', _orbit),
                    _chip('Pulse Ring', _pulse),
                    _chip('Stars', _stars),
                    _chip('Confetti', _confetti),
                    _chip('Lightning', _lightning),
                    _chip('🔥 Fire (PE)', _fire),
                    _chip('❄️ Snow (PE)', _snow),
                    _chip('✨ Sparkle (PE)', _sparkle),
                    _chip('Text', _text),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Glow R', style: TextStyle(color: Colors.white70, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _glowRadius,
                        min: 40,
                        max: 260,
                        onChanged: (v) {
                          setState(() => _glowRadius = v);
                          _glow.radius = v;
                          _controller.update(0);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, RenderLayer layer) {
    final on = layer.visible;
    return GestureDetector(
      onTap: () => _toggleLayer(layer, !on),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: on ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: on ? const Color(0xFF60A5FA) : Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(on ? Icons.visibility : Icons.visibility_off, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _OrbitGlowLayer extends RenderLayer {
  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = math.min(size.width, size.height) * 0.32;
    final pos = Offset(
      center.dx + math.cos(_t * 1.2) * r,
      center.dy + math.sin(_t * 1.2) * r,
    );
    final paint = Paint()
      ..color = const Color(0x66EC4899)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(pos, 70, paint);
  }
}

class _StarFieldLayer extends RenderLayer {
  _StarFieldLayer({this.count = 60}) {
    final rng = math.Random(42);
    for (var i = 0; i < count; i++) {
      _stars.add(_Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        speed: 0.02 + rng.nextDouble() * 0.08,
        radius: 0.6 + rng.nextDouble() * 1.8,
        alpha: 0.3 + rng.nextDouble() * 0.7,
      ));
    }
  }

  final int count;
  final List<_Star> _stars = [];

  @override
  void update(double dt) {
    for (final s in _stars) {
      s.y += s.speed * dt;
      if (s.y > 1.05) s.y = -0.05;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in _stars) {
      paint.color = Color.fromRGBO(255, 255, 255, s.alpha);
      canvas.drawCircle(Offset(s.x * size.width, s.y * size.height), s.radius, paint);
    }
  }
}

class _Star {
  _Star({required this.x, required this.y, required this.speed, required this.radius, required this.alpha});
  double x, y, speed, radius, alpha;
}
