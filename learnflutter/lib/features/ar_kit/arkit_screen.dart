// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:video_player/video_player.dart';

/// [ARKitScreen] mô phỏng trải nghiệm AR bằng cách overlay model 3D lên
/// camera preview theo thời gian thực. Widget sử dụng Stack 3 layer: layer dưới
/// là CameraPreview full-screen, layer giữa là model GLB render bằng Flutter3DViewer,
/// và layer trên là SafeArea chứa các nút điều khiển record/pause/close.
/// Khi người dùng nhấn record, camera bắt đầu ghi video trong khi model 3D vẫn
/// hiển thị liên tục, tạo cảm giác AR thực sự trên thiết bị.
class ARKitScreen extends StatefulWidget {
  /// [modelAssetPath] cho phép truyền đường dẫn model 3D khác nhau từ màn hình gọi,
  /// mặc định sử dụng model business_man.glb đã có sẵn trong assets dự án.
  final String modelAssetPath;

  const ARKitScreen({
    super.key,
    this.modelAssetPath = 'assets/3d/business_man.glb',
  });

  @override
  State<ARKitScreen> createState() => _ARKitScreenState();
}

/// [_ARKitScreenState] sử dụng [WidgetsBindingObserver] để giải phóng camera
/// khi app chuyển sang nền, tránh xung đột với các ứng dụng khác sử dụng camera.
class _ARKitScreenState extends State<ARKitScreen> with WidgetsBindingObserver {
  CameraController? _ctrl;
  List<CameraDescription> _cameras = [];

  /// [Flutter3DController] điều khiển model 3D: chọn animation, reset, play/pause.
  /// Controller này hoàn toàn độc lập với camera, cho phép animation 3D chạy
  /// liên tục kể cả khi camera đang trong trạng thái recording video.
  final Flutter3DController _modelCtrl = Flutter3DController();

  bool _recording = false;
  bool _paused = false;
  Duration _recDur = Duration.zero;
  Timer? _timer;
  VideoPlayerController? _vCtrl;

  /// [_modelScale] và [_baseScale] lưu tỉ lệ phóng to/thu nhỏ model 3D overlay.
  /// [_baseScale] được lưu tại lúc bắt đầu gesture để tính delta scale chính xác,
  /// tránh hiện tượng model nhảy cóc khi bắt đầu mỗi lần pinch mới.
  double _modelScale = 1.0;
  double _baseScale = 1.0;

  /// [_modelOffset] lưu vị trí lệch của model 3D so với tâm màn hình.
  /// Dùng [Offset] thay vì top/left để dễ cộng dồn delta pan từ gesture.
  Offset _modelOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  /// [dispose] giải phóng tất cả tài nguyên: camera controller, video player,
  /// và timer đếm giây để tránh memory leak khi widget bị xóa khỏi widget tree.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose();
    _vCtrl?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// [didChangeAppLifecycleState] xử lý vòng đời ứng dụng để camera hoạt động
  /// đúng cách khi app bị che khuất hoặc quay trở lại foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_ctrl == null || !_ctrl!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _ctrl!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  /// [_initCamera] khởi tạo camera đầu tiên (back camera) với [ResolutionPreset.high]
  /// và bật audio để ghi âm đồng thời khi quay video AR.
  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;
      final prev = _ctrl;
      if (prev != null) await prev.dispose();
      final c = CameraController(
        _cameras[0],
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _ctrl = c;
      c.addListener(() {
        if (mounted) setState(() {});
      });
      await c.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  // ─── Record ───────────────────────────────────────────────────

  /// [_startRec] bắt đầu quay video và khởi động Timer đếm giây.
  /// Model 3D tiếp tục render trong suốt quá trình recording vì [Flutter3DViewer]
  /// hoạt động độc lập với [CameraController] trên Widget tree.
  Future<void> _startRec() async {
    try {
      await _ctrl?.startVideoRecording();
      _recDur = Duration.zero;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recDur += const Duration(seconds: 1));
      });
      setState(() => _recording = true);
    } catch (e) {
      _showSnack('Lỗi bắt đầu quay: $e');
    }
  }

  Future<void> _pauseRec() async {
    try {
      await _ctrl?.pauseVideoRecording();
      _timer?.cancel();
      setState(() => _paused = true);
    } catch (e) {
      _showSnack('Lỗi pause: $e');
    }
  }

  Future<void> _resumeRec() async {
    try {
      await _ctrl?.resumeVideoRecording();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recDur += const Duration(seconds: 1));
      });
      setState(() => _paused = false);
    } catch (e) {
      _showSnack('Lỗi resume: $e');
    }
  }

  /// [_stopRec] dừng quay và khởi tạo [VideoPlayerController] để phát lại ngay
  /// trong thumbnail, giúp người dùng xem lại mà không cần rời khỏi màn hình AR.
  Future<void> _stopRec() async {
    try {
      final f = await _ctrl?.stopVideoRecording();
      _timer?.cancel();
      if (f == null) return;
      setState(() {
        _recording = false;
        _paused = false;
      });
      await _vCtrl?.dispose();
      final vCtrl = VideoPlayerController.file(File(f.path));
      _vCtrl = vCtrl;
      await vCtrl.initialize();
      await vCtrl.setLooping(true);
      await vCtrl.play();
      if (mounted) setState(() {});
    } catch (e) {
      _showSnack('Lỗi dừng quay: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
      '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Camera preview full screen — nền AR
          _buildCameraPreview(),

          // Layer 2: Model 3D draggable + pinch scalable
          _buildDraggableModel(),

          // Layer 3: UI controls overlay (top + bottom)
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

  /// [_buildCameraPreview] hiển thị live camera stream chiếm toàn màn hình.
  /// Khi camera chưa khởi tạo xong, hiển thị vòng chờ màu trắng trên nền đen
  /// để người dùng biết ứng dụng đang trong quá trình khởi động phần cứng.
  Widget _buildCameraPreview() {
    final ctrl = _ctrl;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return CameraPreview(ctrl);
  }

  /// [_buildDraggableModel] render model 3D GLB có thể kéo (pan) và phóng to (pinch).
  /// [Positioned] đặt model tại vị trí tâm màn hình cộng [_modelOffset] để hỗ trợ drag.
  /// [GestureDetector] xử lý đồng thời 2 gesture: pan 1 ngón để di chuyển,
  /// pinch 2 ngón để thay đổi scale; cả hai không ảnh hưởng đến camera phía dưới.
  Widget _buildDraggableModel() {
    final size = MediaQuery.of(context).size;
    final modelSize = 200.0 * _modelScale;
    final left = (size.width / 2 - modelSize / 2) + _modelOffset.dx;
    final top = (size.height / 2 - modelSize / 2) + _modelOffset.dy;

    return Positioned(
      left: left,
      top: top,
      width: modelSize,
      height: modelSize,
      child: GestureDetector(
        onScaleStart: (_) => _baseScale = _modelScale,
        onScaleUpdate: (d) {
          setState(() {
            _modelScale = (_baseScale * d.scale).clamp(0.3, 5.0);
            if (d.pointerCount == 1) _modelOffset += d.focalPointDelta;
          });
        },
        child: Flutter3DViewer(
          controller: _modelCtrl,
          src: widget.modelAssetPath,
          activeGestureInterceptor: false,
        ),
      ),
    );
  }

  /// Thanh trên cùng chứa nút đóng (trái), badge thời gian record (giữa),
  /// và nút reset vị trí/scale model (phải). Tất cả nút dùng pill nền đen mờ
  /// để hiển thị rõ ràng trên bất kỳ màu nền camera nào.
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _pill(
              child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          )),
          const Spacer(),
          if (_recording)
            _pill(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.circle, color: Colors.red, size: 10),
                const SizedBox(width: 4),
                Text(
                  _fmt(_recDur),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ]),
            )),
          const Spacer(),
          _pill(
              child: IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            tooltip: 'Reset vị trí model',
            onPressed: () => setState(() {
              _modelOffset = Offset.zero;
              _modelScale = 1.0;
            }),
          )),
        ],
      ),
    );
  }

  /// Thanh dưới cùng gồm thumbnail video, nút record chính và nút pause/resume.
  /// Padding bottom 32 đảm bảo nút không bị che bởi home indicator trên iOS.
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildThumbnail(),
          _buildRecordButton(),
          if (_recording)
            _pill(
                child: IconButton(
              icon: Icon(
                _paused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _paused ? _resumeRec : _pauseRec,
            ))
          else
            const SizedBox(width: 52),
        ],
      ),
    );
  }

  /// Thumbnail hiển thị video phát lại sau khi dừng record, hoặc icon mặc định
  /// khi chưa có video nào được ghi. [VideoPlayer] chạy loop trong thumbnail
  /// để người dùng xem lại AR video ngay trên màn hình camera.
  Widget _buildThumbnail() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white70, width: 1.5),
        color: Colors.black45,
      ),
      clipBehavior: Clip.hardEdge,
      child: _vCtrl != null && _vCtrl!.value.isInitialized
          ? VideoPlayer(_vCtrl!)
          : const Icon(Icons.videocam, color: Colors.white30, size: 28),
    );
  }

  /// Nút record chính: hình tròn viền trắng, phần trong chuyển từ tròn trắng
  /// (chờ) sang vuông bo góc đỏ (đang quay) với animation 200ms mượt mà.
  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: _recording ? _stopRec : _startRec,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: _recording ? Colors.red.withOpacity(0.3) : Colors.transparent,
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _recording ? 28 : 56,
            height: _recording ? 28 : 56,
            decoration: BoxDecoration(
              color: _recording ? Colors.red[800] : Colors.white,
              borderRadius: BorderRadius.circular(_recording ? 6 : 28),
            ),
          ),
        ),
      ),
    );
  }

  /// [_pill] là container nền đen mờ bo góc dùng để bọc các nút điều khiển overlay.
  /// Thiết kế này đảm bảo các nút luôn dễ nhìn dù camera đang hướng vào
  /// bất kỳ cảnh nào: sáng, tối, hay nhiều màu sắc phức tạp.
  Widget _pill({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(color: Colors.black45, child: child),
    );
  }
}
