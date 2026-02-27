import 'dart:math' as math;
import 'package:flutter/material.dart';

class ArrowNotchedShape extends NotchedShape {
  final double progress; // 0 → 1, độ mở của cánh
  final double thickness;
  final double arrowSize;

  const ArrowNotchedShape({
    required this.progress,
    this.thickness = 2.5,
    this.arrowSize = 14,
  });

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    final Path path = Path();

    // Mặc định chúng ta vẽ vùng host trước
    path.addRect(host);

    // Nếu không có guest thì xem như không trừ shape
    if (guest == null) return path;

    final double cx = guest.center.dx;
    final double cy = guest.center.dy;

    final double wing = arrowSize * progress.clamp(0, 1);

    final Path arrow = Path()
      ..moveTo(cx, cy - arrowSize) // đầu mũi tên
      ..lineTo(cx, cy + arrowSize * 0.4) // thân
      ..moveTo(cx, cy + arrowSize * 0.4)
      ..lineTo(cx - wing, cy) // cánh trái
      ..moveTo(cx, cy + arrowSize * 0.4)
      ..lineTo(cx + wing, cy); // cánh phải

    // Vì NotchedShape cần subtract guest khỏi host → dùng difference
    return Path.combine(
      PathOperation.difference,
      path,
      arrow,
    );
  }
}
