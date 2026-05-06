import 'package:flutter/widgets.dart';

abstract class SliverEffect {
  Widget build(BuildContext context, Widget child, double progress);
}

/// Hiệu ứng làm mờ dần theo tiến trình.
class FadeEffect extends SliverEffect {
  @override
  Widget build(BuildContext context, Widget child, double progress) {
    return Opacity(
      opacity: progress,
      child: child,
    );
  }
}

/// Hiệu ứng phóng to/thu nhỏ theo tiến trình.
class ScaleEffect extends SliverEffect {
  final double minScale;

  ScaleEffect({this.minScale = 0.8});

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    final scale = minScale + (1 - minScale) * progress;

    return Transform.scale(
      scale: scale,
      child: child,
    );
  }
}

/// Hiệu ứng Parallax (di chuyển lệch) theo tiến trình.
class ParallaxEffect extends SliverEffect {
  final double offset;

  ParallaxEffect({this.offset = 100});

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    return Transform.translate(
      offset: Offset(0, (1 - progress) * offset),
      child: child,
    );
  }
}

/// Kết hợp nhiều hiệu ứng lại với nhau.
class CombinedEffect extends SliverEffect {
  final List<SliverEffect> effects;

  CombinedEffect(this.effects);

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    Widget current = child;

    for (final effect in effects) {
      current = effect.build(context, current, progress);
    }

    return current;
  }
}
