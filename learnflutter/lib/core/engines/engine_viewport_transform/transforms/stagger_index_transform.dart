import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Phase shift opacity + translateX theo index — item lẻ/chẵn lệch nhau,
/// tạo cảm giác staggered "so le" khi cuộn.
class StaggerIndexTransform extends ViewportTransform {
  StaggerIndexTransform({this.offsetX = 16, this.opacityDip = 0.15});

  /// Offset X giữa item chẵn vs lẻ (px).
  final double offsetX;

  /// Giảm opacity của item lệch (0..1).
  final double opacityDip;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final isOdd = item.index.isOdd;
    state.translateX += isOdd ? offsetX : -offsetX;
    if (isOdd) state.opacity *= (1 - opacityDip).clamp(0.0, 1.0);
  }
}
