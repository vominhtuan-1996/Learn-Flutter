import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

/// Xoay 3D quanh trục Y với pivot tính theo chiều rộng trang.
class ThreeDTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double height = info.height!;
    double width = info.width!;
    double pivotX = 0.0;
    if (position < 0 && position >= -1) {
      pivotX = width;
    }
    return Transform(
      transform: Matrix4.identity()
        ..rotate(vector.Vector3(0.0, 2.0, 0.0), position * 1.5),
      origin: Offset(pivotX, height / 2),
      child: child,
    );
  }
}
