import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Trang cũ đứng yên, trang mới trượt đè lên — phong cách thẻ bài xếp chồng.
class StackTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position <= 0) {
      return Transform.translate(
        offset: Offset(-info.width! * position, 0),
        child: child,
      );
    }
    return child;
  }
}
