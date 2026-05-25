// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';

class CustomRectTween extends RectTween {
  final Rect? begin;
  final Rect? end;

  CustomRectTween({this.begin, this.end}) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    double x = Curves.easeOutCirc.transform(t);

    return Rect.fromLTRB(
      lerpDouble(begin!.left, end!.left, t),
      lerpDouble(begin!.top, end!.top, t),
      lerpDouble(begin!.right, end!.right, t) * (1 + x),
      lerpDouble(begin!.bottom, end!.bottom, t) * (1 + x),
    );
  }

  double lerpDouble(num begin, num end, double t) {
    return begin + (end - begin) * t;
  }
}
