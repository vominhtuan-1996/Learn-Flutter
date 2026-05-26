import 'package:flutter/material.dart';
import 'package:learnflutter/core/utils/device_dimension.dart';
import 'package:learnflutter/core/utils/extension/extension_widget.dart';

import '../effects/aura.dart';
import '../effects/bubble.dart';
import '../effects/comet.dart';
import '../effects/confetti.dart';
import '../effects/explosion.dart';
import '../effects/fire.dart';
import '../effects/firework.dart';
import '../effects/heart.dart';
import '../effects/rain.dart';
import '../effects/rainbow_trail.dart';
import '../effects/smoke.dart';
import '../effects/snow.dart';
import '../effects/sparkle.dart';
import '../effects/vortex.dart';
import '../widgets/particle_layer.dart';

class ParticleDemoScreen extends StatefulWidget {
  const ParticleDemoScreen({super.key});

  @override
  State<ParticleDemoScreen> createState() => _ParticleDemoScreenState();
}

class _ParticleDemoScreenState extends State<ParticleDemoScreen> {
  int _currentIndex = 0;
  double _intensity = 1.0;
  GlobalKey<ParticleLayerState> _layerKey = GlobalKey();

  final List<Map<String, dynamic>> _effects = [
    {
      'name': 'Fire',
      'emitter': (pool) => FireEmitter(pool),
      'physics': updateFirePhysics,
      'bg': Colors.black,
    },
    {
      'name': 'Snow',
      'emitter': (pool) => SnowEmitter(pool),
      'physics': updateSnowPhysics,
      'bg': const Color(0xFF1E3C72),
    },
    {
      'name': 'Sparkle',
      'emitter': (pool) => SparkleEmitter(pool),
      'physics': updateSparklePhysics,
      'bg': Colors.black87,
    },
    {
      'name': 'Explosion',
      'emitter': (pool) => ExplosionEmitter(pool),
      'physics': updateExplosionPhysics,
      'bg': Colors.black,
    },
    {
      'name': 'Bubble',
      'emitter': (pool) => BubbleEmitter(pool),
      'physics': updateBubblePhysics,
      'bg': const Color(0xFF0C4A6E),
    },
    {
      'name': 'Smoke',
      'emitter': (pool) => SmokeEmitter(pool),
      'physics': updateSmokePhysics,
      'bg': const Color(0xFF1F2937),
    },
    {
      'name': 'Confetti',
      'emitter': (pool) => ConfettiEmitter(pool),
      'physics': updateConfettiPhysics,
      'bg': const Color(0xFF111827),
    },
    {
      'name': 'Rain',
      'emitter': (pool) => RainEmitter(pool),
      'physics': updateRainPhysics,
      'bg': const Color(0xFF0F172A),
    },
    {
      'name': 'Heart',
      'emitter': (pool) => HeartEmitter(pool),
      'physics': updateHeartPhysics,
      'bg': const Color(0xFF4A044E),
    },
    {
      'name': 'Vortex',
      'emitter': (pool) => VortexEmitter(pool),
      'physics': updateVortexPhysics,
      'bg': const Color(0xFF020617),
    },
    {
      'name': 'Rainbow',
      'emitter': (pool) => RainbowTrailEmitter(pool),
      'physics': updateRainbowTrailPhysics,
      'bg': Colors.black,
    },
    {
      'name': 'Firework',
      'emitter': (pool) => FireworkEmitter(pool),
      'physics': updateFireworkPhysics,
      'bg': const Color(0xFF0B1426),
    },
    {
      'name': 'Aura',
      'emitter': (pool) => AuraEmitter(pool),
      'physics': updateAuraPhysics,
      'bg': const Color(0xFF1E1B4B),
    },
    {
      'name': 'Comet',
      'emitter': (pool) => CometEmitter(pool),
      'physics': updateCometPhysics,
      'bg': const Color(0xFF030712),
    },
  ];

  void _selectEffect(int index) {
    setState(() {
      _currentIndex = index;
      // Đổi key để force recreate ParticleLayer (pool/emitter mới).
      _layerKey = GlobalKey<ParticleLayerState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    final effect = _effects[_currentIndex];

    return Scaffold(
      backgroundColor: effect['bg'],
      appBar: AppBar(
        title: const Text('Particle Engine Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        actions: [
          IconButton(
            tooltip: 'Clear all particles',
            icon: const Icon(Icons.cleaning_services, color: Colors.white),
            onPressed: () => _layerKey.currentState?.clearAll(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ParticleLayer(
              key: _layerKey,
              poolCapacity: 2000,
              emitterBuilder: effect['emitter'],
              customPhysicsUpdate: effect['physics'],
              autoEmitOnTouch: true,
              intensity: _intensity,
            ),
          ),

          // ── Live counter overlay (top-left) ──────────────────────────────
          Positioned(
            left: 16,
            top: 8,
            child: _LiveCounter(layerKey: _layerKey),
          ),

          // ── Hint ─────────────────────────────────────────────────────────
          const Center(
            child: IgnorePointer(
              child: Text(
                'Touch and drag to emit particles',
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            ),
          ),

          // ── Bottom controls ──────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed, color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        const Text('Intensity', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Expanded(
                          child: Slider(
                            value: _intensity,
                            min: 0.1,
                            max: 4.0,
                            divisions: 39,
                            label: '×${_intensity.toStringAsFixed(1)}',
                            onChanged: (v) => setState(() => _intensity = v),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '×${_intensity.toStringAsFixed(1)}',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_effects.length, (index) {
                          final selected = _currentIndex == index;
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selected ? Colors.blue : Colors.grey.shade700,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _selectEffect(index),
                            child: Text(_effects[index]['name']),
                          ).paddingSymmetric(
                            horizontal: DeviceDimension.padding / 4,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveCounter extends StatelessWidget {
  const _LiveCounter({required this.layerKey});

  final GlobalKey<ParticleLayerState> layerKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bubble_chart, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          _AliveCountText(layerKey: layerKey),
        ],
      ),
    );
  }
}

class _AliveCountText extends StatefulWidget {
  const _AliveCountText({required this.layerKey});

  final GlobalKey<ParticleLayerState> layerKey;

  @override
  State<_AliveCountText> createState() => _AliveCountTextState();
}

class _AliveCountTextState extends State<_AliveCountText> {
  ValueNotifier<int>? _notifier;

  @override
  void initState() {
    super.initState();
    _bindAfterMount();
  }

  @override
  void didUpdateWidget(covariant _AliveCountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layerKey != widget.layerKey) {
      _notifier = null;
      _bindAfterMount();
    }
  }

  void _bindAfterMount() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final n = widget.layerKey.currentState?.aliveCount;
      if (n != _notifier) setState(() => _notifier = n);
    });
  }

  @override
  Widget build(BuildContext context) {
    final n = _notifier;
    if (n == null) {
      return const Text('alive: 0', style: TextStyle(color: Colors.white, fontSize: 12));
    }
    return ValueListenableBuilder<int>(
      valueListenable: n,
      builder: (_, count, __) => Text(
        'alive: $count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
