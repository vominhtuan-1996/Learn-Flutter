import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Xoay nghiêng xuống, pivot ở cạnh dưới — cảm giác "rơi".
class RotateDownTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    const double rotation = -math.pi / 4;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateZ(position * rotation),
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }
}
