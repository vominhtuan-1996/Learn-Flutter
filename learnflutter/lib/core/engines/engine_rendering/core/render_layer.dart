import 'package:flutter/material.dart';

/// Lớp cơ sở cho tất cả các layer trong Render Layer Engine.
abstract class RenderLayer {
  /// Xác định layer có được hiển thị hay không.
  bool visible = true;

  /// Độ trong suốt của layer (0.0 đến 1.0).
  double opacity = 1.0;

  /// Hàm được gọi trên mỗi frame để cập nhật logic (ví dụ: animation).
  /// [dt] là delta time kể từ frame trước.
  void update(double dt);

  /// Hàm vẽ nội dung của layer lên canvas.
  /// [canvas] là đối tượng vẽ chính.
  /// [size] là kích thước không gian vẽ của render object.
  void paint(Canvas canvas, Size size);
}
