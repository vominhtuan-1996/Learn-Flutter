import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Xoay tròn 360° + scale + opacity — như đĩa nhạc.
class SpinTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform.rotate(
      angle: position * math.pi * 2,
      child: Transform.scale(
        scale: 1 - position.abs(),
        child: Opacity(
          opacity: 1 - position.abs(),
          child: child,
        ),
      ),
    );
  }
}
