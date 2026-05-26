import 'package:flutter/material.dart';
import 'render_layer_controller.dart';

/// Lớp đại diện cho Render Pipeline, cho phép cấu hình và điều phối vòng đời của layer engine.
class RenderPipeline {
  final RenderLayerController controller;

  RenderPipeline({required this.controller});

  /// Chạy luồng update -> layout -> paint -> composite
  /// Trong mô hình custom rendering qua Canvas, pipeline cơ bản sẽ như sau:
  void execute(double dt, Canvas canvas, Size size) {
    // 1. Update
    _update(dt);

    // 2. Layout (nếu các layer có logic tự tính toán size riêng, hiện tại dùng size chung của box)
    _layout(size);

    // 3. Paint & Composite (đẩy vào controller thực hiện)
    _paint(canvas, size);
  }

  void _update(double dt) {
    controller.update(dt);
  }

  void _layout(Size size) {
    // Tương lai có thể duyệt qua các layer để phân bổ layout, tương tự performLayout của RenderBox.
  }

  void _paint(Canvas canvas, Size size) {
    // Controller sẽ lo việc composite các layer (sắp xếp lớp và alpha blend)
    controller.paint(canvas, size);
  }
}
