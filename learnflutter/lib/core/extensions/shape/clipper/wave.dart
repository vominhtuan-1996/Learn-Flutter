import 'package:flutter/material.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path()..moveTo(0, 0);

    path.quadraticBezierTo(
      size.width * .25,
      30,
      size.width * .5,
      20,
    );

    path.quadraticBezierTo(
      size.width * .75,
      10,
      size.width,
      30,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    return path..close();
  }

  @override
  bool shouldReclip(_) => false;
}
