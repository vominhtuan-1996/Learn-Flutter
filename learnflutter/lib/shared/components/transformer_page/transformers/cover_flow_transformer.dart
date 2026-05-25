import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// CoverFlow của Apple — nghiêng + scale + dịch ngang.
class CoverFlowTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;
    double rotation = position.clamp(-1.0, 1.0) * -math.pi / 4;
    double scale = 1.0 - position.abs() * 0.2;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotation)
        ..scale(scale),
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(position * width * 0.5, 0),
        child: child,
      ),
    );
  }
}
