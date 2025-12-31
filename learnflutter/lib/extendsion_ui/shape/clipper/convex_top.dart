import 'package:flutter/material.dart';

class ConvexTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 20)
      ..quadraticBezierTo(size.width / 2, -30, size.width, 20)
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
