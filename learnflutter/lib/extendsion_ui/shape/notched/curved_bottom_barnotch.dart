import 'dart:math' as math;
import 'package:flutter/material.dart';

class CurvedBottomBarNotch extends NotchedShape {
  const CurvedBottomBarNotch();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    // Nếu không có fab → trả rect bình thường
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final double fabRadius = guest.width / 2;
    final double notchRadius = fabRadius + 8;

    final double s1 = 15; // độ cong trái
    final double s2 = 15; // độ cong phải

    final Path path = Path();
    path.moveTo(host.left, host.top);

    // Bo cong trái
    path.quadraticBezierTo(
      host.left + s1,
      host.top,
      host.left + s1 * 2,
      host.top,
    );

    final double fabX = guest.center.dx;
    final double fabY = guest.center.dy;

    // Vẽ notch cong mềm quanh FAB
    path.arcToPoint(
      Offset(fabX - notchRadius, host.top),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.arcToPoint(
      Offset(fabX + notchRadius, host.top),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Bo cong phải
    path.quadraticBezierTo(
      host.right - s2,
      host.top,
      host.right,
      host.top,
    );

    // Xuống bottom và đóng shape
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();

    return path;
  }
}
