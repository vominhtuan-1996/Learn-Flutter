import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Trượt + cắt (clip) — trang mới wipe vào theo cạnh.
class WipeTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;
    if (position <= 0) {
      return child;
    } else {
      return ClipRect(
        child: Transform.translate(
          offset: Offset(width * (1 - position), 0),
          child: child,
        ),
      );
    }
  }
}
