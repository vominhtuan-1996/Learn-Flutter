import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Phóng to trang mới khi tiến vào vùng hiển thị — kết hợp translate + scale.
class ZoomInPageTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;
    if (position > 0 && position <= 1) {
      return Transform.translate(
        offset: Offset(-width * position, 0.0),
        child: Transform.scale(
          scale: 1 - position,
          child: child,
        ),
      );
    }
    return child;
  }
}
