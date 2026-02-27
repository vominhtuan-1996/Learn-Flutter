---
description: Quy trình xây dựng màn hình AR Kit mô phỏng 3D overlay lên camera khi đang record video
---

# ARKit Screen Workflow

> **Approach**: Dùng `camera` preview full-screen + `flutter_3d_controller` để render model `.glb` overlay lên camera. Khi record, model 3D tiếp tục hiển thị. iOS-only nếu dùng `arkit_plugin`; cross-platform nếu dùng stack overlay.

---

## Bước 1 – Dependency

`pubspec.yaml` (đã có sẵn):
```yaml
camera: ^0.11.0+2
video_player: ^2.9.2
flutter_3d_controller: ^2.2.0
path_provider: ^2.1.5
path: ^1.9.0
```

Assets (đã có sẵn):
```yaml
assets:
  - assets/3d/business_man.glb
```

---

## Bước 2 – ARKitScreen

`lib/features/ar_kit/arkit_screen.dart`:

```dart
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// [ARKitScreen] mô phỏng trải nghiệm AR bằng cách overlay model 3D lên
/// camera preview theo thời gian thực. Widget sử dụng Stack 2 layer: layer dưới
/// là CameraPreview full-screen, layer trên là model GLB render bằng Flutter3DViewer.
/// Khi người dùng nhấn record, camera bắt đầu ghi video trong khi model 3D vẫn
/// hiển thị liên tục, tạo cảm giác AR thực sự trên thiết bị.
class ARKitScreen extends StatefulWidget {
  const ARKitScreen({super.key});
  @override
  State<ARKitScreen> createState() => _ARKitScreenState();
}

class _ARKitScreenState extends State<ARKitScreen> with WidgetsBindingObserver {
  CameraController? _ctrl;
  List<CameraDescription> _cameras = [];

  /// [Flutter3DController] điều khiển model 3D: chọn animation, reset, v.v.
  /// Controller này độc lập với camera, cho phép animation chạy liên tục
  /// kể cả khi camera đang trong trạng thái recording.
  final Flutter3DController _modelCtrl = Flutter3DController();

  bool _recording = false;
  bool _paused = false;
  Duration _recDur = Duration.zero;
  Timer? _timer;
  XFile? _vidFile;
  VideoPlayerController? _vCtrl;

  /// [_modelScale] cho phép người dùng phóng to/thu nhỏ model 3D overlay
  /// bằng cử chỉ pinch trực tiếp lên vùng model, tách biệt với zoom camera.
  double _modelScale = 1.0;
  double _baseScale = 1.0;

  /// [_modelOffset] lưu vị trí model khi người dùng kéo trên màn hình.
  /// Dùng [Offset] thay vì top/left để dễ áp dụng với [Positioned].
  Offset _modelOffset = const Offset(0, 0);
  Offset _dragStart = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose();
    _vCtrl?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_ctrl == null || !_ctrl!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) _ctrl!.dispose();
    else if (state == AppLifecycleState.resumed) _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    final c = CameraController(_cameras[0], ResolutionPreset.high, enableAudio: true);
    _ctrl = c;
    c.addListener(() { if (mounted) setState(() {}); });
    await c.initialize();
    if (mounted) setState(() {});
  }

  // ─── Record ───────────────────────────────────────────────────

  Future<void> _startRec() async {
    await _ctrl?.startVideoRecording();
    _recDur = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recDur += const Duration(seconds: 1));
    });
    setState(() => _recording = true);
  }

  Future<void> _pauseRec() async {
    await _ctrl?.pauseVideoRecording();
    _timer?.cancel();
    setState(() => _paused = true);
  }

  Future<void> _resumeRec() async {
    await _ctrl?.resumeVideoRecording();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recDur += const Duration(seconds: 1));
    });
    setState(() => _paused = false);
  }

  Future<void> _stopRec() async {
    final f = await _ctrl?.stopVideoRecording();
    _timer?.cancel();
    if (f == null) return;
    setState(() { _recording = false; _paused = false; _vidFile = f; });
    final vCtrl = VideoPlayerController.file(File(f.path));
    _vCtrl = vCtrl;
    await vCtrl.initialize();
    await vCtrl.setLooping(true);
    await vCtrl.play();
    if (mounted) setState(() {});
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
      '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Camera preview full screen
          _buildCameraPreview(),

          // Layer 2: Model 3D draggable + scalable overlay
          _buildDraggableModel(),

          // Layer 3: UI controls overlay
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Camera preview fill toàn màn hình, là nền AR.
  Widget _buildCameraPreview() {
    if (_ctrl == null || !_ctrl!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return CameraPreview(_ctrl!);
  }

  /// [_buildDraggableModel] render model 3D GLB tại vị trí [_modelOffset] trên màn hình.
  /// GestureDetector kết hợp pan (kéo) và scale (pinch) để người dùng tự đặt
  /// và điều chỉnh kích thước model AR tùy ý trong không gian camera preview.
  Widget _buildDraggableModel() {
    final size = MediaQuery.of(context).size;
    final modelSize = 200.0 * _modelScale;

    return Positioned(
      left: (size.width / 2 - modelSize / 2) + _modelOffset.dx,
      top: (size.height / 2 - modelSize / 2) + _modelOffset.dy,
      width: modelSize,
      height: modelSize,
      child: GestureDetector(
        onScaleStart: (d) => _baseScale = _modelScale,
        onScaleUpdate: (d) {
          setState(() {
            _modelScale = (_baseScale * d.scale).clamp(0.3, 5.0);
            if (d.pointerCount == 1) {
              _modelOffset += d.focalPointDelta;
            }
          });
        },
        child: Flutter3DViewer(
          controller: _modelCtrl,
          src: 'assets/3d/business_man.glb',
          activeGestureInterceptor: false,
        ),
      ),
    );
  }

  /// Thanh điều khiển trên: nút đóng, đồng hồ record, animation picker, reset model.
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _pill(child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          )),
          const Spacer(),
          if (_recording)
            _pill(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.circle, color: Colors.red, size: 10),
                const SizedBox(width: 4),
                Text(_fmt(_recDur), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]),
            )),
          const Spacer(),
          _pill(child: IconButton(
            icon: const Icon(Icons.rotate_left, color: Colors.white, size: 20),
            onPressed: () {
              setState(() { _modelOffset = Offset.zero; _modelScale = 1.0; });
            },
          )),
        ],
      ),
    );
  }

  /// Thanh điều khiển dưới: thumbnail video, nút record chính, pause.
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Thumbnail video sau khi dừng record
          _buildThumbnail(),

          // Nút record chính
          GestureDetector(
            onTap: _recording ? _stopRec : _startRec,
            child: Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: _recording ? Colors.red : Colors.transparent,
              ),
              child: Center(child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _recording ? 28 : 56,
                height: _recording ? 28 : 56,
                decoration: BoxDecoration(
                  color: _recording ? Colors.red[800] : Colors.white,
                  borderRadius: BorderRadius.circular(_recording ? 6 : 28),
                ),
              )),
            ),
          ),

          // Pause / Resume khi đang record
          if (_recording)
            _pill(child: IconButton(
              icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: Colors.white, size: 28),
              onPressed: _paused ? _resumeRec : _pauseRec,
            ))
          else
            const SizedBox(width: 52),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 62, height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white70, width: 1.5),
        color: Colors.black45,
      ),
      clipBehavior: Clip.hardEdge,
      child: _vCtrl != null
          ? VideoPlayer(_vCtrl!)
          : const Icon(Icons.videocam, color: Colors.white30),
    );
  }

  /// [_pill] là container nền đen mờ bo góc, dùng để bọc các nút điều khiển
  /// đảm bảo dễ nhìn trên bất kỳ nền camera màu nào.
  Widget _pill({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(color: Colors.black45, child: child),
    );
  }
}
```

---

## Bước 3 – Route

`lib/shared/widgets/routes/route.dart`:
```dart
// import
import 'package:learnflutter/features/ar_kit/arkit_screen.dart';

// constant
static const String arkitScreen = 'arkit_screen';

// generateRoute
case Routes.arkitScreen:
  return SlideRightRoute(
    routeSettings: RouteSettings(name: Routes.arkitScreen),
    builder: (_) => const ARKitScreen(),
  );
```

---

## Bước 4 – TestScreen

```dart
TextButton(
  onPressed: () => Navigator.of(context).pushNamed(Routes.arkitScreen),
  child: const Text('AR Kit – 3D Model on Camera'),
),
```

---

## Ghi chú mở rộng

- **Đổi model**: thêm `.glb` vào `assets/3d/` → truyền qua constructor
- **Animation**: `_modelCtrl.playAnimation(animationName: 'Run')`
- **ARKit thật (iOS-only)**: uncomment `arkit_plugin` trong pubspec, chỉ chạy trên device thật
