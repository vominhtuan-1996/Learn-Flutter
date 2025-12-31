import 'package:flutter/material.dart';

class DiamondNotchedRectangle extends NotchedShape {
  const DiamondNotchedRectangle({this.size = 18});

  /// size = độ lớn mỗi cạnh của kim cương
  final double size;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final double notchCenterX = guest.center.dx;
    final double top = host.top;

    final double half = size;
    final double leftPointX = notchCenterX - half;
    final double rightPointX = notchCenterX + half;

    final double midTopY = top; // điểm trên
    final double midBottomY = top + half; // điểm dưới (đáy kim cương)

    Path path = Path();

    // Bắt đầu từ trái
    path.moveTo(host.left, host.top);

    // Đường tới cạnh trái diamond
    path.lineTo(leftPointX, midTopY);

    // Diamond top → đáy
    path.lineTo(notchCenterX, midBottomY);

    // Đáy → cạnh phải
    path.lineTo(rightPointX, midTopY);

    // Tiếp tục vẽ tới mép phải
    path.lineTo(host.right, host.top);

    // Xuống bottom và đóng shape
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();

    return path;
  }
}
