import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Parallax — nội dung dịch với một nửa tốc độ trang.
class ParallaxTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;
    if (position >= -1 && position <= 1) {
      return Transform.translate(
        offset: Offset(position * width / 2, 0),
        child: child,
      );
    }
    return child;
  }
}
