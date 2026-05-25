import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Scale + opacity kết hợp — mượt, không gây mỏi mắt.
class ScaleAndFadeTransformer extends PageTransformer {
  final double scale;
  final double fade;

  ScaleAndFadeTransformer({this.fade = 0.3, this.scale = 0.8});

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double scaleFactor = (1 - position.abs()) * (1 - scale);
    double fadeFactor = (1 - position.abs()) * (1 - fade);
    double opacity = fade + fadeFactor;
    double scaleVal = scale + scaleFactor;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scaleVal,
        child: child,
      ),
    );
  }
}
