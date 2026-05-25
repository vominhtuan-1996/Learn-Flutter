import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Lật mặt trong khối lập phương — xoay Y 90°, pivot ở cạnh đối diện.
class CubeInTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double height = info.height!;
    double width = info.width!;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(position * math.pi / 2),
      origin: Offset(position <= 0 ? width : 0, height / 2),
      child: child,
    );
  }
}
