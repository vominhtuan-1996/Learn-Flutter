import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Giảm opacity khi item rời xa tâm viewport.
class OpacityTransform extends ViewportTransform {
  OpacityTransform({this.minOpacity = 0.2});

  /// Opacity tối thiểu khi item ở biên.
  final double minOpacity;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final distance = (itemCenter - center).abs();
    final normalized = (distance / (context.viewportSize / 2)).clamp(0.0, 1.0);
    state.opacity = 1.0 - (1.0 - minOpacity) * normalized;
  }
}
