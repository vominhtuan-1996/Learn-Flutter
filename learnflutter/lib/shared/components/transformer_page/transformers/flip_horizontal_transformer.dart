import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Lật thẻ 180° quanh trục Y — ẩn mặt sau khi rotation vượt 90°.
class FlipHorizontalTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double rotation = position * math.pi;

    if (rotation > math.pi / 2 || rotation < -math.pi / 2) {
      return Container();
    }

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotation),
      alignment: Alignment.center,
      child: child,
    );
  }
}
