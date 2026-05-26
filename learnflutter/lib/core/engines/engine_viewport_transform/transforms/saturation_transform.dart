import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Giảm độ bão hoà màu khi item rời tâm — ở biên item về gần grayscale.
class SaturationTransform extends ViewportTransform {
  SaturationTransform({this.minSaturation = 0.0});

  /// 0 = grayscale hoàn toàn ở biên, 1 = không thay đổi.
  final double minSaturation;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final dist = (itemCenter - center).abs();
    final normalized = (dist / (context.viewportSize / 2)).clamp(0.0, 1.0);
    state.saturation = 1.0 - (1.0 - minSaturation) * normalized;
  }
}
