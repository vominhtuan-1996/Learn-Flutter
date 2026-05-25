import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Thấu kính lồi — cong ra phía người dùng.
class ConvexTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002)
        ..rotateY(position * math.pi / 2),
      alignment: position > 0 ? Alignment.centerLeft : Alignment.centerRight,
      child: child,
    );
  }
}
