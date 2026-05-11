import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/core_anim/core_anim.dart';

class TimelineDemoScreen extends StatefulWidget {
  const TimelineDemoScreen({super.key});

  @override
  State<TimelineDemoScreen> createState() => _TimelineDemoScreenState();
}

class _TimelineDemoScreenState extends State<TimelineDemoScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    CoreTicker().start(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Timeline Animation', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _label('Preset: pressBounce'),
          const SizedBox(height: 12),
          const _PressBounceDemo(),
          const SizedBox(height: 32),
          _label('Preset: fadeInSlide (tap to play)'),
          const SizedBox(height: 12),
          const _FadeInSlideDemo(),
          const SizedBox(height: 32),
          _label('Multi-track: Scale + Opacity'),
          const SizedBox(height: 12),
          const _MultiTrackDemo(),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600));
}

// ── Press Bounce ────────────────────────────────────────────────────────────
class _PressBounceDemo extends StatelessWidget {
  const _PressBounceDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 1.0, target: 1.0);
    return Center(
      child: GestureDetector(
        onTapDown: (_) => ctrl.animateTo(0.0),
        onTapUp: (_) => ctrl.animateTo(1.0),
        onTapCancel: () => ctrl.animateTo(1.0),
        child: AnimatedRepaint(
          controller: ctrl,
          child: _card(
            color: const Color(0xFF6C63FF),
            icon: Icons.touch_app,
            label: 'Hold Me',
          ),
          builder: (t, child) => AnimPresets.pressBounce().build(t, child),
        ),
      ),
    );
  }
}

// ── Fade In Slide ───────────────────────────────────────────────────────────
class _FadeInSlideDemo extends StatelessWidget {
  const _FadeInSlideDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 0.0, target: 0.0);
    return Center(
      child: GestureDetector(
        onTap: () {
          ctrl.value = 0.0;
          ctrl.velocity = 0.0;
          ctrl.animateTo(1.0);
        },
        child: AnimatedRepaint(
          controller: ctrl,
          child: _card(
            color: const Color(0xFFFF6584),
            icon: Icons.play_arrow_rounded,
            label: 'Tap to Play',
          ),
          builder: (t, child) => AnimPresets.fadeInSlide().build(t, child),
        ),
      ),
    );
  }
}

// ── Multi-track ─────────────────────────────────────────────────────────────
class _MultiTrackDemo extends StatelessWidget {
  const _MultiTrackDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 0.0, target: 0.0);
    return Center(
      child: GestureDetector(
        onTap: () {
          ctrl.value = 0.0;
          ctrl.velocity = 0.0;
          ctrl.animateTo(1.0);
        },
        child: AnimatedRepaint(
          controller: ctrl,
          child: _card(
            color: const Color(0xFF43D8C9),
            icon: Icons.layers_rounded,
            label: 'Multi-track',
          ),
          builder: (t, child) => AnimPresets.scaleOpacity().build(t, child),
        ),
      ),
    );
  }
}

// ── Shared card widget ───────────────────────────────────────────────────────
Widget _card({required Color color, required IconData icon, required String label}) {
  return Container(
    width: 200,
    height: 100,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 36),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
