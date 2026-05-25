import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

/// Rèm sân khấu mở ra — tách nửa trái/phải khi position trong (-1, 0].
class CurtainTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position!;
    double width = info.width!;

    if (position <= 0 && position > -1) {
      return Stack(
        children: [
          ClipRect(
            clipper: _CurtainClipper(isLeft: true, position: position),
            child: Transform.translate(
              offset: Offset(width * position * 0.5, 0),
              child: child,
            ),
          ),
          ClipRect(
            clipper: _CurtainClipper(isLeft: false, position: position),
            child: Transform.translate(
              offset: Offset(-width * position * 0.5, 0),
              child: child,
            ),
          ),
        ],
      );
    }
    return child;
  }
}

class _CurtainClipper extends CustomClipper<Rect> {
  final bool isLeft;
  final double position;

  _CurtainClipper({required this.isLeft, required this.position});

  @override
  Rect getClip(Size size) {
    if (isLeft) {
      return Rect.fromLTWH(0, 0, size.width / 2, size.height);
    } else {
      return Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height);
    }
  }

  @override
  bool shouldReclip(_CurtainClipper oldClipper) => true;
}
