import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Item càng gần tâm viewport thì [TransformState.zIndex] càng cao —
/// dùng cho `Stack` hoặc list custom để item ở tâm nổi lên trên các item khác.
class ZIndexTransform extends ViewportTransform {
  ZIndexTransform({this.maxZ = 100});

  final double maxZ;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final dist = (itemCenter - center).abs();
    final normalized = (dist / (context.viewportSize / 2)).clamp(0.0, 1.0);
    state.zIndex = (1.0 - normalized) * maxZ;
  }
}
