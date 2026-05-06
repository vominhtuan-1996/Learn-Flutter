---
description: Refine reusable package structure (core aniamtion)
---

🧠 1. Mục tiêu package
✅ 1 ticker global
✅ 1 controller chung (spring-based)
✅ widget wrapper nhẹ (RepaintBoundary)
✅ dễ compose effect
❌ không phụ thuộc vào widget phức tạp
❌ không ép dùng RenderObject


#2. Cấu trúc package
core_anim/
├── core_anim.dart
│
├── src/
│   ├── ticker/
│   │   └── core_ticker.dart
│   │
│   ├── controller/
│   │   └── core_anim_controller.dart
│   │
│   ├── widget/
│   │   └── animated_repaint.dart
│   │
│   ├── effect/
│   │   ├── scale_effect.dart
│   │   ├── translate_effect.dart
│   │   ├── opacity_effect.dart
│   │   └── composite_effect.dart
│   │
│   └── painter/
│       └── ripple_painter.dart

#3. Public API (core_anim.dart)
library core_anim;

export 'src/ticker/core_ticker.dart';
export 'src/controller/core_anim_controller.dart';
export 'src/widget/animated_repaint.dart';

export 'src/effect/scale_effect.dart';
export 'src/effect/translate_effect.dart';
export 'src/effect/opacity_effect.dart';
export 'src/effect/composite_effect.dart';

export 'src/painter/ripple_painter.dart';
#4. CoreTicker (singleton)
class CoreTicker {
  static final CoreTicker _instance = CoreTicker._();
  factory CoreTicker() => _instance;

  CoreTicker._();

  final _listeners = <void Function(double dt)>[];
  Duration _last = Duration.zero;

  void add(void Function(double dt) l) => _listeners.add(l);

  void start(TickerProvider vsync) {
    vsync.createTicker((elapsed) {
      final dt = (_last == Duration.zero)
          ? 0.0
          : (elapsed - _last).inMicroseconds / 1e6;

      _last = elapsed;

      for (final l in _listeners) {
        l(dt);
      }
    }).start();
  }
}
5. CoreAnimController
class CoreAnimController {
  double value;
  double target;
  double velocity = 0;

  CoreAnimController({this.value = 1, this.target = 1});

  void animateTo(double t) {
    target = t;
  }

  void update(double dt) {
    const k = 300;
    const d = 20;

    final force = k * (target - value);
    velocity += force * dt;
    velocity *= exp(-d * dt);

    value += velocity * dt;
  }
}
#6. AnimatedRepaint (core widget)
class AnimatedRepaint extends StatefulWidget {
  final CoreAnimController controller;
  final Widget child;
  final Widget Function(double value, Widget child) builder;

  const AnimatedRepaint({
    super.key,
    required this.controller,
    required this.child,
    required this.builder,
  });

  @override
  State createState() => _AnimatedRepaintState();
}

class _AnimatedRepaintState extends State<AnimatedRepaint> {
  @override
  void initState() {
    super.initState();

    CoreTicker().add((dt) {
      widget.controller.update(dt);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: widget.builder(
        widget.controller.value,
        widget.child,
      ),
    );
  }
}
7. Effect system (composable)
🔹 base
abstract class AnimEffect {
  Widget build(double t, Widget child);
}
🔹 scale
class ScaleEffect extends AnimEffect {
  final double min;
  final double max;

  ScaleEffect({this.min = 0.9, this.max = 1});

  @override
  Widget build(double t, Widget child) {
    final scale = min + (max - min) * t;
    return Transform.scale(scale: scale, child: child);
  }
}
🔹 translate
class TranslateEffect extends AnimEffect {
  final Offset from;
  final Offset to;

  TranslateEffect(this.from, this.to);

  @override
  Widget build(double t, Widget child) {
    return Transform.translate(
      offset: Offset.lerp(from, to, t)!,
      child: child,
    );
  }
}
🔹 composite
class CompositeEffect extends AnimEffect {
  final List<AnimEffect> effects;

  CompositeEffect(this.effects);

  @override
  Widget build(double t, Widget child) {
    Widget result = child;

    for (final e in effects.reversed) {
      result = e.build(t, result);
    }

    return result;
  }
}
#8. RipplePainter (optional module)
class RipplePainter extends CustomPainter {
  final double progress;

  RipplePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(1 - progress)
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      size.center(Offset.zero),
      progress * 80,
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => true;
}
#9. Usage (clean & reusable)
final ctrl = CoreAnimController(value: 1);

GestureDetector(
  onTapDown: (_) => ctrl.animateTo(0),
  onTapUp: (_) => ctrl.animateTo(1),
  child: AnimatedRepaint(
    controller: ctrl,
    child: child,
    builder: (t, child) {
      return CompositeEffect([
        ScaleEffect(min: 0.9, max: 1),
        TranslateEffect(
          Offset(0, 10),
          Offset.zero,
        ),
      ]).build(t, child);
    },
  ),
)
#10. Optional extension (rất nên có)
🔥 extension API
extension AnimControllerX on CoreAnimController {
  void press() => animateTo(0);
  void release() => animateTo(1);
}