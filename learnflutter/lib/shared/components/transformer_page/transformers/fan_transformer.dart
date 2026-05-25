import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Bung kiểu quạt giấy — xoay Z, pivot ở góc dưới giữa.
class FanTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateZ(position * math.pi / 2),
      alignment: Alignment.bottomCenter,
      child: child,
    );
  }
}
