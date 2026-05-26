import 'dart:math' as math;

import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Xoay item theo dấu khoảng cách tới tâm — item phía trên nghiêng một chiều,
/// phía dưới nghiêng chiều ngược lại, ở tâm thì thẳng.
class RotationTransform extends ViewportTransform {
  RotationTransform({this.maxAngleDegrees = 12});

  /// Góc xoay tối đa (độ) khi item ở biên.
  final double maxAngleDegrees;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final signed = (itemCenter - center) / (context.viewportSize / 2);
    final clamped = signed.clamp(-1.0, 1.0);
    state.rotation = clamped * maxAngleDegrees * math.pi / 180;
  }
}
