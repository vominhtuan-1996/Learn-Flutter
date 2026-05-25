import 'dart:math' as math;
import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Thu nhỏ + làm mờ trang khi rời tâm — gợi cảm giác lùi vào hậu cảnh.
class ZoomOutPageTransformer extends PageTransformer {
  static const double minScale = 0.85;
  static const double minAlpha = 0.5;

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double pageWidth = info.width!;
    double pageHeight = info.height!;

    if (position < -1) {
      return child;
    } else if (position <= 1) {
      double scaleFactor = math.max(minScale, 1 - position.abs());
      double vertMargin = pageHeight * (1 - scaleFactor) / 2;
      double horzMargin = pageWidth * (1 - scaleFactor) / 2;
      double dx;
      if (position < 0) {
        dx = (horzMargin - vertMargin / 2);
      } else {
        dx = (-horzMargin + vertMargin / 2);
      }
      double opacity =
          minAlpha + (scaleFactor - minScale) / (1 - minScale) * (1 - minAlpha);

      return Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(dx, 0.0),
          child: Transform.scale(
            scale: scaleFactor,
            child: child,
          ),
        ),
      );
    }
    return child;
  }
}
