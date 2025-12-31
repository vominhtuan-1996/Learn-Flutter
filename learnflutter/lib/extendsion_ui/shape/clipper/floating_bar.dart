import 'dart:ui';

import 'package:flutter/material.dart';

class FloatingBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double radius = 32;
    return Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
