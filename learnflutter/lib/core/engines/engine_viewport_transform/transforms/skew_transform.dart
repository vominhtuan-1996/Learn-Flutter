import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Skew item theo trục X/Y tỉ lệ với khoảng cách signed tới tâm.
class SkewTransform extends ViewportTransform {
  SkewTransform({this.maxSkewX = 0.0, this.maxSkewY = 0.25});

  /// Skew tối đa (radian) ở biên.
  final double maxSkewX;
  final double maxSkewY;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final signed = ((itemCenter - center) / (context.viewportSize / 2)).clamp(-1.0, 1.0);
    state.skewX = signed * maxSkewX;
    state.skewY = signed * maxSkewY;
  }
}
