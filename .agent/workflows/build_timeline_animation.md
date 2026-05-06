---
description: Build timeline animation (sequence nhiều step)
---

#1. Concept Timeline
 ## time (0 → 1)
   ↓
[ Step 1 ][ Step 2 ][ Step 3 ]
   ↓
value (t mapped theo step)
   ↓
Effect
## mỗi step:

có duration
có curve
có range (from → to)
#2. TimelineStep
 class TimelineStep {
  final double start; // 0 → 1
  final double end;
  final double from;
  final double to;
  final double Function(double t)? curve;

  TimelineStep({
    required this.start,
    required this.end,
    required this.from,
    required this.to,
    this.curve,
  });

  double transform(double t) {
    if (t < start) return from;
    if (t > end) return to;

    final localT = (t - start) / (end - start);
    final curved = curve?.call(localT) ?? localT;

    return from + (to - from) * curved;
  }
}
#3. TimelineController
 ## wrap lại controller hiện tại
class TimelineController {
  final CoreAnimController controller;

  TimelineController(this.controller);

  double get t => controller.value;

  void play() => controller.animateTo(1);
  void reverse() => controller.animateTo(0);
}
#4. TimelineEffect (core)
class TimelineEffect extends AnimEffect {
  final List<TimelineStep> steps;
  final Widget Function(double v, Widget child) builder;

  TimelineEffect({
    required this.steps,
    required this.builder,
  });

  @override
  Widget build(double t, Widget child) {
    double value = 0;

    for (final step in steps) {
      value = step.transform(t);
    }

    return builder(value, child);
  }
}
#5. Curve presets (rất quan trọng)
double easeOut(double t) => 1 - pow(1 - t, 3);
double easeIn(double t) => t * t;
double easeInOut(double t) =>
    t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2;
#6. Example 1: Scale sequence
TimelineEffect(
  steps: [
    TimelineStep(
      start: 0.0,
      end: 0.3,
      from: 1,
      to: 0.9,
      curve: easeOut,
    ),
    TimelineStep(
      start: 0.3,
      end: 1.0,
      from: 0.9,
      to: 1,
      curve: easeInOut,
    ),
  ],
  builder: (v, child) {
    return Transform.scale(scale: v, child: child);
  },
)
effect:

press xuống nhanh
bounce lên chậm
7. Example 2: Fade + translate sequence
TimelineEffect(
  steps: [
    TimelineStep(
      start: 0,
      end: 0.5,
      from: 0,
      to: 1,
    ),
  ],
  builder: (v, child) {
    return Opacity(
      opacity: v,
      child: Transform.translate(
        offset: Offset(0, (1 - v) * 20),
        child: child,
      ),
    );
  },
)
8. Multi-track timeline (pro)
class TimelineTrack {
  final List<TimelineStep> steps;

  TimelineTrack(this.steps);

  double value(double t) {
    for (final s in steps) {
      if (t >= s.start && t <= s.end) {
        return s.transform(t);
      }
    }
    return steps.last.to;
  }
}
dùng:
final scaleTrack = TimelineTrack([...]);
final opacityTrack = TimelineTrack([...]);
#9. Compose multi-track
builder: (t, child) {
  final scale = scaleTrack.value(t);
  final opacity = opacityTrack.value(t);

  return Opacity(
    opacity: opacity,
    child: Transform.scale(
      scale: scale,
      child: child,
    ),
  );
}
#10. Preset timeline (rất đáng làm)
class AnimPresets {
  static TimelineEffect press() {
    return TimelineEffect(
      steps: [
        TimelineStep(
          start: 0,
          end: 0.2,
          from: 1,
          to: 0.9,
        ),
        TimelineStep(
          start: 0.2,
          end: 1,
          from: 0.9,
          to: 1,
        ),
      ],
      builder: (v, child) =>
          Transform.scale(scale: v, child: child),
    );
  }
}
#11. Advanced (nếu muốn thêm)
🔥 Delay support
start: 0.3
🔥 Loop
controller.value = (controller.value + dt) % 1;
🔥 Reverse auto
if (t == 1) reverse();
#12. Full usage
final ctrl = CoreAnimController(value: 0);

GestureDetector(
  onTap: () => ctrl.animateTo(1),
  child: AnimatedRepaint(
    controller: ctrl,
    child: child,
    builder: (t, child) {
      return AnimPresets.press().build(t, child);
    },
  ),
)