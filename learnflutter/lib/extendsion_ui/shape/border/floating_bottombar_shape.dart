import 'package:flutter/material.dart';

class FloatingBottomBarShape extends ShapeBorder {
  const FloatingBottomBarShape({
    this.radius = 32,
    this.marginBottom = 16,
  });

  final double radius;
  final double marginBottom;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: marginBottom);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Rect newRect = Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right,
      rect.bottom - marginBottom, // nâng bar lên
    );

    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(newRect, Radius.circular(radius)),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return FloatingBottomBarShape(
      radius: radius * t,
      marginBottom: marginBottom * t,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    // TODO: implement getInnerPath
    throw UnimplementedError();
  }
}
