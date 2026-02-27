import 'package:flutter/material.dart';

class BottomNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double notchRadius = 28;
    const double notchWidth = 80;
    final center = size.width / 2;

    Path path = Path()
      ..moveTo(0, 20)
      ..quadraticBezierTo(0, 0, 20, 0)
      ..lineTo(center - notchWidth / 2, 0)
      // ..cubicTo(
      //   center - notchRadius,
      //   0,
      //   center - notchRadius,
      //   40,
      //   center,
      //   40,
      // )
      // ..cubicTo(
      //   center + notchRadius,
      //   40,
      //   center + notchRadius,
      //   0,
      //   center + notchWidth / 2,
      //   0,
      // )
      ..lineTo(size.width - 20, 0)
      ..quadraticBezierTo(size.width, 0, size.width, 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
