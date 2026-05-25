import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Bay xuyên đường hầm — scale cực mạnh + opacity, trang mới hiện từ tâm.
class TunnelTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    if (position <= 0 && position > -1) {
      return Opacity(
        opacity: 1 + position,
        child: Transform.scale(
          scale: 1 - position.abs() * 5,
          child: child,
        ),
      );
    } else if (position > 0 && position <= 1) {
      return Opacity(
        opacity: 1 - position,
        child: Transform.scale(
          scale: 0.1 + (1 - position) * 0.9,
          child: child,
        ),
      );
    }
    return child;
  }
}
