import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Xoay 3D quanh trục X (radian) theo dấu khoảng cách — flip ngang kiểu coverflow.
/// Set [axis] = 'Y' để dùng [TransformState.rotationY] thay vì rotationX.
class PerspectiveFlipTransform extends ViewportTransform {
  PerspectiveFlipTransform({
    this.maxAngleDegrees = 35,
    this.axis = 'X',
  });

  final double maxAngleDegrees;

  /// 'X' = nghiêng trước/sau (flip ngang), 'Y' = nghiêng trái/phải (coverflow).
  final String axis;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final signed = ((itemCenter - center) / (context.viewportSize / 2)).clamp(-1.0, 1.0);
    final rad = signed * maxAngleDegrees * 3.1415926535 / 180;
    if (axis == 'Y') {
      state.rotationY = rad;
    } else {
      state.rotationX = rad;
    }
  }
}
