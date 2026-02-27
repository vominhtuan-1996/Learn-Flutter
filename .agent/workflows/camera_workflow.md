---
description: Quy trình xây dựng màn hình Camera với zoom in/out, chế độ video/takephoto, có thể tái sử dụng từ các màn hình khác
---

# Camera Screen Workflow

## Bước 1 – Dependency & Quyền

`pubspec.yaml`:
```yaml
camera: ^0.11.0+2
video_player: ^2.9.2
path_provider: ^2.1.5
path: ^1.9.0
```

`ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key><string>Cần quyền camera</string>
<key>NSMicrophoneUsageDescription</key><string>Cần quyền micro</string>
```

`AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

---

## Bước 2 – CameraMode enum

`lib/features/camera/model/camera_mode.dart`:
```dart
enum CameraMode { photo, video }
```

---

## Bước 3 – CameraScreen

`lib/features/camera/camera_screen.dart`:

```dart
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/features/camera/model/camera_mode.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  final CameraMode initialMode;
  final void Function(XFile)? onPhotoCaptured;
  final void Function(XFile)? onVideoRecorded;
  const CameraScreen({super.key, this.initialMode = CameraMode.photo, this.onPhotoCaptured, this.onVideoRecorded});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _ctrl;
  int _camIdx = 0;
  double _minZ = 1, _maxZ = 1, _curZ = 1, _baseZ = 1;
  int _pointers = 0;
  late CameraMode _mode;
  bool _recording = false, _paused = false;
  Duration _recDur = Duration.zero;
  Timer? _timer;
  XFile? _imgFile, _vidFile;
  VideoPlayerController? _vCtrl;
  FlashMode _flash = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
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
    else if (state == AppLifecycleState.resumed) _initCtrl(_cameras[_camIdx]);
  }

  Future<void> _initCameras() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) await _initCtrl(_cameras[0]);
  }

  Future<void> _initCtrl(CameraDescription desc) async {
    final c = CameraController(desc, ResolutionPreset.high, enableAudio: true);
    _ctrl = c;
    c.addListener(() { if (mounted) setState(() {}); });
    await c.initialize();
    await Future.wait([c.getMinZoomLevel().then((v) => _minZ = v), c.getMaxZoomLevel().then((v) => _maxZ = v)]);
    _curZ = _minZ;
    if (mounted) setState(() {});
  }

  void _onScaleStart(ScaleStartDetails d) => _baseZ = _curZ;
  Future<void> _onScaleUpdate(ScaleUpdateDetails d) async {
    if (_ctrl == null || _pointers != 2) return;
    _curZ = (_baseZ * d.scale).clamp(_minZ, _maxZ);
    await _ctrl!.setZoomLevel(_curZ);
    if (mounted) setState(() {});
  }

  Future<void> _takePicture() async {
    if (_ctrl == null || !_ctrl!.value.isInitialized) return;
    final f = await _ctrl!.takePicture();
    setState(() => _imgFile = f);
    widget.onPhotoCaptured?.call(f);
  }

  Future<void> _startRec() async {
    await _ctrl?.startVideoRecording();
    _recDur = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => _recDur += const Duration(seconds: 1)); });
    setState(() => _recording = true);
  }

  Future<void> _pauseRec() async {
    await _ctrl?.pauseVideoRecording();
    _timer?.cancel();
    setState(() => _paused = true);
  }

  Future<void> _resumeRec() async {
    await _ctrl?.resumeVideoRecording();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => _recDur += const Duration(seconds: 1)); });
    setState(() => _paused = false);
  }

  Future<void> _stopRec() async {
    final f = await _ctrl?.stopVideoRecording();
    _timer?.cancel();
    if (f == null) return;
    setState(() { _recording = false; _paused = false; _vidFile = f; });
    widget.onVideoRecorded?.call(f);
    _vCtrl = VideoPlayerController.file(File(f.path));
    await _vCtrl!.initialize();
    await _vCtrl!.setLooping(true);
    await _vCtrl!.play();
    if (mounted) setState(() {});
  }

  Future<void> _cycleFlash() async {
    final next = {FlashMode.auto: FlashMode.always, FlashMode.always: FlashMode.off, FlashMode.off: FlashMode.auto}[_flash]!;
    await _ctrl?.setFlashMode(next);
    setState(() => _flash = next);
  }

  Future<void> _flipCam() async {
    if (_cameras.length < 2) return;
    _camIdx = (_camIdx + 1) % _cameras.length;
    await _initCtrl(_cameras[_camIdx]);
  }

  String _fmt(Duration d) => '${d.inMinutes.remainder(60).toString().padLeft(2,'0')}:${d.inSeconds.remainder(60).toString().padLeft(2,'0')}';
  IconData get _flashIcon => {FlashMode.auto: Icons.flash_auto, FlashMode.always: Icons.flash_on, FlashMode.off: Icons.flash_off, FlashMode.torch: Icons.flashlight_on}[_flash]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Column(children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
            if (_recording)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: Text(_fmt(_recDur), style: const TextStyle(color: Colors.white)),
              ),
            Row(children: [
              IconButton(icon: Icon(_flashIcon, color: Colors.white), onPressed: _cycleFlash),
              IconButton(icon: const Icon(Icons.flip_camera_ios, color: Colors.white), onPressed: _flipCam),
            ]),
          ]),
        ),
        // Preview + pinch zoom
        Expanded(
          child: _ctrl?.value.isInitialized == true
            ? Listener(
                onPointerDown: (_) => _pointers++,
                onPointerUp: (_) => _pointers--,
                child: GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  child: CameraPreview(_ctrl!),
                ),
              )
            : const Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
        // Mode selector
        SegmentedButton<CameraMode>(
          style: SegmentedButton.styleFrom(foregroundColor: Colors.white, selectedBackgroundColor: Colors.white, selectedForegroundColor: Colors.black, side: const BorderSide(color: Colors.white54)),
          segments: const [
            ButtonSegment(value: CameraMode.photo, label: Text('Ảnh'), icon: Icon(Icons.photo_camera)),
            ButtonSegment(value: CameraMode.video, label: Text('Video'), icon: Icon(Icons.videocam)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) { if (!_recording) setState(() => _mode = s.first); },
        ),
        // Zoom slider
        if (_maxZ > _minZ) Row(children: [
          const Icon(Icons.zoom_out, color: Colors.white70),
          Expanded(child: Slider(
            value: _curZ, min: _minZ, max: _maxZ, activeColor: Colors.white, inactiveColor: Colors.white24,
            onChanged: (v) async { setState(() => _curZ = v); await _ctrl?.setZoomLevel(v); },
          )),
          const Icon(Icons.zoom_in, color: Colors.white70),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('${_curZ.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ]),
        // Bottom controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white54), color: Colors.black45),
              clipBehavior: Clip.hardEdge,
              child: _imgFile != null && _mode == CameraMode.photo
                ? Image.file(File(_imgFile!.path), fit: BoxFit.cover)
                : _vCtrl != null && _mode == CameraMode.video
                  ? VideoPlayer(_vCtrl!)
                  : const Icon(Icons.photo, color: Colors.white38),
            ),
            GestureDetector(
              onTap: _mode == CameraMode.photo ? _takePicture : (_recording ? _stopRec : _startRec),
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), color: _recording ? Colors.red : Colors.transparent),
                child: Center(child: Container(
                  width: _recording ? 28 : 56, height: _recording ? 28 : 56,
                  decoration: BoxDecoration(color: _recording ? Colors.red[800] : Colors.white, borderRadius: BorderRadius.circular(_recording ? 6 : 28)),
                )),
              ),
            ),
            if (_mode == CameraMode.video && _recording)
              IconButton(icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: Colors.white, size: 32), onPressed: _paused ? _resumeRec : _pauseRec)
            else
              const SizedBox(width: 48),
          ]),
        ),
      ])),
    );
  }
}
```

---

## Bước 4 – Route

`lib/shared/widgets/routes/route.dart`:
```dart
// import
import 'package:learnflutter/features/camera/camera_screen.dart';
import 'package:learnflutter/features/camera/model/camera_mode.dart';

// constant
static const String cameraScreen = '/camera_screen';

// generateRoute
case Routes.cameraScreen:
  final args = settings.arguments as Map<String, dynamic>?;
  return SlideRightRoute(
    routeSettings: RouteSettings(name: Routes.cameraScreen),
    builder: (_) => CameraScreen(
      initialMode: args?['mode'] ?? CameraMode.photo,
      onPhotoCaptured: args?['onPhotoCaptured'],
      onVideoRecorded: args?['onVideoRecorded'],
    ),
  );
```

---

## Bước 5 – TestScreen & Tái sử dụng

**Thêm vào TestScreen:**
```dart
TextButton(
  onPressed: () => Navigator.of(context).pushNamed(Routes.cameraScreen, arguments: {'mode': CameraMode.photo}),
  child: const Text('Camera Screen (Zoom + Photo/Video)'),
),
```

**Gọi từ màn hình khác (qua route):**
```dart
Navigator.of(context).pushNamed(Routes.cameraScreen, arguments: {
  'mode': CameraMode.video,
  'onVideoRecorded': (XFile file) { /* xử lý */ },
});
```

**Gọi trực tiếp:**
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => CameraScreen(
    initialMode: CameraMode.photo,
    onPhotoCaptured: (XFile file) { /* xử lý */ },
  ),
));
```
