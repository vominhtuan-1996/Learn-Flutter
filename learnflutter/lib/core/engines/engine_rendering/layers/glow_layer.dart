import 'package:flutter/material.dart';
import '../core/render_layer.dart';

/// Layer vẽ một vòng tròn toả sáng (glow) với MaskFilter.
class GlowLayer extends RenderLayer {
  Offset position;
  double radius;
  Color color;
  double blurSigma;

  GlowLayer({
    this.position = Offset.zero,
    this.radius = 120.0,
    this.color = const Color(0x332196F3), // Colors.blue.withOpacity(0.2)
    this.blurSigma = 30.0,
  });

  @override
  void update(double dt) {
    // Có thể thêm logic di chuyển vòng tròn ở đây nếu cần.
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    // Tính toán center nếu position là Offset.zero (mặc định vẽ giữa)
    final drawCenter =
        position == Offset.zero ? size.center(Offset.zero) : position;

    canvas.drawCircle(drawCenter, radius, paint);
  }
}
