import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Xoay 360° + scale clamp + opacity — năng động, phá cách.
class ScaleRotateTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform.rotate(
      angle: position * math.pi * 2,
      child: Transform.scale(
        scale: 1 - position.abs().clamp(0.0, 0.5),
        child: Opacity(
          opacity: 1 - position.abs(),
          child: child,
        ),
      ),
    );
  }
}
