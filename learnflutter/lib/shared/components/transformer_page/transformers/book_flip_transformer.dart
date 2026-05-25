import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Lật trang sách quanh cạnh trái — xoay Y với position bị clamp ở [-1, 0].
class BookFlipTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(position.clamp(-1.0, 0.0) * math.pi),
      alignment: Alignment.centerLeft,
      child: Transform.translate(
        offset: Offset(position < 0 ? width * -position : 0, 0),
        child: child,
      ),
    );
  }
}
