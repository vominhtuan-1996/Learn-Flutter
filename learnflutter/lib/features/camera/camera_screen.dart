// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/features/camera/model/camera_mode.dart';
import 'package:video_player/video_player.dart';

/// [CameraScreen] là màn hình camera tái sử dụng được thiết kế để hoạt động độc lập
/// với bất kỳ màn hình nào trong ứng dụng. Widget nhận [initialMode] để xác định
/// chế độ mặc định khi khởi động, đồng thời cung cấp hai callback để truyền kết quả
/// chụp ảnh hoặc video ra ngoài mà không cần phụ thuộc vào state management cụ thể.
/// Thiết kế này đảm bảo tính linh hoạt và khả năng tái sử dụng tối đa.
class CameraScreen extends StatefulWidget {
  final CameraMode initialMode;
  final void Function(XFile)? onPhotoCaptured;
  final void Function(XFile)? onVideoRecorded;

  const CameraScreen({
    super.key,
    this.initialMode = CameraMode.photo,
    this.onPhotoCaptured,
    this.onVideoRecorded,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

/// [_CameraScreenState] sử dụng mixin [WidgetsBindingObserver] để lắng nghe
/// sự thay đổi vòng đời của ứng dụng. Điều này cần thiết vì camera là tài nguyên
/// phần cứng, nếu không giải phóng khi app vào nền sẽ gây lỗi và tốn pin.
class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _ctrl;
  int _camIdx = 0;

  /// Bốn biến zoom lưu trữ ngưỡng min/max do phần cứng cung cấp, giá trị hiện tại,
  /// và giá trị gốc lúc bắt đầu cử chỉ pinch. [_pointers] đếm số ngón tay đang
  /// chạm màn hình và chỉ cho phép zoom khi có đúng 2 ngón, tránh xung đột với tap.
  double _minZ = 1, _maxZ = 1, _curZ = 1, _baseZ = 1;
  int _pointers = 0;

  late CameraMode _mode;
  bool _recording = false, _paused = false;
  Duration _recDur = Duration.zero;
  Timer? _timer;

  XFile? _imgFile;
  VideoPlayerController? _vCtrl;
  FlashMode _flash = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  /// [dispose] giải phóng toàn bộ tài nguyên nặng khi widget bị xóa khỏi cây.
  /// Việc hủy [_ctrl], [_vCtrl] và [_timer] ở đây là bắt buộc để tránh memory leak,
  /// đặc biệt khi camera stream và timer vẫn đang chạy ngầm trong nền.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl?.dispose();
    _vCtrl?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// [didChangeAppLifecycleState] xử lý việc giải phóng và tái khởi tạo camera
  /// theo vòng đời ứng dụng. Khi app chuyển sang trạng thái inactive (bị che khuất
  /// hoặc nhận cuộc gọi), camera cần được giải phóng ngay để tránh xung đột quyền
  /// truy cập phần cứng. Khi resumed, camera được khởi tạo lại từ đầu.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_ctrl == null || !_ctrl!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _ctrl!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCtrl(_cameras[_camIdx]);
    }
  }

  /// [_initCameras] lấy danh sách tất cả camera vật lý khả dụng trên thiết bị
  /// rồi khởi tạo camera đầu tiên trong danh sách, thường là camera sau (back).
  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) await _initCtrl(_cameras[0]);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  /// [_initCtrl] tạo [CameraController] với [ResolutionPreset.high] để đảm bảo
  /// chất lượng ảnh/video. Sau khi initialize, lấy ngưỡng zoom thực tế từ phần cứng
  /// qua [Future.wait] để chạy song song, giảm thời gian khởi động. [_curZ] được
  /// reset về [_minZ] mỗi lần đổi camera để tránh giữ zoom không hợp lệ.
  Future<void> _initCtrl(CameraDescription desc) async {
    final prev = _ctrl;
    if (prev != null) await prev.dispose();

    final c = CameraController(
      desc,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _ctrl = c;
    c.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await c.initialize();
      await Future.wait([
        c.getMinZoomLevel().then((v) => _minZ = v),
        c.getMaxZoomLevel().then((v) => _maxZ = v),
      ]);
      _curZ = _minZ;
    } catch (e) {
      debugPrint('Controller init error: $e');
    }

    if (mounted) setState(() {});
  }

  // ─── Zoom ─────────────────────────────────────────────────────

  void _onScaleStart(ScaleStartDetails d) => _baseZ = _curZ;

  /// [_onScaleUpdate] tính zoom bằng cách nhân [_baseZ] với tỉ lệ scale của gesture,
  /// sau đó clamp trong khoảng [_minZ, _maxZ] để không vượt giới hạn phần cứng.
  /// Chỉ xử lý khi [_pointers] bằng đúng 2 để tránh kích hoạt nhầm khi chỉ dùng 1 ngón.
  Future<void> _onScaleUpdate(ScaleUpdateDetails d) async {
    if (_ctrl == null || _pointers != 2) return;
    _curZ = (_baseZ * d.scale).clamp(_minZ, _maxZ);
    await _ctrl!.setZoomLevel(_curZ);
    if (mounted) setState(() {});
  }

  // ─── Photo ────────────────────────────────────────────────────

  /// [_takePicture] chụp ảnh và lưu kết quả vào [_imgFile] để hiển thị thumbnail.
  /// Callback [onPhotoCaptured] được gọi ngay sau đó để màn hình cha có thể xử lý
  /// file ảnh theo nghiệp vụ riêng mà không cần CameraScreen biết chi tiết.
  Future<void> _takePicture() async {
    final ctrl = _ctrl;
    if (ctrl == null || !ctrl.value.isInitialized || ctrl.value.isTakingPicture)
      return;
    try {
      final f = await ctrl.takePicture();
      setState(() => _imgFile = f);
      widget.onPhotoCaptured?.call(f);
    } catch (e) {
      _showSnack('Lỗi chụp ảnh: $e');
    }
  }

  // ─── Video ────────────────────────────────────────────────────

  /// [_startRec] bắt đầu quay video và khởi động [Timer] đếm giây mỗi giây một lần.
  /// Timer cập nhật [_recDur] liên tục để widget hiển thị đồng hồ thời gian quay
  /// theo thời gian thực, giúp người dùng kiểm soát độ dài của video.
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

  /// [_stopRec] dừng quay, trả về [XFile] chứa đường dẫn file video trên thiết bị.
  /// Sau đó khởi tạo [VideoPlayerController] để phát lại ngay trong thumbnail,
  /// giúp người dùng xem lại video vừa quay mà không cần rời khỏi màn hình camera.
  Future<void> _stopRec() async {
    try {
      final f = await _ctrl?.stopVideoRecording();
      _timer?.cancel();
      if (f == null) return;
      setState(() {
        _recording = false;
        _paused = false;
      });
      widget.onVideoRecorded?.call(f);

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

  // ─── Flash & Flip ─────────────────────────────────────────────

  /// [_cycleFlash] xoay vòng qua 3 chế độ đèn flash theo thứ tự auto → on → off.
  /// Dùng Map thay vì if-else để code ngắn gọn và dễ bổ sung chế độ mới sau này.
  Future<void> _cycleFlash() async {
    final next = {
      FlashMode.auto: FlashMode.always,
      FlashMode.always: FlashMode.off,
      FlashMode.off: FlashMode.auto,
    }[_flash]!;
    await _ctrl?.setFlashMode(next);
    setState(() => _flash = next);
  }

  /// [_flipCam] chuyển đổi giữa camera trước và camera sau bằng cách tăng index
  /// theo vòng tròn. Mỗi lần đổi sẽ khởi tạo lại [CameraController] với camera mới,
  /// đảm bảo preview cập nhật đúng nguồn hình ảnh từ phần cứng tương ứng.
  Future<void> _flipCam() async {
    if (_cameras.length < 2) return;
    _camIdx = (_camIdx + 1) % _cameras.length;
    await _initCtrl(_cameras[_camIdx]);
  }

  // ─── Helpers ──────────────────────────────────────────────────

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
      '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  IconData get _flashIcon => {
        FlashMode.auto: Icons.flash_auto,
        FlashMode.always: Icons.flash_on,
        FlashMode.off: Icons.flash_off,
        FlashMode.torch: Icons.flashlight_on,
      }[_flash]!;

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
          // Layer 1: Camera preview full screen
          _buildPreview(),

          // Layer 2: SafeArea bọc toàn bộ controls overlay
          SafeArea(
            child: Column(
              children: [
                // Top bar: đóng / đồng hồ / flash / flip
                _buildTopBar(),
                const Spacer(),
                // Mode selector + zoom slider + nút chụp/quay
                _buildModeSelector(),
                _buildZoomSlider(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Vùng preview chiếm toàn bộ màn hình và bọc bởi [Listener] + [GestureDetector]
  /// để theo dõi số ngón tay ([_pointers]) và xử lý cử chỉ pinch zoom đồng thời.
  /// [CircularProgressIndicator] hiện trong lúc camera đang khởi tạo chưa xong.
  Widget _buildPreview() {
    final ctrl = _ctrl;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return Listener(
      onPointerDown: (_) => _pointers++,
      onPointerUp: (_) => _pointers--,
      child: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        child: CameraPreview(ctrl),
      ),
    );
  }

  /// Thanh điều khiển trên cùng chứa nút đóng, đồng hồ đếm thời gian quay,
  /// nút flash và nút lật camera. Đồng hồ chỉ hiển thị khi [_recording] là true
  /// để không chiếm không gian UI khi không cần thiết.
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút đóng có nền mờ để dễ nhìn trên preview
          _circleIconButton(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
          ),
          if (_recording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, color: Colors.white, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    _fmt(_recDur),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
          Row(
            children: [
              _circleIconButton(icon: _flashIcon, onTap: _cycleFlash),
              const SizedBox(width: 8),
              _circleIconButton(icon: Icons.flip_camera_ios, onTap: _flipCam),
            ],
          ),
        ],
      ),
    );
  }

  /// [SegmentedButton] cho phép người dùng chuyển đổi giữa chế độ Ảnh và Video.
  /// Khi đang quay video, việc đổi chế độ bị chặn để tránh xung đột với stream.
  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SegmentedButton<CameraMode>(
        style: SegmentedButton.styleFrom(
          foregroundColor: Colors.white,
          selectedForegroundColor: Colors.black,
          selectedBackgroundColor: Colors.white,
          backgroundColor: Colors.black38,
          side: const BorderSide(color: Colors.white54),
        ),
        segments: const [
          ButtonSegment(
            value: CameraMode.photo,
            label: Text('Ảnh'),
            icon: Icon(Icons.photo_camera),
          ),
          ButtonSegment(
            value: CameraMode.video,
            label: Text('Video'),
            icon: Icon(Icons.videocam),
          ),
        ],
        selected: {_mode},
        onSelectionChanged: (s) {
          if (!_recording) setState(() => _mode = s.first);
        },
      ),
    );
  }

  /// Thanh slider zoom chỉ hiển thị khi thiết bị hỗ trợ zoom ([_maxZ] > [_minZ]).
  /// Người dùng có thể dùng slider thay cho pinch gesture, cả hai đều cập nhật
  /// [_curZ] và gọi [setZoomLevel] để đồng bộ với phần cứng camera.
  Widget _buildZoomSlider() {
    if (_maxZ <= _minZ) return const SizedBox.shrink();
    return Row(
      children: [
        const SizedBox(width: 8),
        const Icon(Icons.zoom_out, color: Colors.white70, size: 20),
        Expanded(
          child: Slider(
            value: _curZ,
            min: _minZ,
            max: _maxZ,
            activeColor: Colors.white,
            inactiveColor: Colors.white24,
            onChanged: (v) async {
              setState(() => _curZ = v);
              await _ctrl?.setZoomLevel(v);
            },
          ),
        ),
        const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
        SizedBox(
          width: 42,
          child: Text(
            '${_curZ.toStringAsFixed(1)}x',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Thanh điều khiển dưới cùng gồm thumbnail kết quả, nút capture chính,
  /// và nút pause/resume chỉ xuất hiện khi đang ở chế độ video và đang quay.
  /// Nút capture thay đổi hình dạng (tròn → vuông bo góc) để biểu thị trạng thái recording.
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildThumbnail(),
          _buildCaptureButton(),
          if (_mode == CameraMode.video && _recording)
            _circleIconButton(
              icon: _paused ? Icons.play_arrow : Icons.pause,
              size: 28,
              onTap: _paused ? _resumeRec : _pauseRec,
            )
          else
            const SizedBox(width: 52),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    Widget? child;
    if (_imgFile != null && _mode == CameraMode.photo) {
      child = kIsWeb
          ? Image.network(_imgFile!.path, fit: BoxFit.cover)
          : Image.file(File(_imgFile!.path), fit: BoxFit.cover);
    } else if (_vCtrl != null && _mode == CameraMode.video) {
      child = VideoPlayer(_vCtrl!);
    }
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white70, width: 1.5),
        color: Colors.black45,
      ),
      clipBehavior: Clip.hardEdge,
      child: child ?? const Icon(Icons.photo, color: Colors.white30),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _mode == CameraMode.photo
          ? _takePicture
          : (_recording ? _stopRec : _startRec),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: _recording ? Colors.red : Colors.transparent,
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

  /// [_circleIconButton] nút icon tròn có nền mờ đen, dùng cho top bar và pause button
  /// để đảm bảo khả năng nhìn thấy rõ trên bất kỳ nền camera nào.
  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 22,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
