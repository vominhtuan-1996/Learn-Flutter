import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Dịch chuyển hue của item theo khoảng cách signed tới tâm —
/// item trên / dưới sẽ ngả về 2 phía hue khác nhau, ở tâm giữ nguyên.
class HueShiftTransform extends ViewportTransform {
  HueShiftTransform({this.maxHueDegrees = 90});

  /// Hue tối đa (độ) khi item ở biên — đổi sang radian khi apply ma trận.
  final double maxHueDegrees;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final signed = ((itemCenter - center) / (context.viewportSize / 2)).clamp(-1.0, 1.0);
    state.hueShift = signed * maxHueDegrees * 3.1415926535 / 180;
  }
}
