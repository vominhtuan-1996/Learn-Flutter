import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArrowElasticShape extends ShapeBorder {
  /// progress kéo từ 0 → >1
  final double progress;

  /// độ rộng cánh arrow
  final double baseWidth;

  /// độ dài arrow (phần thẳng)
  final double arrowLength;

  /// độ giãn tối đa khi kéo quá
  final double elasticFactor;

  const ArrowElasticShape({
    required this.progress,
    this.baseWidth = 18,
    this.arrowLength = 16,
    this.elasticFactor = 20,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    // điểm giữa
    final centerX = width / 2;

    // độ giãn khi progress > 1
    final extra = progress > 1 ? (progress - 1) * elasticFactor : 0;

    // scale chung (arrow lớn dần khi kéo)
    final scale = Curves.easeOut.transform(math.min(progress, 1));

    final halfBase = baseWidth * scale;
    final len = arrowLength * scale + extra;

    final Path path = Path();

    final double cx = centerX;
    final double cy = height / 2;

    // Điểm đầu arrow (trên)
    final double topY = cy - len / 2;

    // Điểm cuối arrow (nhọn, dưới)
    final double tipY = cy + len / 2 + extra;

    // Left wing
    final leftWing = Offset(cx - halfBase, topY + arrowLength * .4);

    // Right wing
    final rightWing = Offset(cx + halfBase, topY + arrowLength * .4);

    // Bắt đầu vẽ path shape
    path.moveTo(cx, topY); // đỉnh mũi tên trên
    path.lineTo(leftWing.dx, leftWing.dy);
    path.lineTo(cx, tipY); // đáy nhọn
    path.lineTo(rightWing.dx, rightWing.dy);
    path.close();

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    // TODO: implement getInnerPath
    throw UnimplementedError();
  }
}
