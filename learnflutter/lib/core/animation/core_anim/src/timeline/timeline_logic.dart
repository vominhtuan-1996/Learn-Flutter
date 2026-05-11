import 'dart:math';
import '../controller/core_anim_controller.dart';

// ── Curve Presets ─────────────────────────────────────────────────────────────
double tlEaseOut(double t) => 1 - pow(1 - t, 3).toDouble();
double tlEaseIn(double t) => t * t;
double tlEaseInOut(double t) =>
    t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2;

// ── TimelineStep ──────────────────────────────────────────────────────────────
class TimelineStep {
  final double start;
  final double end;
  final double from;
  final double to;
  final double Function(double t)? curve;

  const TimelineStep({
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

// ── TimelineTrack (multi-track support) ───────────────────────────────────────
class TimelineTrack {
  final List<TimelineStep> steps;

  TimelineTrack(this.steps);

  double value(double t) {
    for (final s in steps) {
      if (t >= s.start && t <= s.end) return s.transform(t);
    }
    if (steps.isEmpty) return 0;
    if (t < steps.first.start) return steps.first.from;
    return steps.last.to;
  }
}

// ── TimelineController ────────────────────────────────────────────────────────
class TimelineController {
  final CoreAnimController controller;

  TimelineController(this.controller);

  double get t => controller.value;

  void play() => controller.animateTo(1.0);
  void reverse() => controller.animateTo(0.0);
  void reset() {
    controller.value = 0.0;
    controller.velocity = 0.0;
  }
}
