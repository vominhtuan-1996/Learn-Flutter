import 'package:flutter/widgets.dart';
import '../effect/effects.dart';
import 'timeline_logic.dart';

/// TimelineEffect - AnimEffect đặc biệt cho phép sequence nhiều step.
class TimelineEffect extends AnimEffect {
  final List<TimelineStep> steps;
  final Widget Function(double v, Widget child) builder;

  TimelineEffect({required this.steps, required this.builder});

  @override
  Widget build(double t, Widget child) {
    // Lấy giá trị từ step cuối cùng có t nằm trong range
    double value = steps.isEmpty ? t : steps.first.from;
    for (final step in steps) {
      value = step.transform(t);
    }
    return builder(value, child);
  }
}

/// MultiTrackEffect - Compose nhiều track (Scale, Opacity, ...) đồng thời.
class MultiTrackEffect extends AnimEffect {
  final Widget Function(double t, Widget child) builder;

  MultiTrackEffect({required this.builder});

  @override
  Widget build(double t, Widget child) => builder(t, child);
}
