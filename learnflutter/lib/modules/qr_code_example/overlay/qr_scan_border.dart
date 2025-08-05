import 'package:flutter/material.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

class QRBorderOverlay extends StatelessWidget {
  final double scanAreaSize;
  final double borderLength;
  final double strokeWidth;
  final Color borderColor;

  const QRBorderOverlay({
    Key? key,
    this.scanAreaSize = 250,
    this.borderLength = 30,
    this.strokeWidth = 6,
    this.borderColor = Colors.greenAccent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _QRBorderOverlayPainter(
        scanAreaSize: scanAreaSize,
        borderLength: borderLength,
        strokeWidth: strokeWidth,
        borderColor: borderColor,
      ),
      size: context.mediaQuery.size,
    );
  }
}

class _QRBorderOverlayPainter extends CustomPainter {
  final double scanAreaSize;
  final double borderLength;
  final double strokeWidth;
  final Color borderColor;

  _QRBorderOverlayPainter({
    required this.scanAreaSize,
    required this.borderLength,
    required this.strokeWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scanRect = Rect.fromLTWH(
      (size.width - scanAreaSize) / 2,
      (size.height - scanAreaSize) / 2,
      scanAreaSize,
      scanAreaSize,
    );

    // 1. Vẽ nền tối và khoét vùng scan (vùng trong sáng)
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectXY(scanRect, 0, 0)); // Bo góc nhẹ

    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawPath(path, overlayPaint);

    // 2. Vẽ viền 4 góc vùng scan
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void drawCorner(Offset corner, Offset hOffset, Offset vOffset) {
      canvas.drawLine(corner, corner + hOffset, borderPaint);
      canvas.drawLine(corner, corner + vOffset, borderPaint);
    }

    drawCorner(scanRect.topLeft, Offset(borderLength, 0), Offset(0, borderLength));
    drawCorner(scanRect.topRight, Offset(-borderLength, 0), Offset(0, borderLength));
    drawCorner(scanRect.bottomLeft, Offset(borderLength, 0), Offset(0, -borderLength));
    drawCorner(scanRect.bottomRight, Offset(-borderLength, 0), Offset(0, -borderLength));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
