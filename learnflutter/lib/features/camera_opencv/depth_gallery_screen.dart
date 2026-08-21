// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

/// Gallery → MiDaS depth estimation test screen.
/// Simpler than CameraDepthScreen — no camera, just pick image → analyze.
class DepthGalleryScreen extends StatefulWidget {
  const DepthGalleryScreen({super.key});

  @override
  State<DepthGalleryScreen> createState() => _DepthGalleryScreenState();
}

class _DepthGalleryScreenState extends State<DepthGalleryScreen> {
  OrtSession? _session;
  final _picker = ImagePicker();

  bool _modelReady = false;
  bool _analyzing = false;
  String _status = 'Đang tải model...';

  Uint8List? _originalBytes;
  List<double>? _depthFlat;
  Uint8List? _depthPng;

  double _alpha = 0.65;
  bool _depthOnly = false;
  int _colormap = cv.COLORMAP_INFERNO;

  static const _colormaps = <String, int>{
    'Inferno': cv.COLORMAP_INFERNO,
    'Magma':   cv.COLORMAP_MAGMA,
    'Turbo':   cv.COLORMAP_TURBO,
    'Jet':     cv.COLORMAP_JET,
  };

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      OrtEnv.instance.init();
      final bytes = await rootBundle.load('assets/models/midas_v21_small_256.onnx');
      _session = OrtSession.fromBuffer(
        bytes.buffer.asUint8List(),
        OrtSessionOptions()..setIntraOpNumThreads(2),
      );
      if (mounted) setState(() { _modelReady = true; _status = 'Chọn ảnh để phân tích depth'; });
    } catch (e) {
      if (mounted) setState(() => _status = 'Lỗi load model: $e');
    }
  }

  Future<void> _pick() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() { _analyzing = true; _status = 'Đang chạy MiDaS...'; });

    try {
      final fileBytes = await File(file.path).readAsBytes();
      final src = cv.imdecode(fileBytes, cv.IMREAD_COLOR);

      // Original for display
      final displayW = src.cols.clamp(1, 1200);
      final displayH = (displayW * src.rows / src.cols).round();
      final display = cv.resize(src, (displayW, displayH));
      final (_, origJpg) = cv.imencode('.jpg', display);
      display.dispose();

      // Run MiDaS
      final resized = cv.resize(src, (256, 256));
      src.dispose();
      final depth = _runMidas(resized);
      resized.dispose();
      final png = _buildHeatmap(depth, _colormap);

      if (mounted) setState(() {
        _originalBytes = origJpg;
        _depthFlat = depth;
        _depthPng = png;
        _analyzing = false;
        _status = 'Done — ${file.name}';
      });
    } catch (e) {
      if (mounted) setState(() { _analyzing = false; _status = 'Lỗi: $e'; });
    }
  }

  void _applyColormap(int colormap) {
    final flat = _depthFlat;
    if (flat == null) return;
    setState(() { _colormap = colormap; _depthPng = _buildHeatmap(flat, colormap); });
  }

  // ── MiDaS ────────────────────────────────────────────────────────────────

  List<double> _runMidas(cv.Mat bgr256) {
    const mean = [0.485, 0.456, 0.406];
    const std  = [0.229, 0.224, 0.225];
    final input = Float32List(3 * 256 * 256);
    for (int r = 0; r < 256; r++)
      for (int c = 0; c < 256; c++) {
        final px = bgr256.at<cv.Vec3b>(r, c);
        final rgb = [px.val3 / 255.0, px.val2 / 255.0, px.val1 / 255.0];
        for (int ch = 0; ch < 3; ch++)
          input[ch * 256 * 256 + r * 256 + c] = (rgb[ch] - mean[ch]) / std[ch];
      }

    final tensor  = OrtValueTensor.createTensorWithDataList(input, [1, 3, 256, 256]);
    final runOpts = OrtRunOptions();
    final outputs = _session!.run(runOpts, {_session!.inputNames.first: tensor});
    tensor.release();
    runOpts.release();

    final raw = outputs.first?.value;
    for (final o in outputs) o?.release();
    if (raw == null) return List.filled(256 * 256, 0.0);

    try {
      if (raw is List && raw.first is List && (raw.first as List).first is List)
        return (raw.first as List).expand((r) => (r as List).cast<num>()).map((v) => v.toDouble()).toList();
      if (raw is List && raw.first is List)
        return (raw as List).expand((r) => (r as List).cast<num>()).map((v) => v.toDouble()).toList();
      return (raw as List).cast<num>().map((v) => v.toDouble()).toList();
    } catch (_) { return List.filled(256 * 256, 0.0); }
  }

  static Uint8List _buildHeatmap(List<double> depth, int colormap) {
    double mn = depth.first, mx = depth.first;
    for (final v in depth) { if (v < mn) mn = v; if (v > mx) mx = v; }
    final range = mx - mn;
    final gray = cv.Mat.zeros(256, 256, cv.MatType.CV_8UC1);
    for (int i = 0; i < depth.length; i++)
      gray.set<int>(i ~/ 256, i % 256,
          ((range > 0 ? (depth[i] - mn) / range : 0.5) * 255).round().clamp(0, 255));
    final colored = cv.applyColorMap(gray, colormap);
    gray.dispose();
    final (_, png) = cv.imencode('.png', colored);
    colored.dispose();
    return png;
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _session?.release();
    OrtEnv.instance.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Depth — Gallery Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: (_modelReady && !_analyzing) ? _pick : null,
            tooltip: 'Chọn ảnh',
          ),
        ],
      ),
      body: Column(children: [
        // Status bar
        Container(
          width: double.infinity,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(children: [
            if (_analyzing || !_modelReady)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(width: 12, height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent)),
              ),
            Expanded(child: Text(_status,
                style: const TextStyle(color: Colors.white60, fontSize: 12))),
          ]),
        ),

        // Image area
        Expanded(child: _buildImageArea()),

        // Controls (only when result available)
        if (_depthPng != null) _buildControls(),
      ]),

      // FAB pick button
      floatingActionButton: _depthPng == null ? FloatingActionButton.extended(
        onPressed: (_modelReady && !_analyzing) ? _pick : null,
        backgroundColor: _modelReady ? Colors.tealAccent : Colors.grey,
        foregroundColor: Colors.black,
        icon: _analyzing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : const Icon(Icons.photo_library),
        label: Text(_analyzing ? 'Đang xử lý...' : 'Chọn ảnh'),
      ) : null,
    );
  }

  Widget _buildImageArea() {
    if (_originalBytes == null || _depthPng == null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.image_search, size: 64, color: Colors.white12),
        const SizedBox(height: 16),
        Text(
          _modelReady ? 'Chọn ảnh từ gallery để phân tích' : 'Đang tải MiDaS model...',
          style: const TextStyle(color: Colors.white30, fontSize: 14),
        ),
      ]));
    }

    if (_depthOnly) {
      return InteractiveViewer(
        child: Image.memory(_depthPng!, fit: BoxFit.contain, gaplessPlayback: true),
      );
    }

    // Blend: original + depth overlay
    return InteractiveViewer(
      child: Stack(children: [
        Positioned.fill(child: Image.memory(_originalBytes!, fit: BoxFit.contain, gaplessPlayback: true)),
        Positioned.fill(child: Opacity(
          opacity: _alpha,
          child: Image.memory(_depthPng!, fit: BoxFit.contain, gaplessPlayback: true),
        )),
      ]),
    );
  }

  Widget _buildControls() => Container(
    color: Colors.black,
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      // Depth only toggle + opacity
      Row(children: [
        const Text('Depth only', style: TextStyle(color: Colors.white60, fontSize: 13)),
        Switch(value: _depthOnly, activeColor: Colors.tealAccent,
            onChanged: (v) => setState(() => _depthOnly = v)),
        const Spacer(),
        if (!_depthOnly) ...[
          const Icon(Icons.layers, color: Colors.white30, size: 16),
          const SizedBox(width: 4),
          SizedBox(
            width: 120,
            child: Slider(
              value: _alpha, min: 0.1, max: 1.0,
              activeColor: Colors.tealAccent,
              onChanged: (v) => setState(() => _alpha = v),
            ),
          ),
          Text('${(_alpha * 100).toInt()}%',
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ]),

      // Colormap row
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _colormaps.entries.map((e) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.key, style: const TextStyle(fontSize: 12)),
              selected: _colormap == e.value,
              selectedColor: Colors.tealAccent,
              onSelected: (_) => _applyColormap(e.value),
            ),
          )).toList(),
        ),
      ),
      const SizedBox(height: 8),

      // Legend
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('← Xa (Far)', style: TextStyle(color: Colors.white24, fontSize: 11)),
        Container(
          width: 150, height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: _colormap == cv.COLORMAP_JET
                  ? const [Colors.blue, Colors.cyan, Colors.green, Colors.yellow, Colors.red]
                  : const [Colors.black, Colors.purple, Colors.deepOrange, Colors.yellow, Colors.white],
            ),
          ),
        ),
        const Text('Gần (Near) →', style: TextStyle(color: Colors.white24, fontSize: 11)),
      ]),

      // Pick another
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _pick,
          icon: const Icon(Icons.photo_library, size: 16),
          label: const Text('Chọn ảnh khác'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.tealAccent,
              side: const BorderSide(color: Colors.tealAccent)),
        ),
      ),
    ]),
  );
}
