import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Lật thẻ 180° quanh trục X — kiểu lật lịch.
class FlipVerticalTransformer extends PageTransformer {
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
        ..rotateX(rotation),
      alignment: Alignment.center,
      child: child,
    );
  }
}
