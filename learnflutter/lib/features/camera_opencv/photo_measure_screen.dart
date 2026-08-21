// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

/// Photo-based object size measurement.
///
/// Flow:
///   1. Chụp ảnh / Gallery
///   2. Chế độ "Đặt chuẩn": tap 2 điểm trên vật chuẩn → nhập khoảng cách thực (mm)
///      → lưu pxPerMm
///   3. Chế độ "Đo": tap 2 điểm → hiện khoảng cách mm
///   4. Có thể đo nhiều lần, reset hoặc chụp ảnh mới
///
/// OpenCV: hiện edge overlay để dễ snap vào biên vật thể.
class PhotoMeasureScreen extends StatefulWidget {
  const PhotoMeasureScreen({super.key});

  @override
  State<PhotoMeasureScreen> createState() => _PhotoMeasureScreenState();
}

enum _Step { noPhoto, calibrate, measure }

class _Segment {
  const _Segment(this.a, this.b, this.mm);
  final Offset a, b; // in image-normalized coords (0..1)
  final double mm;
}

class _PhotoMeasureScreenState extends State<PhotoMeasureScreen> {
  final _picker = ImagePicker();

  // Image state
  ui.Image? _uiImage;       // original for display
  Uint8List? _edgePng;      // OpenCV edge overlay
  int _imgW = 1, _imgH = 1; // actual image pixel size
  bool _showEdges = false;

  // Measurement state
  _Step _step = _Step.noPhoto;
  double? _pxPerMm;

  // Tap points (image-normalized 0..1)
  Offset? _p1, _p2;

  // Completed measurements
  List<_Segment> _segments = [];

  // Calibration reference segment (normalized)
  Offset? _refA, _refB;

  // ── Image loading ─────────────────────────────────────────────────────────

  Future<void> _capturePhoto() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    // Use image_picker camera for simplicity (no CameraController needed)
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 95);
    if (file == null) return;
    await _loadImage(file.path);
  }

  Future<void> _pickGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    await _loadImage(file.path);
  }

  Future<void> _loadImage(String path) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final img = frame.image;

    // Build edge overlay via OpenCV
    final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
    final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
    final blurred = cv.gaussianBlur(gray, (3, 3), 0);
    gray.dispose();
    final edges = cv.canny(blurred, 40, 120);
    blurred.dispose();
    final edgeBgr = cv.cvtColor(edges, cv.COLOR_GRAY2BGR);
    edges.dispose();
    final (_, edgePng) = cv.imencode('.png', edgeBgr);
    edgeBgr.dispose();

    if (mounted) setState(() {
      _uiImage   = img;
      _imgW      = mat.cols;
      _imgH      = mat.rows;
      _edgePng   = edgePng;
      _step      = _Step.calibrate;
      _p1 = _p2  = null;
      _refA = _refB = null;
      _pxPerMm   = null;
      _segments  = [];
    });
    mat.dispose();
  }

  // ── Tap handling ─────────────────────────────────────────────────────────

  void _onTap(Offset localPos, Size widgetSize) {
    // Convert widget coords → image-normalized (account for BoxFit.contain letterbox)
    final norm = _toNormalized(localPos, widgetSize);
    if (norm == null) return;

    if (_step == _Step.calibrate) {
      if (_p1 == null) {
        setState(() => _p1 = norm);
      } else {
        setState(() { _p2 = norm; });
        _askRealDistance();
      }
    } else if (_step == _Step.measure) {
      if (_p1 == null) {
        setState(() => _p1 = norm);
      } else {
        final a = _p1!;
        final b = norm;
        final pxDist = _pixelDist(a, b);
        final mm = pxDist / _pxPerMm!;
        setState(() {
          _segments.add(_Segment(a, b, mm));
          _p1 = null;
        });
      }
    }
  }

  /// Convert widget tap position → image-normalized (0..1), accounting for letterbox.
  Offset? _toNormalized(Offset local, Size widgetSize) {
    final imgAspect = _imgW / _imgH;
    final boxAspect = widgetSize.width / widgetSize.height;
    double drawW, drawH, offX, offY;
    if (imgAspect > boxAspect) {
      drawW = widgetSize.width;
      drawH = widgetSize.width / imgAspect;
      offX  = 0;
      offY  = (widgetSize.height - drawH) / 2;
    } else {
      drawH = widgetSize.height;
      drawW = widgetSize.height * imgAspect;
      offX  = (widgetSize.width - drawW) / 2;
      offY  = 0;
    }
    final ix = (local.dx - offX) / drawW;
    final iy = (local.dy - offY) / drawH;
    if (ix < 0 || ix > 1 || iy < 0 || iy > 1) return null;
    return Offset(ix, iy);
  }

  double _pixelDist(Offset a, Offset b) {
    final dx = (a.dx - b.dx) * _imgW;
    final dy = (a.dy - b.dy) * _imgH;
    return sqrt(dx * dx + dy * dy);
  }

  Future<void> _askRealDistance() async {
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Khoảng cách thực tế'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nhập khoảng cách (mm)',
            suffixText: 'mm',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(controller.text.trim());
              if (v != null && v > 0) Navigator.pop(context, v);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (result == null) {
      setState(() { _p1 = null; _p2 = null; });
      return;
    }

    final pxDist = _pixelDist(_p1!, _p2!);
    setState(() {
      _pxPerMm = pxDist / result;
      _refA    = _p1;
      _refB    = _p2;
      _p1 = _p2 = null;
      _step = _Step.measure;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ Chuẩn: ${result.toStringAsFixed(1)} mm = ${pxDist.toStringAsFixed(0)} px  →  ${_pxPerMm!.toStringAsFixed(2)} px/mm'),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  void _resetMeasurements() => setState(() { _segments = []; _p1 = null; });

  void _resetAll() => setState(() {
    _step = _Step.calibrate;
    _pxPerMm = null;
    _refA = _refB = null;
    _p1 = _p2 = null;
    _segments = [];
  });

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(switch (_step) {
          _Step.noPhoto   => 'Photo Measure',
          _Step.calibrate => '📐 Tap 2 điểm chuẩn',
          _Step.measure   => '📏 Tap 2 điểm để đo',
        }),
        actions: [
          if (_step == _Step.calibrate && _pxPerMm == null)
            const SizedBox.shrink(),
          if (_step == _Step.measure) ...[
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Xóa phép đo',
              onPressed: _resetMeasurements,
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Đặt lại chuẩn',
              onPressed: _resetAll,
            ),
          ],
          if (_uiImage != null)
            IconButton(
              icon: Icon(_showEdges ? Icons.visibility_off : Icons.auto_fix_high),
              tooltip: _showEdges ? 'Tắt edge' : 'Bật edge',
              onPressed: () => setState(() => _showEdges = !_showEdges),
            ),
        ],
      ),
      body: _step == _Step.noPhoto ? _buildNoPhoto() : _buildMeasureView(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildNoPhoto() => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.straighten, size: 72, color: Colors.white12),
      const SizedBox(height: 20),
      const Text('Chụp hoặc chọn ảnh để đo kích thước',
          style: TextStyle(color: Colors.white38, fontSize: 15)),
      const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        FilledButton.icon(
          onPressed: _capturePhoto,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Chụp ảnh'),
          style: FilledButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: _pickGallery,
          icon: const Icon(Icons.photo_library),
          label: const Text('Gallery'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.tealAccent,
              side: const BorderSide(color: Colors.tealAccent)),
        ),
      ]),
    ],
  ));

  Widget _buildMeasureView() {
    final img = _uiImage;
    if (img == null) return const SizedBox.shrink();

    return Column(children: [
      // Instruction banner
      _buildBanner(),
      // Image + overlay
      Expanded(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              onTapUp: (d) => _onTap(d.localPosition, size),
              child: Stack(children: [
                // Original image
                Positioned.fill(child: CustomPaint(
                  painter: _ImagePainter(img),
                )),
                // Edge overlay
                if (_showEdges && _edgePng != null)
                  Positioned.fill(child: Opacity(
                    opacity: 0.5,
                    child: Image.memory(_edgePng!, fit: BoxFit.contain, gaplessPlayback: true),
                  )),
                // Measurement overlay
                Positioned.fill(child: CustomPaint(
                  painter: _MeasurePainter(
                    imgW: _imgW.toDouble(), imgH: _imgH.toDouble(),
                    p1: _p1, p2: _p2,
                    refA: _refA, refB: _refB,
                    segments: _segments,
                    step: _step,
                  ),
                )),
              ]),
            );
          },
        ),
      ),
      // Measurements list
      if (_segments.isNotEmpty) _buildResultsList(),
    ]);
  }

  Widget _buildBanner() {
    final String msg;
    final Color color;
    if (_step == _Step.calibrate) {
      msg = _p1 == null
          ? '① Tap điểm đầu của vật chuẩn'
          : '② Tap điểm cuối — rồi nhập khoảng cách thực';
      color = Colors.orangeAccent;
    } else {
      msg = _p1 == null
          ? 'Tap điểm đầu muốn đo'
          : 'Tap điểm cuối';
      color = Colors.tealAccent;
    }
    return Container(
      width: double.infinity,
      color: color.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(msg, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildResultsList() => Container(
    color: Colors.black87,
    constraints: const BoxConstraints(maxHeight: 120),
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _segments.length,
      itemBuilder: (_, i) {
        final s = _segments[_segments.length - 1 - i]; // newest first
        final px = _pixelDist(s.a, s.b);
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 12,
            backgroundColor: _segColor(i),
            child: Text('${_segments.length - i}',
                style: const TextStyle(fontSize: 10, color: Colors.black)),
          ),
          title: Text(
            '${s.mm.toStringAsFixed(1)} mm  =  ${(s.mm / 10).toStringAsFixed(2)} cm',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${px.toStringAsFixed(0)} px',
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.white38),
            onPressed: () => setState(() => _segments.removeAt(_segments.length - 1 - i)),
          ),
        );
      },
    ),
  );

  Widget _buildBottomBar() => Container(
    color: Colors.black,
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: Row(children: [
      OutlinedButton.icon(
        onPressed: _capturePhoto,
        icon: const Icon(Icons.camera_alt, size: 16),
        label: const Text('Chụp mới'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.white54,
            side: const BorderSide(color: Colors.white24)),
      ),
      const SizedBox(width: 8),
      OutlinedButton.icon(
        onPressed: _pickGallery,
        icon: const Icon(Icons.photo_library, size: 16),
        label: const Text('Gallery'),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.white54,
            side: const BorderSide(color: Colors.white24)),
      ),
      if (_pxPerMm != null) ...[
        const Spacer(),
        Text(
          '${_pxPerMm!.toStringAsFixed(2)} px/mm',
          style: const TextStyle(color: Colors.white30, fontSize: 12),
        ),
      ],
    ]),
  );

  static Color _segColor(int i) {
    const colors = [
      Color(0xFF34D399), Color(0xFF60A5FA), Color(0xFFFBBF24),
      Color(0xFFF87171), Color(0xFFA78BFA), Color(0xFFF97316),
    ];
    return colors[i % colors.length];
  }
}

// ── Painters ─────────────────────────────────────────────────────────────

class _ImagePainter extends CustomPainter {
  const _ImagePainter(this.image);
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final imgAspect = image.width / image.height;
    final boxAspect = size.width / size.height;
    Rect dst;
    if (imgAspect > boxAspect) {
      final h = size.width / imgAspect;
      dst = Rect.fromLTWH(0, (size.height - h) / 2, size.width, h);
    } else {
      final w = size.height * imgAspect;
      dst = Rect.fromLTWH((size.width - w) / 2, 0, w, size.height);
    }
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(_ImagePainter old) => old.image != image;
}

class _MeasurePainter extends CustomPainter {
  const _MeasurePainter({
    required this.imgW, required this.imgH,
    required this.p1, required this.p2,
    required this.refA, required this.refB,
    required this.segments, required this.step,
  });

  final double imgW, imgH;
  final Offset? p1, p2;
  final Offset? refA, refB;
  final List<_Segment> segments;
  final _Step step;

  // Map normalized image coord → widget coord (letterboxed)
  Offset _toWidget(Offset norm, Size size) {
    final imgAspect = imgW / imgH;
    final boxAspect = size.width / size.height;
    double drawW, drawH, offX, offY;
    if (imgAspect > boxAspect) {
      drawW = size.width; drawH = size.width / imgAspect;
      offX = 0; offY = (size.height - drawH) / 2;
    } else {
      drawH = size.height; drawW = size.height * imgAspect;
      offX = (size.width - drawW) / 2; offY = 0;
    }
    return Offset(offX + norm.dx * drawW, offY + norm.dy * drawH);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Reference line (orange)
    if (refA != null && refB != null) {
      _drawLine(canvas, size, refA!, refB!, Colors.orange, dashed: true);
    }

    // Completed measurement segments
    for (int i = 0; i < segments.length; i++) {
      final s = segments[i];
      final color = _PhotoMeasureScreenState._segColor(i);
      _drawLine(canvas, size, s.a, s.b, color);
      _drawLabel(canvas, size, s.a, s.b, '${s.mm.toStringAsFixed(1)}mm', color, i + 1);
    }

    // Current tap points
    if (p1 != null) {
      final w1 = _toWidget(p1!, size);
      _drawCrosshair(canvas, w1, step == _Step.calibrate ? Colors.orange : Colors.tealAccent);
    }
    if (p2 != null && p1 != null) {
      final w2 = _toWidget(p2!, size);
      _drawCrosshair(canvas, w2, Colors.orange);
      canvas.drawLine(_toWidget(p1!, size), w2,
          Paint()..color = Colors.orange..strokeWidth = 1.5..style = PaintingStyle.stroke);
    }
  }

  void _drawLine(Canvas canvas, Size size, Offset a, Offset b, Color color, {bool dashed = false}) {
    final wa = _toWidget(a, size);
    final wb = _toWidget(b, size);
    final paint = Paint()..color = color..strokeWidth = 2.0;
    if (dashed) {
      _dashedLine(canvas, wa, wb, paint);
    } else {
      canvas.drawLine(wa, wb, paint);
    }
    // End ticks
    final dir = (wb - wa);
    final len = dir.distance;
    if (len < 1) return;
    final perp = Offset(-dir.dy, dir.dx) / len * 6;
    canvas.drawLine(wa - perp, wa + perp, paint);
    canvas.drawLine(wb - perp, wb + perp, paint);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final dir = (b - a);
    final total = dir.distance;
    final unit = dir / total;
    double d = 0;
    bool draw = true;
    while (d < total) {
      final next = min(d + 8, total);
      if (draw) canvas.drawLine(a + unit * d, a + unit * next, paint);
      d = next;
      draw = !draw;
    }
  }

  void _drawLabel(Canvas canvas, Size size, Offset a, Offset b, String text, Color color, int idx) {
    final mid = _toWidget((a + b) / 2, size);
    final tp = TextPainter(
      text: TextSpan(
        text: ' $idx: $text ',
        style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold,
            background: Paint()..color = color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawCrosshair(Canvas canvas, Offset c, Color color) {
    const r = 12.0;
    final p = Paint()..color = color..strokeWidth = 2;
    canvas.drawLine(c - Offset(r, 0), c + Offset(r, 0), p);
    canvas.drawLine(c - Offset(0, r), c + Offset(0, r), p);
    canvas.drawCircle(c, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_MeasurePainter old) => true;
}
