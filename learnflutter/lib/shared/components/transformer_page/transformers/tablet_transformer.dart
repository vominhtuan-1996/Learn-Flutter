import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Lật nhẹ kiểu tablet — xoay Y góc nhỏ (π/4).
class TabletTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double rotation = position * math.pi / 4;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotation),
      alignment: Alignment.center,
      child: child,
    );
  }
}
