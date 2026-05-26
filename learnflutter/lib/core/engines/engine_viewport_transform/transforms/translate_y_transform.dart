import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Đẩy item theo trục Y dựa vào khoảng cách tới tâm — tạo hiệu ứng parallax nhẹ.
class TranslateYTransform extends ViewportTransform {
  TranslateYTransform({this.maxOffset = 30, this.invert = false});

  /// Dịch chuyển tối đa (px) ở biên.
  final double maxOffset;

  /// true → đẩy ngược chiều scroll.
  final bool invert;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final signed = ((itemCenter - center) / (context.viewportSize / 2)).clamp(-1.0, 1.0);
    state.translateY += signed * maxOffset * (invert ? -1 : 1);
  }
}
