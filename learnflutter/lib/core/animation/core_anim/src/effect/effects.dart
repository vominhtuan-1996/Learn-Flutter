import 'package:flutter/widgets.dart';

/// Base class cho tất cả hiệu ứng animation có thể compose.
abstract class AnimEffect {
  Widget build(double t, Widget child);
}

/// Scale effect - phóng to/thu nhỏ widget theo giá trị t.
class ScaleEffect extends AnimEffect {
  final double min;
  final double max;

  ScaleEffect({this.min = 0.9, this.max = 1.0});

  @override
  Widget build(double t, Widget child) {
    final scale = min + (max - min) * t;
    return Transform.scale(scale: scale, child: child);
  }
}

/// Translate effect - dịch chuyển widget từ [from] đến [to] theo t.
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

/// Opacity effect - thay đổi độ trong suốt theo t.
class OpacityEffect extends AnimEffect {
  final double min;
  final double max;

  OpacityEffect({this.min = 0.0, this.max = 1.0});

  @override
  Widget build(double t, Widget child) {
    final opacity = (min + (max - min) * t).clamp(0.0, 1.0);
    return Opacity(opacity: opacity, child: child);
  }
}

/// Composite effect - kết hợp nhiều [AnimEffect] lại thành 1 pipeline.
/// Áp dụng theo thứ tự ngược (reversed) để wrap đúng từ ngoài vào trong.
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
