import 'package:flutter/material.dart';

class PointDrag {
  PointDrag();
  Offset? offset;
  bool? isMove;
  Color? color;
  double? strokeWidth;
}

class DragWidgetPainter extends CustomPainter {
  DragWidgetPainter({
    required this.pointsMove,
    required this.isMove,
  });
  final List<PointDrag> pointsMove;
  final bool isMove;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save(); // var point1 = pointsMove.isNotEmpty ? pointsMove.first : Offset.zero;
    for (int i = 0; i < pointsMove.length - 1; i++) {
      final barPaint = Paint()
        ..color = pointsMove[i].color ?? Colors.red
        ..style = PaintingStyle.fill
        ..strokeJoin = StrokeJoin.round
        ..blendMode = BlendMode.srcOver
        ..strokeWidth = pointsMove[i].strokeWidth ?? 3
        ..isAntiAlias = true;
      if (pointsMove[i].isMove == true) {
        final path = Path()
          ..moveTo(pointsMove[i].offset!.dx + 5, pointsMove[i].offset!.dy + 5)
          ..lineTo(pointsMove[i + 1].offset!.dx + 5, pointsMove[i].offset!.dy + 5);
        canvas.drawShadow(path, Colors.grey, 2.0, false);
        canvas.drawLine(pointsMove[i].offset!, pointsMove[i + 1].offset!, barPaint);
      }
    }
    // for (var element in pointsMove) {
    //   canvas.drawLine(point1, element, barPaint);
    //   point1 = element;
    // }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
