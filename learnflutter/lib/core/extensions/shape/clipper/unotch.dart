import 'package:flutter/material.dart';

class UNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double mid = size.width / 2;
    double depth = 36;

    Path p = Path()
      ..moveTo(0, 0)
      ..lineTo(mid - 40, 0)
      ..quadraticBezierTo(mid, depth, mid + 40, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return p;
  }

  @override
  bool shouldReclip(_) => false;
}
