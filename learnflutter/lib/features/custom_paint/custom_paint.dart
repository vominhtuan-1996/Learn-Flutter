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
          ..cubicTo(
            pointsMove[i].offset!.dx + 5,
            pointsMove[i].offset!.dy + 5,
            pointsMove[i + 1].offset!.dx - 5,
            pointsMove[i + 1].offset!.dy - 5,
            pointsMove[i + 1].offset!.dx,
            pointsMove[i + 1].offset!.dy,
          );
        canvas.drawLine(pointsMove[i].offset!, pointsMove[i + 1].offset!, barPaint);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
