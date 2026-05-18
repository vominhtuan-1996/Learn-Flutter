import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Định nghĩa các trạng thái của từng bước trong Stepper.
enum AppProcessStepStatus {
  pending,    // Chờ xử lý (màu xám)
  processing, // Đang xử lý (xoay tròn)
  completed,  // Đã hoàn thành (dấu tích xanh)
  failed      // Thất bại (dấu X đỏ)
}

/// Cấu hình cho một bước xử lý trong quy trình.
class AppProcessStepConfig {
  final String title;
  
  /// Mô tả hiển thị khi đang chạy bước này.
  final String? processingSubtitle;

  /// Logic nghiệp vụ thực thi bước này. Trả về kết quả đầu ra.
  final Future<dynamic> Function() action;

  /// Xây dựng nội dung chi tiết (subtitle) hiển thị sau khi thành công dựa trên kết quả [action].
  final String Function(dynamic result)? subtitleBuilder;

  /// Trạng thái ban đầu của bước này (mặc định là [AppProcessStepStatus.pending]).
  final AppProcessStepStatus initialStatus;

  /// Kết quả ban đầu của bước này (nếu đã hoàn thành từ trước).
  final dynamic initialResult;

  const AppProcessStepConfig({
    required this.title,
    required this.action,
    this.processingSubtitle,
    this.subtitleBuilder,
    this.initialStatus = AppProcessStepStatus.pending,
    this.initialResult,
  });
}

/// Widget Stepper Tiến trình Đa bước động, dễ dàng tái sử dụng cho mọi quy trình.
class AppProcessStepperWidget extends StatefulWidget {
  final List<AppProcessStepConfig> steps;
  final String title;
  final String Function(List<dynamic> results)? summaryTitleBuilder;
  final List<String> Function(List<dynamic> results)? summaryNotesBuilder;
  final VoidCallback? onAllCompleted;

  const AppProcessStepperWidget({
    super.key,
    required this.steps,
    this.title = 'Tiến trình xử lý',
    this.summaryTitleBuilder,
    this.summaryNotesBuilder,
    this.onAllCompleted,
  });

  @override
  State<AppProcessStepperWidget> createState() => _AppProcessStepperWidgetState();
}

class _AppProcessStepperWidgetState extends State<AppProcessStepperWidget> {
  late List<AppProcessStepStatus> _statuses;
  late List<dynamic> _results;
  late List<String?> _subtitles;
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _statuses = widget.steps.map((s) => s.initialStatus).toList();
    _results = widget.steps.map((s) => s.initialResult).toList();
    _subtitles = widget.steps.map((s) {
      if (s.initialStatus == AppProcessStepStatus.completed && s.initialResult != null) {
        return s.subtitleBuilder?.call(s.initialResult) ?? '';
      }
      return null;
    }).toList();

    // Tự động chạy tiến trình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runNextPendingStep();
    });
  }

  /// Tìm bước đầu tiên đang pending để thực thi
  Future<void> _runNextPendingStep() async {
    if (_isProcessing) return;

    int nextIndex = -1;
    for (int i = 0; i < _statuses.length; i++) {
      if (_statuses[i] == AppProcessStepStatus.pending) {
        nextIndex = i;
        break;
      } else if (_statuses[i] == AppProcessStepStatus.failed) {
        // Gặp bước thất bại thì dừng lại chờ người dùng bấm Retry
        return;
      }
    }

    if (nextIndex == -1) {
      // Tất cả các bước đã hoàn thành
      widget.onAllCompleted?.call();
      return;
    }

    await _executeStep(nextIndex);
  }

  /// Thực thi một bước cụ thể theo index
  Future<void> _executeStep(int index) async {
    setState(() {
      _statuses[index] = AppProcessStepStatus.processing;
      _errorMessage = null;
      _isProcessing = true;
    });

    final step = widget.steps[index];
    try {
      final result = await step.action();
      if (!mounted) return;

      setState(() {
        _statuses[index] = AppProcessStepStatus.completed;
        _results[index] = result;
        _subtitles[index] = step.subtitleBuilder?.call(result);
        _isProcessing = false;
      });

      // Tự động chạy bước tiếp theo
      _runNextPendingStep();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statuses[index] = AppProcessStepStatus.failed;
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  /// Thử lại từ bước bị lỗi
  Future<void> _retryStep(int index) async {
    await _executeStep(index);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _statuses.any((s) => s == AppProcessStepStatus.failed);
    final isAllCompleted = _statuses.every((s) => s == AppProcessStepStatus.completed);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);
    final titleColor = isDark ? Colors.white : Colors.black87;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.blue.shade100).withOpacity(isDark ? 0.35 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tiêu đề quy trình
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                  fontSize: 15,
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: dividerColor),
  
            // Danh sách các bước Stepper
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.steps.length,
                itemBuilder: (context, index) {
                  return _buildStepItem(index, index == widget.steps.length - 1, isDark);
                },
              ),
            ),
  
            Divider(height: 1, thickness: 1, color: dividerColor),
  
            // Phần chân trang linh hoạt
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildFooterSection(hasError, isAllCompleted, isDark, dividerColor),
            ),
  
            Divider(height: 1, thickness: 1, color: dividerColor),
  
            // Nút Đóng phía dưới cùng
            if (!_isProcessing)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Center(
                  child: SizedBox(
                    width: 100,
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                      ),
                      child: Text(
                        'Đóng',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87, 
                          fontSize: 13, 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Render từng item trong hàng đợi tiến trình
  Widget _buildStepItem(int index, bool isLast, bool isDark) {
    final step = widget.steps[index];
    final status = _statuses[index];
    final subtitle = _subtitles[index];

    Color stepColor = status == AppProcessStepStatus.failed
        ? Colors.red
        : (status == AppProcessStepStatus.pending 
            ? (isDark ? const Color(0xFF475569) : Colors.grey.shade400) 
            : const Color(0xFF3B82F6));

    final textTitleColor = status == AppProcessStepStatus.failed
        ? Colors.red.shade400
        : (status == AppProcessStepStatus.pending 
            ? (isDark ? const Color(0xFF64748B) : Colors.grey.shade600) 
            : (isDark ? Colors.white : Colors.black87));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cột bên trái hiển thị Icon và đường nối tuyến tính
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: status == AppProcessStepStatus.processing
                      ? Colors.transparent
                      : (status == AppProcessStepStatus.failed 
                          ? Colors.red 
                          : const Color(0xFF3B82F6).withOpacity(0.5)),
                  width: 1,
                ),
              ),
              child: Center(
                child: _buildAnimatedIcon(status, index, isDark),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 24,
                color: stepColor.withOpacity(0.4),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Cột bên phải hiển thị Text (Tiêu đề + Subtitle của bước)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textTitleColor,
                      ),
                    ),
                  ),
                  if (status == AppProcessStepStatus.failed)
                    GestureDetector(
                      onTap: () => _retryStep(index),
                      child: const Text(
                        ' Thử lại',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              if (subtitle != null || status == AppProcessStepStatus.processing)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Text(
                    status == AppProcessStepStatus.processing
                        ? (step.processingSubtitle ?? 'Đang xử lý...')
                        : subtitle ?? '',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }

  /// Tạo animated icon tương ứng với trạng thái
  Widget _buildAnimatedIcon(AppProcessStepStatus status, int index, bool isDark) {
    final activeBlue = const Color(0xFF3B82F6);
    switch (status) {
      case AppProcessStepStatus.completed:
        return Icon(Icons.check, size: 14, color: activeBlue);
      case AppProcessStepStatus.processing:
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(activeBlue),
          ),
        );
      case AppProcessStepStatus.failed:
        return const Icon(Icons.close, size: 14, color: Colors.red);
      case AppProcessStepStatus.pending:
        return Text(
          '${index + 1}',
          style: TextStyle(
            color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500, 
            fontSize: 10, 
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  /// Render Footer Section dựa trên trạng thái chung
  Widget _buildFooterSection(bool hasError, bool isAllCompleted, bool isDark, Color dividerColor) {
    if (_isProcessing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Center(
          child: Text(
            'Vui lòng không đóng popup khi đang xử lý.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ),
      );
    } else if (hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Center(
          child: Text(
            _errorMessage ?? 'Đã xảy ra lỗi thực thi bước này.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.red.shade400,
              fontSize: 11,
            ),
          ),
        ),
      );
    } else if (isAllCompleted) {
      final summaryTitle = widget.summaryTitleBuilder?.call(_results) ?? 'Đã hoàn thành toàn bộ tiến trình';
      final summaryNotes = widget.summaryNotesBuilder?.call(_results) ?? [];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summaryTitle,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            if (summaryNotes.isNotEmpty) ...[
              const SizedBox(height: 6),
              ...summaryNotes.asMap().entries.map((entry) {
                final idx = entry.key;
                final note = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          note,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (idx * 100).ms).slideX(begin: 0.05, end: 0);
              }),
            ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
