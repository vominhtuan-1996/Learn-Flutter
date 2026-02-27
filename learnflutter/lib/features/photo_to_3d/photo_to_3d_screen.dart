import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:learnflutter/shared/widgets/depth_3d_viewer.dart';

/// [ConverterMode] định nghĩa hai phương thức chuyển đổi ảnh 2D sang 3D.
enum ConverterMode {
  cloud, // Sử dụng Cloud AI để dựng mô hình .glb (Yêu cầu mạng)
  offline // Sử dụng Depth Map & Parallax (Offline hoàn toàn)
}

/// [PhotoTo3DScreen] là màn hình đa năng hỗ trợ cả hai giải pháp 3D hiện đại nhất.
/// Cho phép người dùng chọn lựa giữa việc dựng mô hình 3D thực thụ (Cloud)
/// hoặc tạo hiệu ứng chiều sâu Parallax (Offline) ngay trên thiết bị.
class PhotoTo3DScreen extends StatefulWidget {
  final XFile imageFile;

  const PhotoTo3DScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<PhotoTo3DScreen> createState() => _PhotoTo3DScreenState();
}

class _PhotoTo3DScreenState extends State<PhotoTo3DScreen> {
  bool _isProcessing = true;
  double _progress = 0.0;
  Timer? _timer;

  /// Chế độ mặc định là Cloud, người dùng có thể chuyển sang Offline qua UI.
  ConverterMode _mode = ConverterMode.cloud;

  /// [Flutter3DController] dùng để điều khiển mô hình 3D sau khi "xử lý" xong.
  final Flutter3DController _modelCtrl = Flutter3DController();

  @override
  void initState() {
    super.initState();
    _startSimulatedProcessing();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// [_startSimulatedProcessing] khởi chạy luồng xử lý giả lập.
  /// Nếu là Offline, tiến trình sẽ chạy nhanh hơn (vì xử lý trên chip cục bộ).
  void _startSimulatedProcessing() {
    setState(() {
      _isProcessing = true;
      _progress = 0.0;
    });
    _timer?.cancel();

    final interval = _mode == ConverterMode.offline ? 50 : 100;
    final increment = _mode == ConverterMode.offline ? 0.05 : 0.025;

    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 1.0) {
          _progress += increment;
        } else {
          _timer?.cancel();
          _isProcessing = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('2D to 3D AI Studio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Nút chuyển đổi chế độ Cloud/Offline ngay trên AppBar
          TextButton.icon(
            onPressed: _isProcessing
                ? null
                : () {
                    setState(() {
                      _mode = _mode == ConverterMode.cloud
                          ? ConverterMode.offline
                          : ConverterMode.cloud;
                      _startSimulatedProcessing();
                    });
                  },
            icon: Icon(
              _mode == ConverterMode.cloud ? Icons.cloud_done : Icons.vibration,
              color: Colors.blueAccent,
              size: 18,
            ),
            label: Text(
              _mode == ConverterMode.cloud ? 'Cloud mode' : 'Offline mode',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: _isProcessing ? _buildProcessingUI() : _buildViewerUI(),
        ),
      ),
    );
  }

  /// [_buildProcessingUI] thay đổi thông điệp dựa trên chế độ người dùng chọn.
  Widget _buildProcessingUI() {
    final title = _mode == ConverterMode.cloud
        ? 'Dựng mô hình .GLB bằng Cloud AI...'
        : 'Đang trích xuất Depth Map Offline...';

    final subTitle = _mode == ConverterMode.cloud
        ? 'Máy chủ đang tái cấu trúc Mesh và Texture 3D'
        : 'Chip NPU đang phân tích cấu trúc chiều sâu ảnh';

    return Column(
      key: ValueKey('processing_${_mode.name}'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent, width: 2),
            image: DecorationImage(
              image: FileImage(File(widget.imageFile.path)),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
          ),
          child: SpinKitPulse(color: Colors.blueAccent, size: 60),
        ),
        const SizedBox(height: 40),
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          subTitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.white10,
            color: Colors.blueAccent,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 10),
        Text('${(_progress * 100).toInt()}%',
            style: const TextStyle(color: Colors.blueAccent)),
      ],
    );
  }

  /// [_buildViewerUI] hiển thị kết quả tương ứng với chế độ đã chọn.
  Widget _buildViewerUI() {
    return Column(
      key: ValueKey('viewer_${_mode.name}'),
      children: [
        Expanded(
          child: _mode == ConverterMode.cloud
              ? _buildCloudViewer()
              : _buildOfflineDepthViewer(),
        ),
        _buildBottomStatus(),
      ],
    );
  }

  /// Hiển thị mô hình 3D thực thụ (GLB) - Kết quả từ Cloud.
  Widget _buildCloudViewer() {
    return Flutter3DViewer(
      controller: _modelCtrl,
      src: 'assets/3d/business_man.glb',
    );
  }

  /// Hiển thị hiệu ứng Parallax (Offline) - Sử dụng Depth3DViewer.
  /// Để mô phỏng, ta sử dụng Stack với hai lớp ảnh có độ mờ/màu sắc khác nhau.
  Widget _buildOfflineDepthViewer() {
    final imageFile = File(widget.imageFile.path);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Depth3DViewer(
        depth: 30.0,
        // Lớp Nền: Thường được xử lý mờ hơn (Blur) để tăng cảm giác xa
        backgroundImage: Opacity(
          opacity: 0.6,
          child: Image.file(imageFile, fit: BoxFit.cover),
        ),
        // Lớp Chủ thể: Giữ nguyên độ sắc nét
        foregroundImage: Image.file(imageFile, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildBottomStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _mode == ConverterMode.cloud
                    ? Icons.auto_awesome
                    : Icons.layers,
                color: Colors.greenAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _mode == ConverterMode.cloud
                    ? '3D Model Reconstruction complete!'
                    : 'Depth Map Parallax ready!',
                style: const TextStyle(
                    color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Hoàn tất và Quay lại'),
          ),
        ],
      ),
    );
  }
}
