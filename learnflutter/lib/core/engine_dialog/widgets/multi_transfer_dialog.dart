import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Loại truyền tải dữ liệu
enum AppTransferType {
  download,
  upload,
}

/// Cấu hình cho từng file trong danh sách tải xuống/tải lên
class AppTransferFileConfig {
  final String name;
  final double sizeInMB;

  /// Hành động thực tế để download/upload file này.
  /// Cung cấp một callback `onProgress(double percent)` nhận giá trị từ `0.0` đến `1.0`.
  final Future<void> Function(void Function(double progress) onProgress) transferAction;

  const AppTransferFileConfig({
    required this.name,
    required this.sizeInMB,
    required this.transferAction,
  });
}

/// Widget Dialog truyền tải nhiều tệp cùng lúc (Multi-file Download/Upload)
class AppMultiTransferDialog extends StatefulWidget {
  final List<AppTransferFileConfig> files;
  final AppTransferType type;
  final String title;
  final VoidCallback? onCompleted;
  final VoidCallback? onCanceled;

  const AppMultiTransferDialog({
    super.key,
    required this.files,
    required this.type,
    this.title = 'Truyền tải dữ liệu',
    this.onCompleted,
    this.onCanceled,
  });

  @override
  State<AppMultiTransferDialog> createState() => _AppMultiTransferDialogState();
}

class _AppMultiTransferDialogState extends State<AppMultiTransferDialog> {
  late List<double> _progresses;
  late List<bool> _isCompleted;
  late List<bool> _isFailed;
  late List<String?> _errorMessages;
  
  bool _isCanceled = false;
  bool _isRunning = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _progresses = List.filled(widget.files.length, 0.0);
    _isCompleted = List.filled(widget.files.length, false);
    _isFailed = List.filled(widget.files.length, false);
    _errorMessages = List.filled(widget.files.length, null);

    // Tự động bắt đầu tải tệp đầu tiên sau khi giao diện sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTransferQueue();
    });
  }

  /// Quản lý việc chạy tuần tự danh sách các tệp
  Future<void> _startTransferQueue() async {
    if (_isRunning || _isCanceled) return;
    setState(() {
      _isRunning = true;
    });

    for (int i = 0; i < widget.files.length; i++) {
      if (_isCanceled) break;
      
      // Nếu file này đã completed (từ lần trước), bỏ qua
      if (_isCompleted[i]) continue;
      
      _currentIndex = i;
      
      // Chạy tiến trình cho file hiện tại
      await _transferFile(i);
    }

    if (!mounted) return;
    setState(() {
      _isRunning = false;
    });

    // Nếu tất cả đã hoàn thành mà không bị hủy
    final allSuccess = _isCompleted.every((completed) => completed);
    if (allSuccess && !_isCanceled) {
      widget.onCompleted?.call();
    }
  }

  /// Thử lại riêng các tệp bị lỗi
  Future<void> _retryFailedTransfers() async {
    if (_isRunning || _isCanceled) return;
    setState(() {
      _isRunning = true;
    });

    for (int i = 0; i < widget.files.length; i++) {
      if (_isCanceled) break;
      
      // Chỉ chạy lại những tệp có trạng thái lỗi
      if (_isFailed[i]) {
        _currentIndex = i;
        setState(() {
          _isFailed[i] = false;
          _errorMessages[i] = null;
          _progresses[i] = 0.0;
        });
        await _transferFile(i);
      }
    }

    if (!mounted) return;
    setState(() {
      _isRunning = false;
    });

    // Nếu tất cả đã hoàn thành mà không bị hủy
    final allSuccess = _isCompleted.every((completed) => completed);
    if (allSuccess && !_isCanceled) {
      widget.onCompleted?.call();
    }
  }

  /// Chạy truyền tải cho một file cụ thể
  Future<void> _transferFile(int index) async {
    final file = widget.files[index];
    
    try {
      await file.transferAction((progress) {
        if (_isCanceled || !mounted) return;
        setState(() {
          // Chuẩn hóa progress trong khoảng 0.0 -> 1.0
          _progresses[index] = progress.clamp(0.0, 1.0);
          if (progress >= 1.0) {
            _isCompleted[index] = true;
          }
        });
      });

      if (mounted && !_isCanceled) {
        setState(() {
          _isCompleted[index] = true;
          _progresses[index] = 1.0;
        });
      }
    } catch (e) {
      if (mounted && !_isCanceled) {
        setState(() {
          _isFailed[index] = true;
          _isCompleted[index] = false;
          _errorMessages[index] = e.toString();
        });
      }
    }
  }

  /// Tính toán phần trăm tổng thể
  double get _totalProgress {
    if (widget.files.isEmpty) return 0.0;
    double sum = _progresses.reduce((value, element) => value + element);
    return sum / widget.files.length;
  }

  /// Tính tổng dung lượng đã tải
  double get _totalTransferredMB {
    double sum = 0.0;
    for (int i = 0; i < widget.files.length; i++) {
      sum += widget.files[i].sizeInMB * _progresses[i];
    }
    return sum;
  }

  /// Tổng kích thước của toàn bộ tệp
  double get _totalSizeMB {
    return widget.files.fold(0.0, (prev, element) => prev + element.sizeInMB);
  }

  /// Số lượng file đã hoàn thành
  int get _completedCount {
    return _isCompleted.where((completed) => completed).length;
  }

  /// Hủy bỏ toàn bộ tiến trình
  void _cancelTransfer() {
    setState(() {
      _isCanceled = true;
      _isRunning = false;
    });
    widget.onCanceled?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasFailed = _isFailed.any((failed) => failed);
    final isAllDone = _completedCount == widget.files.length;
    final isDone = isAllDone || _isCanceled;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final themeColor = widget.type == AppTransferType.download ? const Color(0xFF3B82F6) : const Color(0xFF8B5CF6);
    final themeBg = widget.type == AppTransferType.download 
        ? (isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFEFF6FF)) 
        : (isDark ? const Color(0xFF4C1D95).withOpacity(0.3) : const Color(0xFFF5F3FF));
        
    final totalProgressPercent = (_totalProgress * 100).toInt();

    // Dark mode color tokens
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subTitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);
    final cardBgColor = isDark ? const Color(0xFF334155) : const Color(0xFFF9FAFB);
    final cardBorderColor = isDark ? const Color(0xFF475569) : const Color(0xFFF3F4F6);
    final barBgColor = isDark ? const Color(0xFF475569) : const Color(0xFFE5E7EB);
    final itemTextColor = isDark ? Colors.white : const Color(0xFF374151);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: themeColor.withOpacity(isDark ? 0.35 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Icon + Title
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: themeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.type == AppTransferType.download 
                          ? Icons.cloud_download_rounded 
                          : Icons.cloud_upload_rounded,
                      color: themeColor,
                      size: 24,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                   .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: titleColor,
                          ),
                        ),
                        Text(
                          isAllDone 
                              ? 'Đã hoàn tất truyền tải dữ liệu' 
                              : '${widget.type == AppTransferType.download ? "Đang tải xuống" : "Đang tải lên"} • $_completedCount / ${widget.files.length} tệp',
                          style: TextStyle(
                            fontSize: 12,
                            color: subTitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
    
              // Total Progress Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$totalProgressPercent%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: themeColor,
                          ),
                        ),
                        Text(
                          '${_totalTransferredMB.toStringAsFixed(1)} MB / ${_totalSizeMB.toStringAsFixed(1)} MB',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _totalProgress,
                        minHeight: 8,
                        backgroundColor: barBgColor,
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
    
              // File List
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.files.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final file = widget.files[index];
                    final progress = _progresses[index];
                    final completed = _isCompleted[index];
                    final failed = _isFailed[index];
                    final isActive = _isRunning && _currentIndex == index && !completed && !failed;
    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? themeBg.withOpacity(0.5) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? themeColor.withOpacity(0.2) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Status Icon
                          _buildFileStatusIcon(completed, failed, isActive, themeColor, isDark),
                          const SizedBox(width: 12),
                          // File Info & Mini Progress
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        file.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isActive || completed ? FontWeight.bold : FontWeight.normal,
                                          color: itemTextColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      failed 
                                          ? 'Lỗi' 
                                          : '${(progress * 100).toInt()}% • ${file.sizeInMB} MB',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: failed ? Colors.red : subTitleColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isActive || (progress > 0 && !completed && !failed)) ...[
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 4,
                                      backgroundColor: cardBorderColor,
                                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
    
              // Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Nút Hủy hiển thị khi đang chạy hoặc chưa xong toàn bộ
                  if (!isDone)
                    OutlinedButton(
                      onPressed: _cancelTransfer,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: subTitleColor,
                        side: BorderSide(color: cardBorderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        'Hủy bỏ',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  
                  // NÚT RETRY FAILED ONLY: Xuất hiện nếu có file lỗi và hệ thống đang tạm dừng
                  if (hasFailed && !_isRunning) ...[
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _retryFailedTransfers,
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B), // Màu Cam Warning
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      label: const Text(
                        'Thử lại file lỗi',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: subTitleColor,
                        side: BorderSide(color: cardBorderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                  
                  // Nút Hoàn tất hiển thị khi đã xong sạch sẽ toàn bộ
                  if (isAllDone)
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: const Text(
                        'Hoàn tất',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ).animate().scale(duration: 250.ms, curve: Curves.easeOutBack),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileStatusIcon(bool completed, bool failed, bool isActive, Color themeColor, bool isDark) {
    if (completed) {
      return const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
          .animate().scale(duration: 200.ms);
    }
    if (failed) {
      return const Icon(Icons.error_rounded, color: Colors.red, size: 20)
          .animate().shake(duration: 300.ms);
    }
    if (isActive) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
        ),
      );
    }
    return Icon(
      Icons.insert_drive_file_outlined, 
      color: isDark ? const Color(0xFF475569) : const Color(0xFF9CA3AF), 
      size: 20,
    );
  }
}
