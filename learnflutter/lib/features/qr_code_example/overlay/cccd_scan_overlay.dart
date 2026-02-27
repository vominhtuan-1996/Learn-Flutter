import 'package:flutter/material.dart';

class CccdScanOverlay extends StatelessWidget {
  const CccdScanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: Container(),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Tính toán tỷ lệ khung CCCD: 85.6mm x 54mm ≈ 1.58:1
    final overlayWidth = size.width * 0.85;
    final overlayHeight = overlayWidth / 1.58;

    final left = (size.width - overlayWidth) / 2;
    final top = (size.height - overlayHeight) / 2;

    final rect = Rect.fromLTWH(left, top, overlayWidth, overlayHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));

    // Vẽ khung
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
