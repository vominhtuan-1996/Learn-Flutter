// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:convert';
import 'dart:io' as dart_io;
import 'dart:ui' as ui;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:gal/gal.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Micro-pattern watermark — nearly invisible, survives print+photograph.
///
/// Pattern layout (160×160 px):
///   TL/TR/BL finder marks (16×16 px, 3-ring) for perspective detection
///   9×9 data grid (cell=8×8 px) → 80 bits = 10 bytes text + 1 parity bit
///   Blended at 15% opacity on source image
///
/// Detection pipeline:
///   equalizeHist → matchTemplate (find 3 finders) → getPerspectiveTransform
///   → warpPerspective → adaptiveThreshold → read grid → UTF-8 decode
class DartCVDemoScreen extends StatefulWidget {
  const DartCVDemoScreen({super.key});

  @override
  State<DartCVDemoScreen> createState() => _DartCVDemoScreenState();
}

class _DartCVDemoScreenState extends State<DartCVDemoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _wController = TextEditingController(text: '© FPT ISC 2026');
  final _picker = ImagePicker();

  // Filter tab state
  cv.Mat? _filterSrc;
  cv.Mat? _filterResult;
  ui.Image? _filterSrcImg;
  ui.Image? _filterResultImg;
  String _selectedFilter = '';
  bool _filterBusy = false;

  cv.Mat? _embedSrc;
  cv.Mat? _embedResult;
  ui.Image? _embedSrcImg;
  ui.Image? _embedResultImg;
  String _embedStatus = '';

  cv.Mat? _detectSrc;
  ui.Image? _detectSrcImg;
  ui.Image? _amplifiedImg;
  String _detectResult = '';
  String _detectStatus = '';

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadSyntheticSrc();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _wController.dispose();
    _embedSrc?.dispose();
    _embedResult?.dispose();
    _detectSrc?.dispose();
    _filterSrc?.dispose();
    _filterResult?.dispose();
    super.dispose();
  }

  void _loadSyntheticSrc() {
    final mat = _makeSyntheticPhoto();
    _embedSrc?.dispose();
    _embedSrc = mat;
    _toUiImage(mat).then((img) {
      if (mounted) setState(() => _embedSrcImg = img);
    });
  }

  static cv.Mat _makeSyntheticPhoto() {
    final mat = cv.Mat.zeros(600, 800, cv.MatType.CV_8UC3);
    for (int r = 0; r < 600; r++)
      for (int c = 0; c < 800; c++)
        mat.set<cv.Vec3b>(r, c, cv.Vec3b(
          (r * 0.4).round() % 256,
          (c * 0.3).round() % 256,
          ((r + c) * 0.2).round() % 256,
        ));
    return mat;
  }

  Future<void> _pickEmbedSrc() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
    _embedSrc?.dispose();
    _embedSrc = mat;
    _embedResult?.dispose();
    _embedResult = null;
    final img = await _toUiImage(mat);
    if (mounted) setState(() { _embedSrcImg = img; _embedResultImg = null; _embedStatus = ''; });
  }

  Future<void> _doEmbed() async {
    final src = _embedSrc;
    if (src == null || _busy) return;
    final text = _wController.text.trim();
    if (text.isEmpty) return;
    final bytes = utf8.encode(text);
    if (bytes.length > WatermarkCodec.maxBytes) {
      setState(() => _embedStatus = '⚠️ Text quá dài! Tối đa ${WatermarkCodec.maxBytes} bytes.');
      return;
    }
    setState(() { _busy = true; _embedStatus = 'Đang nhúng...'; });
    final result = WatermarkCodec.embed(src, bytes);
    _embedResult?.dispose();
    _embedResult = result;
    final img = await _toUiImage(result);
    if (mounted) setState(() {
      _embedResultImg = img;
      _busy = false;
      _embedStatus = '✅ Nhúng xong — ${bytes.length} bytes, opacity 15%. Lưu PNG để giữ watermark.';
    });
  }

  Future<void> _pickDetectSrc() async {
    final f = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // giữ chất lượng cao để finder marks không bị nén
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();
    final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
    _detectSrc?.dispose();
    _detectSrc = mat;
    final img = await _toUiImage(mat);
    if (mounted) setState(() {
      _detectSrcImg = img;
      _detectResult = '';
      _detectStatus = 'Ảnh ${mat.cols}×${mat.rows} — nhấn Detect.';
    });
  }

  Future<void> _saveToAlbum() async {
    final mat = _embedResult;
    if (mat == null) return;
    try {
      final (_, bytes) = cv.imencode('.png', mat);
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.png';
      await dart_io.File(path).writeAsBytes(bytes);
      await Gal.putImage(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã lưu vào album (PNG)'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e'), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  Future<void> _useEmbedForDetect() async {
    final mat = _embedResult;
    if (mat == null) return;
    _detectSrc?.dispose();
    _detectSrc = mat.clone();
    final img = await _toUiImage(_detectSrc!);
    if (mounted) setState(() {
      _detectSrcImg = img;
      _detectResult = '';
      _detectStatus = 'Dùng ảnh embedded — nhấn Detect.';
    });
    _tabs.animateTo(1);
  }

  Future<void> _doDetect() async {
    final src = _detectSrc;
    if (src == null || _busy) return;
    setState(() { _busy = true; _detectResult = ''; _detectStatus = 'Đang detect...'; });
    try {
      final (text, debug) = WatermarkCodec.detect(src);
      if (mounted) setState(() { _detectResult = text; _detectStatus = debug; _busy = false; });
    } catch (e) {
      if (mounted) setState(() { _detectStatus = '❌ Lỗi: $e'; _busy = false; });
    }
  }

  Future<void> _doAmplify() async {
    final src = _detectSrc;
    if (src == null || _busy) return;
    setState(() { _busy = true; _detectStatus = 'Đang phơi sáng watermark...'; });
    final gray = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
    final amplified = WatermarkCodec.amplifyWatermark(gray);
    gray.dispose();
    final img = await _toUiImage(amplified);
    amplified.dispose();
    if (mounted) setState(() {
      _amplifiedImg = img;
      _busy = false;
      _detectStatus = 'Phơi sáng xong — vùng sáng = nơi có watermark signal.';
    });
  }

  Future<void> _pickFilterSrc() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    final mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
    _filterSrc?.dispose();
    _filterSrc = mat;
    _filterResult?.dispose();
    _filterResult = null;
    final img = await _toUiImage(mat);
    if (mounted) setState(() { _filterSrcImg = img; _filterResultImg = null; _selectedFilter = ''; });
  }

  static const _filters = [
    'Grayscale', 'Gaussian Blur', 'Box Blur', 'Median Blur', 'Bilateral',
    'Canny Edge', 'Sobel', 'Laplacian', 'Threshold (Otsu)',
    'Adaptive Threshold', 'Dilate', 'Erode', 'Morph Gradient',
    'Sharpen', 'Invert', 'Equalize Hist', 'Sepia',
  ];

  Future<void> _applyFilter(String name) async {
    final src = _filterSrc;
    if (src == null || _filterBusy) return;
    setState(() { _filterBusy = true; _selectedFilter = name; });

    cv.Mat result;
    switch (name) {
      case 'Grayscale':
        final g = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
        result = cv.cvtColor(g, cv.COLOR_GRAY2BGR);
        g.dispose();

      case 'Gaussian Blur':
        result = cv.gaussianBlur(src, (21, 21), 0);

      case 'Box Blur':
        result = cv.blur(src, (21, 21));

      case 'Median Blur':
        result = cv.medianBlur(src, 21);

      case 'Bilateral':
        result = cv.bilateralFilter(src, 15, 80, 80);

      case 'Canny Edge':
        final g = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
        final edges = cv.canny(g, 50, 150);
        result = cv.cvtColor(edges, cv.COLOR_GRAY2BGR);
        g.dispose(); edges.dispose();

      case 'Sobel':
        final g = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
        final sx = cv.sobel(g, cv.MatType.CV_16S, 1, 0);
        final sy = cv.sobel(g, cv.MatType.CV_16S, 0, 1);
        final absx = cv.convertScaleAbs(sx);
        final absy = cv.convertScaleAbs(sy);
        final combined = cv.addWeighted(absx, 0.5, absy, 0.5, 0);
        result = cv.cvtColor(combined, cv.COLOR_GRAY2BGR);
        g.dispose(); sx.dispose(); sy.dispose(); absx.dispose(); absy.dispose(); combined.dispose();

      case 'Laplacian':
        final g = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
        final lap = cv.laplacian(g, cv.MatType.CV_16S);
        final abs = cv.convertScaleAbs(lap);
        result = cv.cvtColor(abs, cv.COLOR_GRAY2BGR);
        g.dispose(); lap.dispose(); abs.dispose();

      case 'Threshold (Otsu)':
        final g = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
        final (_, th) = cv.threshold(g, 0, 255, cv.THRESH_BINARY | cv.THRESH_OTSU);
        result = cv.cvtColor(th, cv.COLOR_GRAY2BGR);
        g.dispose(); th.dispose();

      case 'Adaptive Threshold':
        final g = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
        final th = cv.adaptiveThreshold(g, 255, cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, 11, 2);
        result = cv.cvtColor(th, cv.COLOR_GRAY2BGR);
        g.dispose(); th.dispose();

      case 'Dilate':
        final kernel = cv.getStructuringElement(cv.MORPH_RECT, (5, 5));
        result = cv.dilate(src, kernel);
        kernel.dispose();

      case 'Erode':
        final kernel = cv.getStructuringElement(cv.MORPH_RECT, (5, 5));
        result = cv.erode(src, kernel);
        kernel.dispose();

      case 'Morph Gradient':
        final kernel = cv.getStructuringElement(cv.MORPH_RECT, (5, 5));
        result = cv.morphologyEx(src, cv.MORPH_GRADIENT, kernel);
        kernel.dispose();

      case 'Sharpen':
        // 3×3 sharpening kernel
        final kernel = cv.Mat.zeros(3, 3, cv.MatType.CV_32FC(1));
        kernel.set<double>(0, 1, -1); kernel.set<double>(1, 0, -1);
        kernel.set<double>(1, 1,  5); kernel.set<double>(1, 2, -1);
        kernel.set<double>(2, 1, -1);
        result = cv.filter2D(src, -1, kernel);
        kernel.dispose();

      case 'Invert':
        result = cv.convertScaleAbs(src, alpha: -1, beta: 255);

      case 'Equalize Hist':
        final g = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
        final eq = cv.equalizeHist(g);
        result = cv.cvtColor(eq, cv.COLOR_GRAY2BGR);
        g.dispose(); eq.dispose();

      case 'Sepia':
        result = src.clone();
        for (int r = 0; r < src.rows; r++) {
          for (int c = 0; c < src.cols; c++) {
            final px = src.at<cv.Vec3b>(r, c);
            final b = px.val1.toDouble(); final g = px.val2.toDouble(); final rv = px.val3.toDouble();
            final nb = (0.272*rv + 0.534*g + 0.131*b).clamp(0,255).round();
            final ng = (0.349*rv + 0.686*g + 0.168*b).clamp(0,255).round();
            final nr = (0.393*rv + 0.769*g + 0.189*b).clamp(0,255).round();
            result.set<cv.Vec3b>(r, c, cv.Vec3b(nb, ng, nr));
          }
        }

      default:
        result = src.clone();
    }

    final img = await _toUiImage(result);
    _filterResult?.dispose();
    _filterResult = result;
    if (mounted) setState(() { _filterResultImg = img; _filterBusy = false; });
  }

  List<({String label, ui.Image image})> get _filterImages => [
    if (_filterSrcImg != null) (label: 'Original', image: _filterSrcImg!),
    if (_filterResultImg != null) (label: _selectedFilter, image: _filterResultImg!),
  ];

  Widget _buildFilterTab() => Column(children: [
    Expanded(child: Row(children: [
      _Pane(
        label: 'Original',
        image: _filterSrcImg,
        onTap: _filterImages.isNotEmpty ? () => _showCarousel(_filterImages, initialIndex: 0) : null,
      ),
      const VerticalDivider(width: 1),
      _Pane(
        label: _selectedFilter.isEmpty ? 'Result' : _selectedFilter,
        image: _filterResultImg,
        onTap: _filterImages.length > 1 ? () => _showCarousel(_filterImages, initialIndex: 1) : null,
      ),
    ])),
    const Divider(height: 1),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        OutlinedButton.icon(
          onPressed: _pickFilterSrc,
          icon: const Icon(Icons.photo_library, size: 16),
          label: const Text('Chọn ảnh'),
        ),
        if (_filterBusy) ...[
          const SizedBox(width: 12),
          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 8),
          const Text('Đang xử lý...', style: TextStyle(fontSize: 12)),
        ],
      ]),
    ),
    SizedBox(
      height: 100,
      child: _filterSrc == null
          ? const Center(child: Text('Chọn ảnh để bắt đầu', style: TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((name) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(name, style: const TextStyle(fontSize: 12)),
                    selected: _selectedFilter == name,
                    onSelected: _filterBusy ? null : (_) => _applyFilter(name),
                  ),
                )).toList(),
              ),
            ),
    ),
    const SizedBox(height: 8),
  ]);

  void _showCarousel(List<({String label, ui.Image image})> items, {int initialIndex = 0}) {
    showDialog<void>(
      context: context,
      builder: (_) => _CarouselDialog(items: items, initialIndex: initialIndex),
    );
  }

  static Future<ui.Image> _toUiImage(cv.Mat mat) async {
    final (_, bytes) = cv.imencode('.png', mat);
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micro-Pattern Watermark'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: '🔒 Embed'), Tab(text: '🔍 Detect'), Tab(text: '🎨 Filter')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_buildEmbedTab(), _buildDetectTab(), _buildFilterTab()],
      ),
    );
  }

  List<({String label, ui.Image image})> get _embedImages => [
    if (_embedSrcImg != null) (label: 'Original', image: _embedSrcImg!),
    if (_embedResultImg != null) (label: 'Embedded (15% opacity)', image: _embedResultImg!),
  ];

  List<({String label, ui.Image image})> get _detectImages => [
    if (_detectSrcImg != null) (label: 'Ảnh chụp', image: _detectSrcImg!),
    if (_amplifiedImg != null) (label: 'Phơi sáng (diff×8)', image: _amplifiedImg!),
  ];

  Widget _buildEmbedTab() => Column(children: [
    if (_embedStatus.isNotEmpty) _StatusBar(_embedStatus),
    Expanded(child: Row(children: [
      _Pane(
        label: 'Original',
        image: _embedSrcImg,
        onTap: _embedImages.isNotEmpty ? () => _showCarousel(_embedImages, initialIndex: 0) : null,
      ),
      const VerticalDivider(width: 1),
      _Pane(
        label: 'Embedded (15% opacity)',
        image: _embedResultImg,
        onTap: _embedImages.length > 1 ? () => _showCarousel(_embedImages, initialIndex: 1) : null,
      ),
    ])),
    const Divider(height: 1),
    Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        TextField(
          controller: _wController,
          decoration: InputDecoration(
            labelText: 'Watermark text (max ${WatermarkCodec.maxBytes} bytes)',
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          OutlinedButton(onPressed: _loadSyntheticSrc, child: const Text('Synthetic')),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: _pickEmbedSrc, child: const Text('Gallery')),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: _busy ? null : _doEmbed,
              icon: _busy
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.lock_outline, size: 16),
              label: const Text('Embed'),
            ),
          ),
        ]),
        if (_embedResult != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _useEmbedForDetect,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Test Detect →'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _saveToAlbum,
                icon: const Icon(Icons.save_alt, size: 16),
                label: const Text('Lưu vào Album'),
              ),
            ),
          ]),
        ],
      ]),
    ),
  ]);

  Widget _buildDetectTab() => Column(children: [
    if (_detectStatus.isNotEmpty) _StatusBar(_detectStatus),
    Expanded(
      child: Row(children: [
        _Pane(
          label: 'Ảnh chụp',
          image: _detectSrcImg,
          onTap: _detectImages.isNotEmpty ? () => _showCarousel(_detectImages, initialIndex: 0) : null,
        ),
        const VerticalDivider(width: 1),
        _Pane(
          label: 'Phơi sáng (diff×8)',
          image: _amplifiedImg,
          onTap: _detectImages.length > 1 ? () => _showCarousel(_detectImages, initialIndex: 1) : null,
        ),
      ]),
    ),
    const Divider(height: 1),
    if (_detectResult.isNotEmpty)
      Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Watermark decoded:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 4),
          Text(_detectResult, style: const TextStyle(fontSize: 15)),
        ]),
      ),
    Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        OutlinedButton.icon(
          onPressed: _pickDetectSrc,
          icon: const Icon(Icons.camera_alt, size: 16),
          label: const Text('Chụp'),
        ),
        const SizedBox(width: 6),
        OutlinedButton.icon(
          onPressed: (_detectSrc != null && !_busy) ? _doAmplify : null,
          icon: const Icon(Icons.wb_sunny_outlined, size: 16),
          label: const Text('Phơi sáng'),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: FilledButton.icon(
            onPressed: (_detectSrc != null && !_busy) ? _doDetect : null,
            icon: _busy
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.search, size: 16),
            label: const Text('Detect Watermark'),
          ),
        ),
      ]),
    ),
  ]);
}

// ═══════════════════════════════════════════════════════════════════════════
// Watermark codec
// ═══════════════════════════════════════════════════════════════════════════

class WatermarkCodec {
  WatermarkCodec._();

  static const int patSize   = 160;  // pattern px
  static const int finderSz  = 16;   // finder mark px
  static const int cellSz    = 8;    // data cell px
  static const int gridDim   = 9;    // 9×9 = 81 cells
  static const int edgeMargin = 4;   // px from pattern edge

  static const int gridOriginX = edgeMargin + finderSz + edgeMargin; // 24
  static const int gridOriginY = edgeMargin + finderSz + edgeMargin; // 24

  // Finder top-left positions inside 160×160 pattern
  static const int tlX = edgeMargin;                         // 4
  static const int tlY = edgeMargin;                         // 4
  static const int trX = patSize - edgeMargin - finderSz;    // 140
  static const int trY = edgeMargin;                         // 4
  static const int blX = edgeMargin;                         // 4
  static const int blY = patSize - edgeMargin - finderSz;    // 140

  /// Max text bytes (80 data bits / 8 = 10)
  static const int maxBytes = (gridDim * gridDim - 1) ~/ 8;  // 10

  // ── Embed ──────────────────────────────────────────────────────────────

  static cv.Mat embed(cv.Mat src, List<int> data) {
    final padded = List<int>.from(data);
    while (padded.length < maxBytes) padded.add(0);

    final pattern = _buildPattern(padded);
    final dst = src.clone();

    final px = src.cols - patSize - 10;
    final py = src.rows - patSize - 10;
    const alpha = 0.15;

    for (int r = 0; r < patSize; r++) {
      for (int c = 0; c < patSize; c++) {
        final imgR = py + r;
        final imgC = px + c;
        if (imgR < 0 || imgR >= src.rows || imgC < 0 || imgC >= src.cols) continue;
        final patGray = pattern.at<int>(r, c);
        final srcPx = dst.at<cv.Vec3b>(imgR, imgC);
        dst.set<cv.Vec3b>(imgR, imgC, cv.Vec3b(
          (srcPx.val1 * (1 - alpha) + patGray * alpha).round().clamp(0, 255),
          (srcPx.val2 * (1 - alpha) + patGray * alpha).round().clamp(0, 255),
          (srcPx.val3 * (1 - alpha) + patGray * alpha).round().clamp(0, 255),
        ));
      }
    }
    pattern.dispose();
    return dst;
  }

  static cv.Mat _buildPattern(List<int> data) {
    final pat = cv.Mat.zeros(patSize, patSize, cv.MatType.CV_8UC1);
    // white fill
    for (int r = 0; r < patSize; r++)
      for (int c = 0; c < patSize; c++)
        pat.set<int>(r, c, 255);

    _drawFinder(pat, tlX, tlY);
    _drawFinder(pat, trX, trY);
    _drawFinder(pat, blX, blY);

    int parity = 0;
    int bitIdx = 0;
    for (int row = 0; row < gridDim; row++) {
      for (int col = 0; col < gridDim; col++) {
        final cellIdx = row * gridDim + col;
        if (cellIdx == gridDim * gridDim - 1) {
          _fillCell(pat, col, row, parity & 1);
          break;
        }
        final byteIdx = bitIdx ~/ 8;
        final bitPos = 7 - (bitIdx % 8);
        final bit = byteIdx < data.length ? (data[byteIdx] >> bitPos) & 1 : 0;
        parity ^= bit;
        _fillCell(pat, col, row, bit);
        bitIdx++;
      }
    }
    return pat;
  }

  /// 3-ring finder: outer black 16×16 / inner white 10×10 / center black 6×6.
  static void _drawFinder(cv.Mat pat, int x, int y) {
    for (int r = y; r < y + finderSz; r++)
      for (int c = x; c < x + finderSz; c++)
        pat.set<int>(r, c, 0);
    for (int r = y + 3; r < y + 13; r++)
      for (int c = x + 3; c < x + 13; c++)
        pat.set<int>(r, c, 255);
    for (int r = y + 5; r < y + 11; r++)
      for (int c = x + 5; c < x + 11; c++)
        pat.set<int>(r, c, 0);
  }

  static void _fillCell(cv.Mat pat, int col, int row, int bit) {
    final x = gridOriginX + col * cellSz;
    final y = gridOriginY + row * cellSz;
    final color = bit == 1 ? 0 : 255;
    for (int r = y + 1; r < y + cellSz - 1; r++)
      for (int c = x + 1; c < x + cellSz - 1; c++)
        pat.set<int>(r, c, color);
  }

  // ── Detect ─────────────────────────────────────────────────────────────

  /// Phơi sáng watermark: subtract low-freq background, amplify diff ×8.
  /// Input: grayscale Mat. Output: grayscale Mat (caller disposes cả hai).
  static cv.Mat amplifyWatermark(cv.Mat gray) {
    // Low-freq background = blurred ảnh (kernel lớn loại bỏ watermark signal)
    final background = cv.gaussianBlur(gray, (51, 51), 0);
    final rows = gray.rows;
    final cols = gray.cols;
    final out = cv.Mat.zeros(rows, cols, cv.MatType.CV_8UC1);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final diff = (gray.at<int>(r, c) - background.at<int>(r, c)).abs();
        out.set<int>(r, c, (diff * 8).clamp(0, 255));
      }
    }
    background.dispose();
    return out;
  }

  static (String, String) detect(cv.Mat src) {
    final gray = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
    // Amplify trước: subtract background → phóng đại watermark signal
    final amplified = amplifyWatermark(gray);
    gray.dispose();
    // Equalize để chuẩn hóa lighting sau khi amplify
    final equalized = cv.equalizeHist(amplified);
    amplified.dispose();

    final templ = _buildFinderTemplate();
    final matchResult = cv.matchTemplate(equalized, templ, cv.TM_CCOEFF_NORMED);
    final locations = _findTopMatches(matchResult, 3, minDist: finderSz * 3);
    matchResult.dispose();
    templ.dispose();

    if (locations.length < 3) {
      equalized.dispose();
      return ('', '❌ Tìm được ${locations.length}/3 finder. Chụp gần hơn / sáng hơn.');
    }

    final corners = _identifyCorners(locations);
    if (corners == null) {
      equalized.dispose();
      return ('', '❌ Không xác định orientation của pattern.');
    }

    final flat = _perspectiveCorrect(equalized, corners);
    equalized.dispose();

    final binary = cv.adaptiveThreshold(flat, 255, cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, 15, 5);
    flat.dispose();

    final (text, parityOk) = _readGrid(binary);
    binary.dispose();

    if (!parityOk) return (text, '⚠️ Parity error — noise có thể làm sai data: "$text"');
    return (text, '✅ Detect thành công! Parity OK.');
  }

  static cv.Mat _buildFinderTemplate() {
    final t = cv.Mat.zeros(finderSz, finderSz, cv.MatType.CV_8UC1);
    // outer black
    for (int r = 0; r < finderSz; r++)
      for (int c = 0; c < finderSz; c++)
        t.set<int>(r, c, 0);
    // inner white
    for (int r = 3; r < 13; r++)
      for (int c = 3; c < 13; c++)
        t.set<int>(r, c, 255);
    // center black
    for (int r = 5; r < 11; r++)
      for (int c = 5; c < 11; c++)
        t.set<int>(r, c, 0);
    return t;
  }

  static List<cv.Point> _findTopMatches(cv.Mat result, int n, {required int minDist}) {
    final found = <cv.Point>[];
    // Suppress mask: 255 = suppressed region
    final mask = cv.Mat.zeros(result.rows, result.cols, cv.MatType.CV_8UC1);
    for (int i = 0; i < n; i++) {
      final (_, maxVal, _, maxLoc) = cv.minMaxLoc(result, mask: mask);
      if (maxVal < 0.4) break;
      found.add(cv.Point(maxLoc.x, maxLoc.y));
      // Suppress region
      for (int r = (maxLoc.y - minDist).clamp(0, result.rows - 1);
           r <= (maxLoc.y + minDist).clamp(0, result.rows - 1); r++)
        for (int c = (maxLoc.x - minDist).clamp(0, result.cols - 1);
             c <= (maxLoc.x + minDist).clamp(0, result.cols - 1); c++)
          mask.set<int>(r, c, 255);
    }
    mask.dispose();
    return found;
  }

  /// TL = smallest x+y, then BL = leftmost of remaining, TR = rightmost.
  static List<cv.Point>? _identifyCorners(List<cv.Point> pts) {
    if (pts.length < 3) return null;
    final sorted = List<cv.Point>.from(pts)..sort((a, b) => (a.x + a.y) - (b.x + b.y));
    final tl = sorted[0];
    final other = sorted.sublist(1)..sort((a, b) => a.x - b.x);
    return [tl, other[1], other[0]]; // [TL, TR, BL]
  }

  static cv.Mat _perspectiveCorrect(cv.Mat gray, List<cv.Point> corners) {
    final tl = corners[0];
    final tr = corners[1];
    final bl = corners[2];
    final br = cv.Point(tr.x + bl.x - tl.x, tr.y + bl.y - tl.y);

    final srcList = [tl, tr, br, bl];
    final srcPts = cv.VecPoint.generate(4, (i) => srcList[i]);
    final dstList = [
      cv.Point(0, 0),
      cv.Point(patSize - 1, 0),
      cv.Point(patSize - 1, patSize - 1),
      cv.Point(0, patSize - 1),
    ];
    final dstPts = cv.VecPoint.generate(4, (i) => dstList[i]);

    final m = cv.getPerspectiveTransform(srcPts, dstPts);
    final flat = cv.warpPerspective(gray, m, (patSize, patSize));
    m.dispose();
    srcPts.dispose();
    dstPts.dispose();
    return flat;
  }

  static (String, bool) _readGrid(cv.Mat binary) {
    final bits = <int>[];
    for (int row = 0; row < gridDim; row++) {
      for (int col = 0; col < gridDim; col++) {
        final cx = gridOriginX + col * cellSz + cellSz ~/ 2;
        final cy = gridOriginY + row * cellSz + cellSz ~/ 2;
        if (cx >= binary.cols || cy >= binary.rows) { bits.add(0); continue; }
        bits.add(binary.at<int>(cy, cx) < 128 ? 1 : 0); // black = 1
      }
    }

    final parityBit = bits.last;
    final dataBits = bits.sublist(0, bits.length - 1);

    final dataBytes = <int>[];
    for (int i = 0; i + 7 < dataBits.length; i += 8) {
      int byte = 0;
      for (int b = 0; b < 8; b++) byte |= (dataBits[i + b] << (7 - b));
      if (byte == 0) break;
      dataBytes.add(byte);
    }

    int computedParity = 0;
    for (final bit in dataBits) computedParity ^= bit;

    return (
      dataBytes.isEmpty ? '' : utf8.decode(dataBytes, allowMalformed: true),
      (computedParity & 1) == parityBit,
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────

class _Pane extends StatelessWidget {
  const _Pane({required this.label, required this.image, this.onTap});
  final String label;
  final ui.Image? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
      Expanded(
        child: image == null
            ? const Center(child: Text('—', style: TextStyle(color: Colors.grey)))
            : GestureDetector(
                onTap: onTap,
                child: Stack(children: [
                  Positioned.fill(child: RawImage(image: image, fit: BoxFit.contain)),
                  if (onTap != null)
                    const Positioned(
                      right: 6, bottom: 6,
                      child: Icon(Icons.zoom_in, size: 18, color: Colors.white70),
                    ),
                ]),
              ),
      ),
    ]),
  );
}

class _CarouselDialog extends StatefulWidget {
  const _CarouselDialog({required this.items, required this.initialIndex});
  final List<({String label, ui.Image image})> items;
  final int initialIndex;

  @override
  State<_CarouselDialog> createState() => _CarouselDialogState();
}

class _CarouselDialogState extends State<_CarouselDialog> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            widget.items[_current].label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '${_current + 1} / ${widget.items.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                initialPage: widget.initialIndex,
                height: double.infinity,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                enlargeCenterPage: false,
                onPageChanged: (i, _) => setState(() => _current = i),
              ),
              items: widget.items.map((item) => InteractiveViewer(
                minScale: 1.0,
                maxScale: 6.0,
                child: RawImage(image: item.image, fit: BoxFit.contain),
              )).toList(),
            ),
          ),
          // Dot indicator
          if (widget.items.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.items.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _current == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _current == i ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
        ]),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );
}
