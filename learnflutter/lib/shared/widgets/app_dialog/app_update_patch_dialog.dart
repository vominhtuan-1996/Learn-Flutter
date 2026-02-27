import 'dart:async';
import 'package:flutter/material.dart';

/// [AppUpdatePatchDialog] là một widget hộp thoại được thiết kế theo phong cách hiện đại (Premium UI).
/// Nó được sử dụng để thông báo cho người dùng về các bản cập nhật nóng (Hot Patch/Code Push).
/// Giao diện bao gồm một phần đầu trang rực rỡ với Gradient, biểu tượng minh họa sống động,
/// và một khu vực hiển thị nội dung thay đổi (Changelog) cực kỳ chuyên nghiệp.
/// Đặc biệt, widget này tích hợp [Progress Button] và hỗ trợ [Automation Simulation].
class AppUpdatePatchDialog extends StatefulWidget {
  final String version;
  final List<String> changelog;
  final double progress; // Giá trị từ 0.0 đến 1.0
  final bool isDownloading;
  final VoidCallback onUpdate;
  final bool showSimulator;
  final bool autoSimulate;

  const AppUpdatePatchDialog({
    super.key,
    required this.version,
    required this.changelog,
    required this.onUpdate,
    this.progress = 0.0,
    this.isDownloading = false,
    this.showSimulator = false,
    this.autoSimulate = false,
  });

  @override
  State<AppUpdatePatchDialog> createState() => _AppUpdatePatchDialogState();
}

class _AppUpdatePatchDialogState extends State<AppUpdatePatchDialog> {
  late double _currentProgress;
  late bool _isDownloading;
  Timer? _automationTimer;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.progress;
    _isDownloading = widget.isDownloading;

    // Nếu được yêu cầu tự động mô phỏng ngay từ đầu
    if (_isDownloading && widget.autoSimulate) {
      _startAutomation();
    }
  }

  @override
  void dispose() {
    _automationTimer?.cancel();
    super.dispose();
  }

  /// [ _startAutomation] thực hiện tự động tăng tiến trình tải xuống để mô phỏng.
  void _startAutomation() {
    _automationTimer?.cancel();
    _automationTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentProgress += 0.01; // Tăng 1% mỗi 50ms
        if (_currentProgress >= 1.0) {
          _currentProgress = 1.0;
          timer.cancel();
          _isDownloading = false;
          debugPrint('✅ Cập nhật hoàn tất!');
          // Có thể thêm delay rồi tự động đóng dialog hoặc thông báo hoàn tất
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header: Gradient rực rỡ với Icon minh họa
          _buildHeader(),

          // 2. Nội dung: Thông tin phiên bản và Changelog
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bản cập nhật mới',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'v${widget.version}',
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Có gì mới trong bản vá này?',
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                // Danh sách Changelog cuộn được nếu quá dài
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.changelog.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                widget.changelog[index],
                                style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Nút hành động Chính tích hợp Progress
                _buildProgressButton(),

                const SizedBox(height: 12),

                // 4. Simulator Slider & Điều khiển phụ
                if (_isDownloading) ...[
                  // const Divider(),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text('Mô phỏng trình tải (Slider):', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  //     if (!widget.autoSimulate)
                  //       IconButton(
                  //         onPressed: _startAutomation,
                  //         icon: const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 20),
                  //         tooltip: 'Bắt đầu tự động',
                  //       ),
                  //   ],
                  // ),
                  // Slider(
                  //   value: _currentProgress,
                  //   min: 0.0,
                  //   max: 1.0,
                  //   activeColor: Colors.blueAccent,
                  //   onChanged: (value) {
                  //     _automationTimer?.cancel();
                  //     setState(() {
                  //       _currentProgress = value;
                  //     });
                  //   },
                  // ),
                  // Center(
                  //   child: TextButton(
                  //     onPressed: () => Navigator.pop(context),
                  //     child: const Text('Đóng mô phỏng', style: TextStyle(color: Colors.redAccent)),
                  //   ),
                  // ),
                ] else if (!_isDownloading)
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressButton() {
    return GestureDetector(
      onTap: () {
        if (!_isDownloading) {
          setState(() {
            _isDownloading = true;
          });
          if (widget.showSimulator || widget.autoSimulate) {
            _startAutomation();
          }
          widget.onUpdate();
        }
      },
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isDownloading ? Colors.blueAccent.withOpacity(0.1) : Colors.blueAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Thanh tiến trình chạy ngầm trong nút
            if (_isDownloading)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FractionallySizedBox(
                  widthFactor: _currentProgress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      ),
                    ),
                  ),
                ),
              ),

            // Nội dung Text chính
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isDownloading ? 'Đang tải: ${(_currentProgress * 100).toInt()}%' : 'Cập nhật ngay',
                  key: ValueKey(_isDownloading),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _isDownloading ? const Color(0xFF2575FC) : Colors.white,
                  ),
                ),
              ),
            ),

            // Hiệu ứng Shimmer mờ khi đang tải
            if (_isDownloading && _currentProgress < 1.0)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const Opacity(
                    opacity: 0.1,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
          ),
          Positioned(
            left: 20,
            bottom: -30,
            child: CircleAvatar(radius: 40, backgroundColor: Colors.white.withOpacity(0.1)),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.auto_awesome_motion, color: Colors.white, size: 48),
            ),
          ),
        ],
      ),
    );
  }
}
