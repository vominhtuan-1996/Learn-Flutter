import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Bóp item theo trục scroll: rộng ra ở tâm, hẹp lại ở biên (scaleY < scaleX).
/// Hiệu ứng kiểu Apple Cover Flow / iOS Music wheel.
class SqueezeTransform extends ViewportTransform {
  SqueezeTransform({this.minScaleAcrossAxis = 0.7});

  final double minScaleAcrossAxis;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final dist = (itemCenter - center).abs();
    final normalized = (dist / (context.viewportSize / 2)).clamp(0.0, 1.0);
    state.scaleY = 1.0 - (1.0 - minScaleAcrossAxis) * normalized;
  }
}
