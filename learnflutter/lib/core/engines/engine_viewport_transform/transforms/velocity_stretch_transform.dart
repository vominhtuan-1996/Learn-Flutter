import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Squash & stretch theo tốc độ cuộn: cuộn nhanh → kéo dài trục Y, ép trục X
/// (cảm giác item bị "gió thổi"). Đứng yên → trở về 1:1.
class VelocityStretchTransform extends ViewportTransform {
  VelocityStretchTransform({
    this.maxStretchY = 0.18,
    this.velocityCap = 3000,
  });

  /// Tỉ lệ kéo Y tối đa (vd 0.18 = +18% Y, -18% X tương ứng).
  final double maxStretchY;

  /// Velocity (px/s) tại đó đạt maxStretch — vượt quá sẽ clamp.
  final double velocityCap;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final v = (context.velocity / velocityCap).clamp(-1.0, 1.0);
    final stretch = v.abs() * maxStretchY;
    state.scaleY *= 1 + stretch;
    state.scaleX *= 1 - stretch;
  }
}
