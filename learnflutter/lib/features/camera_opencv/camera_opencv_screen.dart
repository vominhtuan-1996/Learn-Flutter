import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

/// Real-time camera preview with OpenCV contour-based focus rectangle.
///
/// Pipeline (per frame, throttled to ~10 fps):
///   CameraImage (YUV420 / BGRA8888) → grayscale Mat
///   → GaussianBlur → Canny edges → findContours
///   → largest contour → boundingRect
///   → CustomPainter overlay (animated corner brackets)
class CameraOpenCVScreen extends StatefulWidget {
  const CameraOpenCVScreen({super.key});

  @override
  State<CameraOpenCVScreen> createState() => _CameraOpenCVScreenState();
}

class _CameraOpenCVScreenState extends State<CameraOpenCVScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _ctrl;
  bool _ready = false;
  String _error = '';

  // Focus rect in image coordinates (0..1 normalized)
  Rect? _focusRect;
  bool _processing = false;
  int _frameCount = 0;
  static const _processEveryN = 6; // ~10 fps at 60fps stream

  late final AnimationController _animCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() => _error = 'Không tìm thấy camera.');
      return;
    }
    final ctrl = CameraController(
      cameras.first,
      ResolutionPreset.medium, // 640×480-ish — đủ cho OpenCV, tiết kiệm memory
      enableAudio: false,
      imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
    );
    await ctrl.initialize();
    if (!mounted) return;
    _ctrl = ctrl;
    await ctrl.startImageStream(_onFrame);
    setState(() => _ready = true);
  }

  void _onFrame(CameraImage image) {
    _frameCount++;
    if (_frameCount % _processEveryN != 0) return;
    if (_processing) return;
    _processing = true;
    // Run on same isolate — OpenCV ops here are fast (<5ms on medium res)
    try {
      final rect = _detectObject(image);
      if (mounted) setState(() => _focusRect = rect);
    } catch (_) {
      // ignore frame errors
    } finally {
      _processing = false;
    }
  }

  /// Returns normalized Rect (0..1) of largest object, or null.
  static Rect? _detectObject(CameraImage image) {
    final gray = _toGray(image);
    if (gray == null) return null;

    final blurred = cv.gaussianBlur(gray, (5, 5), 0);
    gray.dispose();
    final edges = cv.canny(blurred, 30, 100);
    blurred.dispose();

    final (contours, hierarchy) = cv.findContours(edges, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
    edges.dispose();
    hierarchy.dispose();

    if (contours.length == 0) { contours.dispose(); return null; }

    // Find largest contour by area
    double maxArea = 0;
    int maxIdx = 0;
    for (int i = 0; i < contours.length; i++) {
      final area = cv.contourArea(contours[i]);
      if (area > maxArea) { maxArea = area; maxIdx = i; }
    }

    final minArea = image.width * image.height * 0.005; // ignore tiny noise (<0.5%)
    if (maxArea < minArea) { contours.dispose(); return null; }

    final br = cv.boundingRect(contours[maxIdx]);
    contours.dispose();

    final iw = image.width.toDouble();
    final ih = image.height.toDouble();
    return Rect.fromLTWH(br.x / iw, br.y / ih, br.width / iw, br.height / ih);
  }

  static cv.Mat? _toGray(CameraImage image) {
    try {
      if (Platform.isIOS) {
        // BGRA8888 — plane 0 has all 4 channels interleaved
        final plane = image.planes[0];
        final mat = cv.Mat.fromList(
          image.height, image.width,
          cv.MatType.CV_8UC4,
          plane.bytes,
        );
        final gray = cv.cvtColor(mat, cv.COLOR_BGRA2GRAY);
        mat.dispose();
        return gray;
      } else {
        // YUV420 — plane 0 is the Y (luma) channel = grayscale directly
        final yPlane = image.planes[0];
        final bytes = yPlane.bytes;
        final rowStride = yPlane.bytesPerRow;
        // If rowStride == width, use directly; else strip padding
        if (rowStride == image.width) {
          return cv.Mat.fromList(image.height, image.width, cv.MatType.CV_8UC1, bytes);
        }
        // Strip row padding
        final compact = Uint8List(image.width * image.height);
        for (int r = 0; r < image.height; r++) {
          compact.setRange(r * image.width, (r + 1) * image.width, bytes, r * rowStride);
        }
        return cv.Mat.fromList(image.height, image.width, cv.MatType.CV_8UC1, compact);
      }
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _ctrl?.stopImageStream();
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('OpenCV Focus'),
      ),
      body: _error.isNotEmpty
          ? Center(child: Text(_error, style: const TextStyle(color: Colors.white)))
          : !_ready
              ? const Center(child: CircularProgressIndicator())
              : Stack(children: [
                  // Camera preview fills screen
                  Positioned.fill(child: CameraPreview(_ctrl!)),
                  // OpenCV overlay
                  if (_focusRect != null)
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (_, __) => CustomPaint(
                          painter: _FocusPainter(_focusRect!, _pulse.value),
                        ),
                      ),
                    ),
                  // Info badge
                  Positioned(
                    left: 0, right: 0, bottom: 40,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _focusRect != null
                              ? 'Object detected — ${(_focusRect!.width * 100).toStringAsFixed(0)}% × ${(_focusRect!.height * 100).toStringAsFixed(0)}%'
                              : 'Scanning...',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ]),
    );
  }
}

/// Draws corner brackets around the detected object bounding rect.
class _FocusPainter extends CustomPainter {
  const _FocusPainter(this.normRect, this.pulse);
  final Rect normRect;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    // Map normalized rect to screen coords
    final rect = Rect.fromLTWH(
      normRect.left * size.width,
      normRect.top * size.height,
      normRect.width * size.width,
      normRect.height * size.height,
    );

    final cornerLen = (rect.shortestSide * 0.18).clamp(16.0, 48.0);
    final strokeW = 2.5 * pulse;

    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.85 * pulse)
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dim overlay inside focus area
    canvas.drawRect(
      rect,
      Paint()..color = Colors.greenAccent.withOpacity(0.05 * pulse),
    );

    // Four corner brackets
    _drawCorner(canvas, paint, rect.topLeft, cornerLen, 1, 1);
    _drawCorner(canvas, paint, rect.topRight, cornerLen, -1, 1);
    _drawCorner(canvas, paint, rect.bottomLeft, cornerLen, 1, -1);
    _drawCorner(canvas, paint, rect.bottomRight, cornerLen, -1, -1);
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset corner, double len, double dx, double dy) {
    canvas.drawLine(corner, corner + Offset(len * dx, 0), paint);
    canvas.drawLine(corner, corner + Offset(0, len * dy), paint);
  }

  @override
  bool shouldRepaint(_FocusPainter old) =>
      old.normRect != normRect || old.pulse != pulse;
}
