import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Bóng đổ động — item ở tâm có shadow đậm + offset dy lớn (cảm giác "bay cao"),
/// ở biên shadow nhỏ lại (item dán xuống nền).
class ShadowTransform extends ViewportTransform {
  ShadowTransform({this.maxSigma = 28, this.maxDy = 18});

  final double maxSigma;
  final double maxDy;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final norm = ((itemCenter - center).abs() / (context.viewportSize / 2)).clamp(0.0, 1.0);
    final closeness = 1 - norm;
    state.shadowSigma = maxSigma * closeness;
    state.shadowDy = maxDy * closeness;
  }
}
