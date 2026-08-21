// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;

/// Monocular depth estimation — MiDaS v2.1 small.
///
/// Flow:
///   1. Camera preview (viewfinder only, no stream processing)
///   2. User chụp ảnh (shutter) hoặc chọn từ gallery
///   3. MiDaS inference (~1-3s) → depth heatmap
///   4. Hiện kết quả: original | depth, opacity slider, colormap selector
///   5. Tap "Chụp lại" → quay về preview
class CameraDepthScreen extends StatefulWidget {
  const CameraDepthScreen({super.key});

  @override
  State<CameraDepthScreen> createState() => _CameraDepthScreenState();
}

enum _ViewState { preview, analyzing, result }

class _CameraDepthScreenState extends State<CameraDepthScreen> {
  CameraController? _ctrl;
  OrtSession? _session;
  final _picker = ImagePicker();

  bool _modelReady = false;
  bool _cameraReady = false;
  String _error = '';

  _ViewState _viewState = _ViewState.preview;

  // Result state
  Uint8List? _originalPng;  // captured photo bytes
  List<double>? _depthFlat; // raw MiDaS output, kept for colormap re-apply
  Uint8List? _depthPng;     // colored heatmap

  double _alpha = 0.6;
  bool _showDepthOnly = false;

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
    _initCamera();
  }

  Future<void> _loadModel() async {
    try {
      OrtEnv.instance.init();
      final bytes = await rootBundle.load('assets/models/midas_v21_small_256.onnx');
      final opts = OrtSessionOptions()..setIntraOpNumThreads(2);
      _session = OrtSession.fromBuffer(bytes.buffer.asUint8List(), opts);
      if (mounted) setState(() => _modelReady = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Model error: $e');
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) { setState(() => _error = 'No camera'); return; }
      final ctrl = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await ctrl.initialize();
      if (!mounted) return;
      _ctrl = ctrl;
      setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted) setState(() => _error = 'Camera error: $e');
    }
  }

  // ── Capture & analyze ────────────────────────────────────────────────────

  Future<void> _captureAndAnalyze() async {
    final ctrl = _ctrl;
    if (ctrl == null || !_modelReady) return;
    try {
      final file = await ctrl.takePicture();
      await _analyzeFile(file.path);
    } catch (e) {
      if (mounted) setState(() => _error = 'Capture error: $e');
    }
  }

  Future<void> _pickAndAnalyze() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    await _analyzeFile(file.path);
  }

  Future<void> _analyzeFile(String path) async {
    setState(() { _viewState = _ViewState.analyzing; _error = ''; });
    try {
      final fileBytes = await File(path).readAsBytes();
      final src = cv.imdecode(fileBytes, cv.IMREAD_COLOR);

      // Encode original for display (resize to max 800px wide to save memory)
      final displayMat = src.cols > 800
          ? cv.resize(src, (800, (800 * src.rows / src.cols).round()))
          : src.clone();
      final (_, origPng) = cv.imencode('.jpg', displayMat);
      displayMat.dispose();

      // Resize to 256×256 for MiDaS
      final resized = cv.resize(src, (256, 256));
      src.dispose();

      final depth = _runMidas(resized);
      resized.dispose();

      final png = _buildHeatmap(depth, _colormap);

      if (mounted) setState(() {
        _originalPng  = origPng;
        _depthFlat    = depth;
        _depthPng     = png;
        _viewState    = _ViewState.result;
        _showDepthOnly = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = 'Analyze error: $e'; _viewState = _ViewState.preview; });
    }
  }

  void _changeColormap(int colormap) {
    final depth = _depthFlat;
    if (depth == null) return;
    setState(() {
      _colormap = colormap;
      _depthPng = _buildHeatmap(depth, colormap);
    });
  }

  void _reset() => setState(() {
    _viewState    = _ViewState.preview;
    _originalPng  = null;
    _depthFlat    = null;
    _depthPng     = null;
  });

  // ── MiDaS inference ─────────────────────────────────────────────────────

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
      if (raw is List && raw.first is List && (raw.first as List).first is List) {
        return (raw.first as List).expand((r) => (r as List).cast<num>()).map((v) => v.toDouble()).toList();
      } else if (raw is List && raw.first is List) {
        return (raw as List).expand((r) => (r as List).cast<num>()).map((v) => v.toDouble()).toList();
      }
      return (raw as List).cast<num>().map((v) => v.toDouble()).toList();
    } catch (_) {
      return List.filled(256 * 256, 0.0);
    }
  }

  static Uint8List _buildHeatmap(List<double> depth, int colormap) {
    double minV = depth.first, maxV = depth.first;
    for (final v in depth) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final range = maxV - minV;
    final gray = cv.Mat.zeros(256, 256, cv.MatType.CV_8UC1);
    for (int i = 0; i < depth.length; i++)
      gray.set<int>(i ~/ 256, i % 256,
          ((range > 0 ? (depth[i] - minV) / range : 0.5) * 255).round().clamp(0, 255));
    final colored = cv.applyColorMap(gray, colormap);
    gray.dispose();
    final (_, png) = cv.imencode('.png', colored);
    colored.dispose();
    return png;
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _ctrl?.dispose();
    _session?.release();
    OrtEnv.instance.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: Text(switch (_viewState) {
          _ViewState.preview  => 'Depth Estimation — MiDaS',
          _ViewState.analyzing => 'Đang phân tích...',
          _ViewState.result   => 'Kết quả depth',
        }),
        actions: [
          if (_viewState == _ViewState.result)
            TextButton(
              onPressed: _reset,
              child: const Text('Chụp lại', style: TextStyle(color: Colors.tealAccent)),
            ),
        ],
      ),
      body: _error.isNotEmpty ? _buildError() : switch (_viewState) {
        _ViewState.preview   => _buildPreview(),
        _ViewState.analyzing => _buildAnalyzing(),
        _ViewState.result    => _buildResult(),
      },
    );
  }

  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Text(_error, style: const TextStyle(color: Colors.redAccent)),
  ));

  // ── Preview ──────────────────────────────────────────────────────────────

  Widget _buildPreview() {
    if (!_cameraReady || _ctrl == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(children: [
      Positioned.fill(child: CameraPreview(_ctrl!)),

      // Model loading badge
      if (!_modelReady)
        Positioned(
          top: kToolbarHeight + MediaQuery.of(context).padding.top + 8,
          left: 0, right: 0,
          child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.tealAccent)),
              SizedBox(width: 8),
              Text('Đang tải model MiDaS (~64MB)...', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          )),
        ),

      // Bottom controls
      Positioned(
        left: 0, right: 0, bottom: 0,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            // Gallery
            _CircleBtn(
              icon: Icons.photo_library,
              onTap: _modelReady ? _pickAndAnalyze : null,
              label: 'Gallery',
            ),
            // Shutter
            GestureDetector(
              onTap: _modelReady ? _captureAndAnalyze : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _modelReady ? Colors.white : Colors.white30,
                  border: Border.all(color: Colors.tealAccent, width: 3),
                ),
                child: _modelReady
                    ? const Icon(Icons.camera_alt, color: Colors.black, size: 32)
                    : const Center(child: SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              ),
            ),
            // Placeholder for symmetry
            const SizedBox(width: 56),
          ]),
        ),
      ),
    ]);
  }

  // ── Analyzing ────────────────────────────────────────────────────────────

  Widget _buildAnalyzing() => const Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircularProgressIndicator(color: Colors.tealAccent),
      SizedBox(height: 20),
      Text('Đang chạy MiDaS...', style: TextStyle(color: Colors.white70, fontSize: 15)),
      SizedBox(height: 8),
      Text('(256×256 depth map)', style: TextStyle(color: Colors.white38, fontSize: 12)),
    ],
  ));

  // ── Result ───────────────────────────────────────────────────────────────

  Widget _buildResult() {
    final orig  = _originalPng;
    final depth = _depthPng;
    if (orig == null || depth == null) return const SizedBox.shrink();

    return Column(children: [
      // Image area
      Expanded(
        child: _showDepthOnly
            ? Image.memory(depth, fit: BoxFit.contain, gaplessPlayback: true)
            : Stack(children: [
                Positioned.fill(child: Image.memory(orig, fit: BoxFit.contain, gaplessPlayback: true)),
                Positioned.fill(
                  child: Opacity(
                    opacity: _alpha,
                    child: Image.memory(depth, fit: BoxFit.contain, gaplessPlayback: true),
                  ),
                ),
              ]),
      ),

      // Controls panel
      Container(
        color: Colors.black.withOpacity(0.85),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Toggle depth only
          Row(children: [
            const Text('Depth only', style: TextStyle(color: Colors.white60, fontSize: 13)),
            const Spacer(),
            Switch(
              value: _showDepthOnly,
              activeColor: Colors.tealAccent,
              onChanged: (v) => setState(() => _showDepthOnly = v),
            ),
          ]),

          // Opacity slider (hidden when depth-only)
          if (!_showDepthOnly) Row(children: [
            const Icon(Icons.layers, color: Colors.white38, size: 16),
            const SizedBox(width: 6),
            const Text('Opacity', style: TextStyle(color: Colors.white38, fontSize: 12)),
            Expanded(
              child: Slider(
                value: _alpha, min: 0.1, max: 1.0,
                activeColor: Colors.tealAccent,
                onChanged: (v) => setState(() => _alpha = v),
              ),
            ),
            Text('${(_alpha * 100).toInt()}%',
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ]),

          // Colormap chips
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
                  onSelected: (_) => _changeColormap(e.value),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Legend
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('← Xa', style: TextStyle(color: Colors.white38, fontSize: 11)),
            _LegendBar(_colormap),
            const Text('Gần →', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ]),
        ]),
      ),
    ]);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white12,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: onTap != null ? Colors.white : Colors.white30, size: 24),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(
        color: onTap != null ? Colors.white60 : Colors.white24, fontSize: 11)),
    ]),
  );
}

class _LegendBar extends StatelessWidget {
  const _LegendBar(this.colormap);
  final int colormap;

  @override
  Widget build(BuildContext context) => Container(
    width: 140, height: 10,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colormap == cv.COLORMAP_JET
            ? const [Colors.blue, Colors.cyan, Colors.green, Colors.yellow, Colors.red]
            : const [Colors.black, Colors.purple, Colors.deepOrange, Colors.yellow, Colors.white],
      ),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
