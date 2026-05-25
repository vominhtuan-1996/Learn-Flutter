import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Hợp đồng chung của mọi hiệu ứng sliver — nhận `progress` (0..1) và
/// wrap `child` theo kiểu hình học/hiệu ứng tương ứng.
///
/// `progress = 1.0` → trạng thái "đầy đủ" (xuất hiện hoàn toàn / ở tâm).
/// `progress = 0.0` → trạng thái "khởi đầu" (chưa xuất hiện / xa tâm).
///
/// Hai engine cùng dùng interface này:
/// - [SliverAnimationCoordinator]: progress từ scroll offset range.
/// - [ViewportAwareItem]: progress từ khoảng cách tới tâm viewport.
abstract class SliverEffect {
  const SliverEffect();

  Widget build(BuildContext context, Widget child, double progress);
}

/// Mờ dần theo `progress` — `progress=0` → mờ tới `minOpacity`.
class FadeEffect extends SliverEffect {
  final double minOpacity;

  const FadeEffect({this.minOpacity = 0.0});

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    final opacity = (minOpacity + (1.0 - minOpacity) * progress).clamp(0.0, 1.0);
    return Opacity(opacity: opacity, child: child);
  }
}

/// Thu nhỏ theo `progress` — `progress=0` → scale `minScale`.
class ScaleEffect extends SliverEffect {
  final double minScale;
  final Alignment alignment;

  const ScaleEffect({this.minScale = 0.8, this.alignment = Alignment.center});

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    final scale = minScale + (1.0 - minScale) * progress;
    return Transform.scale(scale: scale, alignment: alignment, child: child);
  }
}

/// Dịch chuyển dọc — `progress=0` → translate `maxOffsetY`.
class ParallaxEffect extends SliverEffect {
  final double maxOffsetY;
  final double maxOffsetX;

  const ParallaxEffect({this.maxOffsetY = 80, this.maxOffsetX = 0});

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    final dx = (1.0 - progress) * maxOffsetX;
    final dy = (1.0 - progress) * maxOffsetY;
    return Transform.translate(offset: Offset(dx, dy), child: child);
  }
}

/// Mờ Gaussian — `progress=0` → blur `maxBlur` pixels.
class BlurEffect extends SliverEffect {
  final double maxBlur;

  const BlurEffect({this.maxBlur = 10.0});

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    final blur = (1.0 - progress) * maxBlur;
    if (blur < 0.1) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: child,
    );
  }
}

/// Composite — áp dụng nhiều effect theo thứ tự khai báo.
class CombinedEffect extends SliverEffect {
  final List<SliverEffect> effects;

  const CombinedEffect(this.effects);

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    Widget current = child;
    for (final e in effects) {
      current = e.build(context, current, progress);
    }
    return current;
  }
}
