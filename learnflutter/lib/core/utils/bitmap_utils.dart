import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Lớp tiện ích để tạo và xử lý hình ảnh bitmap từ text và các phần tử vẽ tùy chỉnh.
/// BitmapUtils cung cấp khả năng tạo hình ảnh PNG từ text và các CustomPainter, hữu ích cho việc tạo marker trên bản đồ hoặc các hình ảnh động.
class BitmapUtils {
  /// Tạo hình ảnh PNG dưới dạng Uint8List từ text.
  /// Phương thức này kết hợp text với các phần tử vẽ tùy chỉnh để tạo ra một hình ảnh hoàn chỉnh.
  Future<Uint8List> generateImagePngAsBytes(String text) async {
    ByteData? image = await generateSquareWithText(text);
    return image!.buffer.asUint8List();
  }

  /// Tạo một hình vuông chứa text và các phần tử vẽ tùy chỉnh.
  /// Sử dụng Canvas để vẽ hình chữ nhật, text và các CustomPainter, sau đó chuyển đổi thành ByteData.
  Future<ByteData?> generateSquareWithText(String text) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0.0, 0.0), const Offset(300.0, 100.0)));

    final stroke = Paint()
      ..color = Colors.grey
      ..colorFilter = const ui.ColorFilter.linearToSrgbGamma()
      ..style = PaintingStyle.stroke;

    canvas.drawRect(const Rect.fromLTWH(0.0, 0.0, 100.0, 100.0), stroke);
    final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainter.layout();

    final textPainterABC = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
    textPainterABC.layout();

    MyCustomPainter().paint(canvas, const Size(100, 100));
    textPainter.paint(canvas, const Offset(110, 0));
    textPainterABC.paint(canvas, const Offset(110, 80));

    final picture = recorder.endRecording();
    ui.Image img = await picture.toImage(100, 100);
    final ByteData? pngBytes =
        await img.toByteData(format: ImageByteFormat.png);
    return pngBytes;
  }
}

/// CustomPainter vẽ bầu trời với gradient xuyên tâm.
/// Sử dụng RadialGradient để tạo hiệu ứng chuyển màu từ trung tâm ra ngoài, phù hợp cho background hoặc các hiệu ứng đặc biệt.
class Sky extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const RadialGradient gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.5,
      colors: <Color>[Color(0xFFddFF00), Color(0xFF0099FF)],
      stops: <double>[0.4, 1.0],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder {
    return (Size size) {
      Rect rect = Offset.zero & size;
      final double width = size.shortestSide * 0.4;
      rect = const Alignment(0.8, -0.9).inscribe(Size(width, width), rect);
      return <CustomPainterSemantics>[
        CustomPainterSemantics(
          rect: rect,
          properties: const SemanticsProperties(
            label: 'Sun',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
    };
  }

  @override
  bool shouldRepaint(Sky oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(Sky oldDelegate) => false;
}

/// CustomPainter đơn giản vẽ một hình chữ nhật màu xanh.
/// Đây là ví dụ cơ bản về cách sử dụng CustomPainter để vẽ các hình dạng tùy chỉnh.
class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
