import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Đẩy item theo trục X dựa khoảng cách signed tới tâm — parallax ngang.
class TranslateXTransform extends ViewportTransform {
  TranslateXTransform({this.maxOffset = 40, this.invert = false});

  final double maxOffset;
  final bool invert;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final signed = ((itemCenter - center) / (context.viewportSize / 2)).clamp(-1.0, 1.0);
    state.translateX += signed * maxOffset * (invert ? -1 : 1);
  }
}
