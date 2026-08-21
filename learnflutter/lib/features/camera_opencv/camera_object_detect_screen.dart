// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

/// Reference-based size measurement.
///
/// Step 1 — Reference mode:
///   Point camera at a known product (e.g., Danh thiếp 90×55mm).
///   ONNX classifies it → tap "Đặt làm chuẩn" → stores px/mm ratio.
///
/// Step 2 — Measure mode:
///   Point at any object. OpenCV finds all significant contours.
///   Each contour's bbox is converted from px → mm using stored ratio.
///   Overlay shows width × height in mm for each detected region.
///
/// Known product sizes (mm):
///   Tờ rơi A5          148 × 210
///   Móc treo chìa khoá  40 × 80  (approx)
///   Decan - Sticker     100 × 100 (approx)
///   Danh thiếp           90 × 55
///   Catalogue - In ấn   210 × 297
class CameraObjectDetectScreen extends StatefulWidget {
  const CameraObjectDetectScreen({super.key});

  @override
  State<CameraObjectDetectScreen> createState() => _CameraObjectDetectScreenState();
}

// ── Known real-world sizes (width × height, mm) ───────────────────────────
const Map<String, (double, double)> _kSizes = {
  'Tờ rơi A5':          (148.0, 210.0),
  'Móc treo chìa khoá': (40.0,  80.0),
  'Decan - Sticker':    (100.0, 100.0),
  'Danh thiếp':         (90.0,  55.0),
  'Catalogue - In ấn':  (210.0, 297.0),
};

enum _Mode { reference, measure }

class _MeasuredBox {
  const _MeasuredBox(this.normRect, this.widthMm, this.heightMm);
  final Rect normRect;   // normalized 0..1
  final double widthMm;
  final double heightMm;
}

class _CameraObjectDetectScreenState extends State<CameraObjectDetectScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _ctrl;
  OrtSession? _session;
  List<String> _labels = [];

  bool _ready = false;
  String _error = '';
  bool _processing = false;
  int _frameCount = 0;
  static const _processEveryN = 4;

  // Reference mode state
  _Mode _mode = _Mode.reference;
  Rect? _focusRect;           // normalized, largest contour
  String _topLabel = '';
  double _topScore = 0;

  // Measure mode state
  double? _pxPerMm;           // calibration: camera-image pixels per mm
  String _refLabel = '';
  List<_MeasuredBox> _measuredBoxes = [];

  // Raw camera image size (needed for px→mm)
  int _camW = 1, _camH = 1;

  late final AnimationController _animCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
    _init();
  }

  Future<void> _init() async {
    try {
      await _loadModel();
      await _initCamera();
    } catch (e) {
      if (mounted) setState(() => _error = 'Init error: $e');
    }
  }

  Future<void> _loadModel() async {
    OrtEnv.instance.init();
    final bytes = await rootBundle.load('assets/models/detector.onnx');
    _session = OrtSession.fromBuffer(bytes.buffer.asUint8List(), OrtSessionOptions());
    final raw = await rootBundle.loadString('assets/models/labels.txt');
    _labels = raw.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw 'No camera';
    final ctrl = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
    );
    await ctrl.initialize();
    if (!mounted) return;
    _ctrl = ctrl;
    await ctrl.startImageStream(_onFrame);
    if (mounted) setState(() => _ready = true);
  }

  // ── Frame processing ────────────────────────────────────────────────────

  void _onFrame(CameraImage image) {
    _frameCount++;
    if (_frameCount % _processEveryN != 0) return;
    if (_processing) return;
    _processing = true;
    _camW = image.width;
    _camH = image.height;

    try {
      final gray = _toGray(image);
      if (gray == null) { _processing = false; return; }

      if (_mode == _Mode.reference) {
        _processReference(gray, image);
      } else {
        _processMeasure(gray);
      }
      gray.dispose();
    } catch (_) {
      // ignore frame error
    } finally {
      _processing = false;
    }
  }

  /// Reference mode: find largest contour, classify with ONNX.
  void _processReference(cv.Mat gray, CameraImage image) {
    final blurred = cv.gaussianBlur(gray, (5, 5), 0);
    final edges = cv.canny(blurred, 30, 100);
    blurred.dispose();

    final (contours, hierarchy) = cv.findContours(edges, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
    edges.dispose();
    hierarchy.dispose();

    cv.Rect? bestBr;
    if (contours.length > 0) {
      double maxArea = 0; int maxIdx = 0;
      for (int i = 0; i < contours.length; i++) {
        final a = cv.contourArea(contours[i]);
        if (a > maxArea) { maxArea = a; maxIdx = i; }
      }
      if (maxArea >= image.width * image.height * 0.01) {
        bestBr = cv.boundingRect(contours[maxIdx]);
      }
    }
    contours.dispose();

    final focusRect = bestBr == null ? null : Rect.fromLTWH(
      bestBr.x / image.width, bestBr.y / image.height,
      bestBr.width / image.width, bestBr.height / image.height,
    );

    // ONNX classify crop
    String label = ''; double score = 0;
    if (bestBr != null) {
      final crop = _safeCrop(gray, bestBr);
      final resized = cv.resize(crop, (96, 96));
      crop.dispose();
      (label, score) = _runOnnx(resized);
      resized.dispose();
    }

    if (mounted) setState(() {
      _focusRect = focusRect;
      _topLabel = label;
      _topScore = score;
      // Auto-store calibration if confidence high enough
      if (score > 0.65 && bestBr != null && _kSizes.containsKey(label)) {
        _pendingBr = bestBr;
        _pendingLabel = label;
      } else {
        _pendingBr = null;
        _pendingLabel = '';
      }
    });
  }

  cv.Rect? _pendingBr;
  String _pendingLabel = '';

  /// Tap "Đặt làm chuẩn" — compute px/mm from current detection.
  void _setReference() {
    final br = _pendingBr;
    final label = _pendingLabel;
    if (br == null || label.isEmpty) return;
    final size = _kSizes[label]!;
    // Use longer dimension to longer side → handles portrait/landscape
    final pxLong = max(br.width, br.height).toDouble();
    final mmLong = max(size.$1, size.$2);
    final pxPerMm = pxLong / mmLong;
    setState(() {
      _pxPerMm = pxPerMm;
      _refLabel = label;
      _mode = _Mode.measure;
      _measuredBoxes = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ Chuẩn: $label — ${pxPerMm.toStringAsFixed(2)} px/mm'),
      duration: const Duration(seconds: 2),
    ));
  }

  /// Measure mode: find all significant contours, compute mm dimensions.
  void _processMeasure(cv.Mat gray) {
    final pxPerMm = _pxPerMm;
    if (pxPerMm == null) return;

    final blurred = cv.gaussianBlur(gray, (5, 5), 0);
    final edges = cv.canny(blurred, 30, 100);
    blurred.dispose();

    // Dilate to merge nearby edges → cleaner object boundaries
    final kernel = cv.getStructuringElement(cv.MORPH_RECT, (3, 3));
    final dilated = cv.dilate(edges, kernel);
    edges.dispose();
    kernel.dispose();

    final (contours, hierarchy) = cv.findContours(dilated, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
    dilated.dispose();
    hierarchy.dispose();

    final minPx = _camW * _camH * 0.005; // ignore noise < 0.5% of frame
    final boxes = <_MeasuredBox>[];

    for (int i = 0; i < contours.length; i++) {
      if (cv.contourArea(contours[i]) < minPx) continue;
      final br = cv.boundingRect(contours[i]);
      boxes.add(_MeasuredBox(
        Rect.fromLTWH(br.x / _camW, br.y / _camH, br.width / _camW, br.height / _camH),
        br.width / pxPerMm,
        br.height / pxPerMm,
      ));
    }
    contours.dispose();

    // Sort by area desc, keep top 5
    boxes.sort((a, b) => (b.normRect.width * b.normRect.height)
        .compareTo(a.normRect.width * a.normRect.height));

    if (mounted) setState(() => _measuredBoxes = boxes.take(5).toList());
  }

  // ── ONNX inference ───────────────────────────────────────────────────────

  (String, double) _runOnnx(cv.Mat gray96) {
    final input = Int8List(96 * 96);
    int idx = 0;
    for (int r = 0; r < 96; r++)
      for (int c = 0; c < 96; c++)
        input[idx++] = (gray96.at<int>(r, c) - 128);

    final tensor = OrtValueTensor.createTensorWithDataList(input, [1, 96, 96, 1]);
    final runOpts = OrtRunOptions();
    final outputs = _session!.run(runOpts, {_session!.inputNames.first: tensor});
    tensor.release();
    runOpts.release();

    final rawValue = outputs.first?.value;
    for (final o in outputs) o?.release();
    if (rawValue == null) return ('', 0.0);

    final List<num> scores = (rawValue is List && rawValue.first is List)
        ? (rawValue.first as List).cast<num>()
        : (rawValue as List).cast<num>();

    double maxV = scores.first.toDouble();
    int maxIdx = 0;
    for (int i = 1; i < scores.length; i++) {
      if (scores[i].toDouble() > maxV) { maxV = scores[i].toDouble(); maxIdx = i; }
    }

    // Softmax probability
    final expVals = scores.map((s) {
      final v = s.toDouble() - maxV;
      return v < -30 ? 0.0 : exp(v);
    }).toList();
    final prob = expVals[maxIdx] / expVals.reduce((a, b) => a + b);

    final label = maxIdx < _labels.length ? _labels[maxIdx] : 'class $maxIdx';
    return (label, prob);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static cv.Mat _safeCrop(cv.Mat src, cv.Rect br) {
    final x = br.x.clamp(0, src.cols - 1);
    final y = br.y.clamp(0, src.rows - 1);
    final w = br.width.clamp(1, src.cols - x);
    final h = br.height.clamp(1, src.rows - y);
    return src.region(cv.Rect(x, y, w, h));
  }

  static cv.Mat? _toGray(CameraImage image) {
    try {
      if (Platform.isIOS) {
        final mat = cv.Mat.fromList(image.height, image.width, cv.MatType.CV_8UC4, image.planes[0].bytes);
        final g = cv.cvtColor(mat, cv.COLOR_BGRA2GRAY);
        mat.dispose();
        return g;
      }
      final yP = image.planes[0];
      if (yP.bytesPerRow == image.width) {
        return cv.Mat.fromList(image.height, image.width, cv.MatType.CV_8UC1, yP.bytes);
      }
      final compact = Uint8List(image.width * image.height);
      for (int r = 0; r < image.height; r++)
        compact.setRange(r * image.width, (r + 1) * image.width, yP.bytes, r * yP.bytesPerRow);
      return cv.Mat.fromList(image.height, image.width, cv.MatType.CV_8UC1, compact);
    } catch (_) { return null; }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _ctrl?.stopImageStream();
    _ctrl?.dispose();
    _session?.release();
    OrtEnv.instance.release();
    super.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: Text(_mode == _Mode.reference ? '📐 Chọn vật chuẩn' : '📏 Đo kích thước'),
        actions: [
          if (_mode == _Mode.measure)
            TextButton(
              onPressed: () => setState(() { _mode = _Mode.reference; _measuredBoxes = []; }),
              child: const Text('Đặt lại', style: TextStyle(color: Colors.orangeAccent)),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: const TextStyle(color: Colors.redAccent)));
    }
    if (!_ready) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Đang tải model...', style: TextStyle(color: Colors.white70)),
      ]));
    }

    return Stack(children: [
      Positioned.fill(child: CameraPreview(_ctrl!)),

      // ── Reference mode overlay ──
      if (_mode == _Mode.reference) ...[
        if (_focusRect != null)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => CustomPaint(
                painter: _RefPainter(
                  rect: _focusRect!,
                  pulse: _pulse.value,
                  label: _topLabel,
                  score: _topScore,
                  isKnown: _kSizes.containsKey(_topLabel),
                ),
              ),
            ),
          ),
        // Known size info panel
        if (_pendingLabel.isNotEmpty) _buildRefInfoPanel(),
        // Scanning hint
        if (_pendingLabel.isEmpty)
          Positioned(
            left: 0, right: 0, bottom: 48,
            child: Center(child: _Badge('Hướng camera vào vật thể cần chuẩn', Colors.white54)),
          ),
      ],

      // ── Measure mode overlay ──
      if (_mode == _Mode.measure) ...[
        if (_measuredBoxes.isNotEmpty)
          Positioned.fill(child: CustomPaint(painter: _MeasurePainter(_measuredBoxes))),
        Positioned(
          left: 0, right: 0, bottom: 48,
          child: Center(child: _Badge('Chuẩn: $_refLabel  |  ${_pxPerMm!.toStringAsFixed(2)} px/mm', Colors.teal)),
        ),
      ],
    ]);
  }

  Widget _buildRefInfoPanel() {
    final label = _pendingLabel;
    final size = _kSizes[label]!;
    return Positioned(
      left: 16, right: 16, bottom: 32,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.7)),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                  '${size.$1.toStringAsFixed(0)} × ${size.$2.toStringAsFixed(0)} mm  |  ${(_topScore * 100).toStringAsFixed(0)}% confidence',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ]),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
              onPressed: _setReference,
              child: const Text('Đặt làm chuẩn'),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.75),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: color.withOpacity(0.6)),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
  );
}

// ── Painters ─────────────────────────────────────────────────────────────

/// Reference mode: corner brackets + label badge.
class _RefPainter extends CustomPainter {
  const _RefPainter({required this.rect, required this.pulse,
      required this.label, required this.score, required this.isKnown});
  final Rect rect;
  final double pulse;
  final String label;
  final double score;
  final bool isKnown;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(rect.left * size.width, rect.top * size.height,
        rect.width * size.width, rect.height * size.height);
    final color = isKnown ? Colors.greenAccent : Colors.white70;
    final len = (r.shortestSide * 0.16).clamp(14.0, 48.0);
    final p = Paint()
      ..color = color.withOpacity(0.9 * pulse)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawRect(r, Paint()..color = color.withOpacity(0.06 * pulse));
    _c(canvas, p, r.topLeft,     len,  1,  1);
    _c(canvas, p, r.topRight,    len, -1,  1);
    _c(canvas, p, r.bottomLeft,  len,  1, -1);
    _c(canvas, p, r.bottomRight, len, -1, -1);

    if (label.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: ' $label ${(score * 100).toStringAsFixed(0)}% ',
          style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold,
              background: Paint()..color = color.withOpacity(0.9)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(r.left + 2, r.top - tp.height - 4));
    }
  }

  void _c(Canvas c, Paint p, Offset o, double l, double dx, double dy) {
    c.drawLine(o, o + Offset(l * dx, 0), p);
    c.drawLine(o, o + Offset(0, l * dy), p);
  }

  @override
  bool shouldRepaint(_RefPainter o) => o.rect != rect || o.pulse != pulse || o.label != label;
}

/// Measure mode: colored boxes with mm dimensions.
class _MeasurePainter extends CustomPainter {
  const _MeasurePainter(this.boxes);
  final List<_MeasuredBox> boxes;

  static const _colors = [
    Color(0xFF34D399), Color(0xFF60A5FA), Color(0xFFFBBF24),
    Color(0xFFF87171), Color(0xFFA78BFA),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < boxes.length; i++) {
      final b = boxes[i];
      final color = _colors[i % _colors.length];
      final r = Rect.fromLTWH(b.normRect.left * size.width, b.normRect.top * size.height,
          b.normRect.width * size.width, b.normRect.height * size.height);

      // Box
      canvas.drawRect(r, Paint()..color = color.withOpacity(0.15));
      canvas.drawRect(r, Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke);

      // Width dimension line (bottom of box)
      _drawDimension(canvas, color,
        Offset(r.left, r.bottom + 10), Offset(r.right, r.bottom + 10),
        '${b.widthMm.toStringAsFixed(1)} mm',
      );

      // Height dimension line (right of box)
      _drawDimension(canvas, color,
        Offset(r.right + 10, r.top), Offset(r.right + 10, r.bottom),
        '${b.heightMm.toStringAsFixed(1)} mm',
        vertical: true,
      );
    }
  }

  void _drawDimension(Canvas canvas, Color color, Offset a, Offset b, String text,
      {bool vertical = false}) {
    final p = Paint()..color = color..strokeWidth = 1.5;
    canvas.drawLine(a, b, p);
    // End ticks
    const tickLen = 5.0;
    if (!vertical) {
      canvas.drawLine(a + const Offset(0, -tickLen), a + const Offset(0, tickLen), p);
      canvas.drawLine(b + const Offset(0, -tickLen), b + const Offset(0, tickLen), p);
    } else {
      canvas.drawLine(a + const Offset(-tickLen, 0), a + const Offset(tickLen, 0), p);
      canvas.drawLine(b + const Offset(-tickLen, 0), b + const Offset(tickLen, 0), p);
    }

    // Label
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold,
            shadows: const [Shadow(color: Colors.black, blurRadius: 3)]),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    if (vertical) {
      canvas.translate(mid.dx + 4, mid.dy);
      canvas.rotate(-pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    } else {
      tp.paint(canvas, Offset(mid.dx - tp.width / 2, mid.dy + 2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MeasurePainter o) => o.boxes != boxes;
}
