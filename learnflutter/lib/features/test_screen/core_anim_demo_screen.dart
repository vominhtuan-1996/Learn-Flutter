import 'package:flutter/material.dart';
import 'package:learnflutter/core/animation/core_anim/core_anim.dart';

class CoreAnimDemoScreen extends StatefulWidget {
  const CoreAnimDemoScreen({super.key});

  @override
  State<CoreAnimDemoScreen> createState() => _CoreAnimDemoScreenState();
}

class _CoreAnimDemoScreenState extends State<CoreAnimDemoScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Khởi động global ticker một lần duy nhất
    CoreTicker().start(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Core Anim Package Demo',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionTitle('Spring Scale (Tap & Hold)'),
          const SizedBox(height: 12),
          const _SpringScaleDemo(),
          const SizedBox(height: 32),
          _SectionTitle('Composite Effect (Scale + Translate + Opacity)'),
          const SizedBox(height: 12),
          const _CompositeDemo(),
          const SizedBox(height: 32),
          _SectionTitle('Ripple Effect'),
          const SizedBox(height: 12),
          const _RippleDemo(),
        ],
      ),
    );
  }

  Widget _SectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
      );
}

// ─────────────────────────────────────────────
class _SpringScaleDemo extends StatelessWidget {
  const _SpringScaleDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 1.0, target: 1.0);
    return Center(
      child: GestureDetector(
        onTapDown: (_) => ctrl.press(),
        onTapUp: (_) => ctrl.release(),
        onTapCancel: () => ctrl.release(),
        child: AnimatedRepaint(
          controller: ctrl,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF3F8EFC)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.touch_app, color: Colors.white, size: 48),
            ),
          ),
          builder: (t, child) => ScaleEffect(min: 0.88).build(t, child),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _CompositeDemo extends StatelessWidget {
  const _CompositeDemo();

  @override
  Widget build(BuildContext context) {
    final ctrl = CoreAnimController(value: 1.0, target: 1.0);
    return Center(
      child: GestureDetector(
        onTapDown: (_) => ctrl.press(),
        onTapUp: (_) => ctrl.release(),
        onTapCancel: () => ctrl.release(),
        child: AnimatedRepaint(
          controller: ctrl,
          child: Container(
            width: 200,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6584), Color(0xFFFF9A44)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: Text('Composite Effect',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          builder: (t, child) => CompositeEffect([
            ScaleEffect(min: 0.92),
            TranslateEffect(const Offset(0, 6), Offset.zero),
            OpacityEffect(min: 0.6),
          ]).build(t, child),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _RippleDemo extends StatelessWidget {
  const _RippleDemo();

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
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF43D8C9),
              borderRadius: BorderRadius.circular(80),
            ),
            child: const Center(
              child: Icon(Icons.radio_button_unchecked,
                  color: Colors.white, size: 32),
            ),
          ),
          builder: (t, child) => Stack(
            alignment: Alignment.center,
            children: [
              child,
              CustomPaint(
                painter: RipplePainter(
                  progress: t,
                  color: const Color(0xFF43D8C9),
                  maxRadius: 100,
                ),
                size: const Size(200, 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
