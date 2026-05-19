// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learnflutter/core/services/camera/model/camera_mode.dart';
import 'package:learnflutter/core/services/camera/widgets/camera_bottom_controls.dart';
import 'package:learnflutter/core/services/camera/widgets/camera_gallery_preview.dart';
import 'package:learnflutter/core/services/camera/widgets/camera_mode_selector.dart';
import 'package:learnflutter/core/services/camera/widgets/camera_top_bar.dart';
import 'package:learnflutter/core/services/camera/widgets/camera_zoom_slider.dart';
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
  final double? minZoom;
  final double? maxZoom;
  final int? maxLength;
  final int? maxleght;
  final List<CameraMode>? modes;

  const CameraScreen({
    super.key,
    this.initialMode = CameraMode.photo,
    this.onPhotoCaptured,
    this.onVideoRecorded,
    this.minZoom,
    this.maxZoom,
    this.maxLength,
    this.maxleght,
    this.modes,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

/// [_CameraScreenState] sử dụng mixin [WidgetsBindingObserver] để lắng nghe
/// sự thay đổi vòng đời của ứng dụng. Điều này cần thiết vì camera là tài nguyên
/// phần cứng, nếu không giải phóng khi app vào nền sẽ gây lỗi và tốn pin.
class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  int? get _effectiveMaxLength => widget.maxLength ?? widget.maxleght;
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
  final List<XFile> _capturedPhotos = [];
  Duration _recDur = Duration.zero;
  Timer? _timer;

  bool _showGalleryPreview = false;
  int _galleryIndex = 0;
  int? _retakeIndex;
  late PageController _pageController;

  XFile? _imgFile;
  XFile? _vFile;
  VideoPlayerController? _vCtrl;
  FlashMode _flash = FlashMode.auto;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final modesList = widget.modes ?? const [CameraMode.photo, CameraMode.video];
    if (modesList.contains(widget.initialMode)) {
      _mode = widget.initialMode;
    } else if (modesList.isNotEmpty) {
      _mode = modesList.first;
    } else {
      _mode = CameraMode.photo;
    }
    WidgetsBinding.instance.addObserver(this);
    _initCameras();
  }

  /// [dispose] giải phóng toàn bộ tài nguyên nặng khi widget bị xóa khỏi cây.
  /// Việc hủy [_ctrl], [_vCtrl] và [_timer] ở đây là bắt buộc để tránh memory leak,
  /// đặc biệt khi camera stream và timer vẫn đang chạy ngầm trong nền.
  @override
  void dispose() {
    _pageController.dispose();
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
      final hardwareMin = await c.getMinZoomLevel();
      final hardwareMax = await c.getMaxZoomLevel();

      _minZ = widget.minZoom != null ? widget.minZoom!.clamp(hardwareMin, hardwareMax) : hardwareMin;
      _maxZ = widget.maxZoom != null ? widget.maxZoom!.clamp(_minZ, hardwareMax) : hardwareMax;

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
    if (ctrl == null || !ctrl.value.isInitialized || ctrl.value.isTakingPicture) return;
    try {
      final f = await ctrl.takePicture();
      if (_retakeIndex != null) {
        final oldIdx = _retakeIndex!;
        setState(() {
          _capturedPhotos[oldIdx] = f;
          _imgFile = f;
          _retakeIndex = null;
          _showGalleryPreview = true;
          _galleryIndex = oldIdx;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(oldIdx);
          }
        });
        _showSnack('Đã cập nhật lại ảnh số ${oldIdx + 1}');
      } else {
        setState(() {
          _capturedPhotos.add(f);
          _imgFile = f;
          _vFile = null;
        });
        widget.onPhotoCaptured?.call(f);

        if (_effectiveMaxLength != null && _capturedPhotos.length >= _effectiveMaxLength!) {
          if (mounted) {
            Navigator.of(context).pop(_capturedPhotos);
          }
          return;
        }
      }
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
        if (mounted) {
          setState(() => _recDur += const Duration(seconds: 1));
        }
      });
      setState(() {
        _recording = true;
        _vFile = null;
        _imgFile = null;
        _capturedPhotos.clear();
      });
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
        if (mounted) {
          setState(() => _recDur += const Duration(seconds: 1));
        }
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
        _vFile = f;
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
                CameraTopBar(
                  mode: _mode,
                  isRecording: _recording,
                  isPaused: _paused,
                  recDuration: _recDur,
                  flashIcon: _flashIcon,
                  onFlashTap: _cycleFlash,
                  onFlipTap: _flipCam,
                  onCloseTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                if (_retakeIndex != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber[900]?.withOpacity(0.9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          '⚡ Đang chụp lại ảnh số ${_retakeIndex! + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _retakeIndex = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                // Mode selector + zoom slider + nút chụp/quay
                CameraModeSelector(
                  currentMode: _mode,
                  allowedModes: widget.modes ?? const [CameraMode.photo, CameraMode.video],
                  isRecording: _recording,
                  onModeChanged: (newMode) {
                    setState(() => _mode = newMode);
                  },
                ),
                CameraZoomSlider(
                  currentZoom: _curZ,
                  minZoom: _minZ,
                  maxZoom: _maxZ,
                  onZoomChanged: (v) async {
                    setState(() => _curZ = v);
                    await _ctrl?.setZoomLevel(v);
                  },
                ),
                CameraBottomControls(
                  mode: _mode,
                  isRecording: _recording,
                  isPaused: _paused,
                  imgFile: _imgFile,
                  videoPlayerController: _vCtrl,
                  capturedPhotos: _capturedPhotos,
                  videoFile: _vFile,
                  onThumbnailTap: () {
                    if (_mode == CameraMode.photo && _capturedPhotos.isNotEmpty) {
                      setState(() {
                        _galleryIndex = _capturedPhotos.length - 1;
                        _showGalleryPreview = true;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_pageController.hasClients) {
                          _pageController.jumpToPage(_capturedPhotos.length - 1);
                        }
                      });
                    }
                  },
                  onCaptureTap: _mode == CameraMode.photo
                      ? _takePicture
                      : (_recording ? _stopRec : _startRec),
                  onPauseResumeTap: _paused ? _resumeRec : _pauseRec,
                  onConfirmTap: () {
                    if (_mode == CameraMode.photo) {
                      Navigator.of(context).pop(_capturedPhotos);
                    } else {
                      Navigator.of(context).pop(_vFile);
                    }
                  },
                ),
              ],
            ),
          ),

          // Layer 3: Gallery preview pageview overlay
          CameraGalleryPreview(
            show: _showGalleryPreview,
            photos: _capturedPhotos,
            currentIndex: _galleryIndex,
            controller: _pageController,
            onPageChanged: (idx) {
              setState(() {
                _galleryIndex = idx;
              });
            },
            onCloseTap: () {
              setState(() {
                _showGalleryPreview = false;
              });
            },
            onRetakeTap: (idx) {
              setState(() {
                _retakeIndex = idx;
                _showGalleryPreview = false;
              });
              _showSnack('Vui lòng chụp lại để thế chỗ ảnh số ${idx + 1}');
            },
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
}
