import 'package:flutter/material.dart';
import 'package:learnflutter/core/engine_dialog/models/dialog_config.dart';
import 'package:learnflutter/core/engine_dialog/widgets/dialog_base_widget.dart';
import 'package:learnflutter/core/engine_dialog/widgets/process_stepper_widget.dart';
import 'package:learnflutter/core/engine_dialog/widgets/multi_transfer_dialog.dart';
import 'package:learnflutter/shared/widgets/highlighted_text.dart';

/// AppDialogEngine – Engine trung tâm để hiển thị tất cả loại dialog.
///
/// Sử dụng [showGeneralDialog] với hiệu ứng Scale + Fade để tạo cảm giác premium.
class AppDialogEngine {
  AppDialogEngine._();

  // ────────────────────────────────────────────
  // Public shortcut methods
  // ────────────────────────────────────────────

  /// Hiển thị dialog thông báo (màu xanh dương).
  static Future<void> showInfo(
    BuildContext context, {
    String title = 'Thông báo',
    required String message,
    Widget? contentWidget,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showCancelButton = false,
    bool barrierDismissible = true,
  }) {
    return show(
      context,
      config: AppDialogConfig(
        title: title,
        message: message,
        type: AppDialogType.info,
        contentWidget: contentWidget,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCancelButton: showCancelButton,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Hiển thị dialog thông báo với nội dung có chứa từ khóa được highlight (nhấn mạnh).
  static Future<void> showHighlightMessage(
    BuildContext context, {
    String title = 'Thông báo',
    required String message,
    required Map<String, TextStyle> highlights,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showCancelButton = false,
    bool barrierDismissible = true,
  }) {
    return show(
      context,
      config: AppDialogConfig(
        title: title,
        message: '', // Để trống vì chúng ta sử dụng contentWidget
        type: AppDialogType.info,
        contentWidget: HighlightedText(
          message: message,
          highlights: highlights,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF94A3B8)
                : const Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCancelButton: showCancelButton,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Hiển thị dialog lỗi (màu đỏ).
  static Future<void> showError(
    BuildContext context, {
    String title = 'Lỗi',
    required String message,
    Widget? contentWidget,
    String? confirmText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return show(
      context,
      config: AppDialogConfig(
        title: title,
        message: message,
        type: AppDialogType.error,
        contentWidget: contentWidget,
        confirmText: confirmText ?? 'Đóng',
        onConfirm: onConfirm,
        showCancelButton: false,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Hiển thị dialog thành công (màu xanh lá).
  static Future<void> showSuccess(
    BuildContext context, {
    String title = 'Thành công',
    required String message,
    Widget? contentWidget,
    String? confirmText,
    VoidCallback? onConfirm,
    bool barrierDismissible = true,
  }) {
    return show(
      context,
      config: AppDialogConfig(
        title: title,
        message: message,
        type: AppDialogType.success,
        contentWidget: contentWidget,
        confirmText: confirmText ?? 'Tuyệt vời!',
        onConfirm: onConfirm,
        showCancelButton: false,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  /// Hiển thị dialog cảnh báo (màu cam).
  static Future<void> showWarning(
    BuildContext context, {
    String title = 'Cảnh báo',
    required String message,
    Widget? contentWidget,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showCancelButton = true,
    bool barrierDismissible = false,
  }) {
    return show(
      context,
      config: AppDialogConfig(
        title: title,
        message: message,
        type: AppDialogType.warning,
        contentWidget: contentWidget,
        confirmText: confirmText ?? 'Xác nhận',
        cancelText: cancelText ?? 'Huỷ',
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCancelButton: showCancelButton,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  // ────────────────────────────────────────────
  // Core methods
  // ────────────────────────────────────────────

  /// Phương thức cốt lõi – hiển thị dialog với [AppDialogConfig].
  /// Tất cả các shortcut method đều gọi qua đây.
  static Future<void> show(
    BuildContext context, {
    required AppDialogConfig config,
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      barrierDismissible: config.barrierDismissible,
      barrierLabel: 'app_dialog',
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        // Curve cho enter
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnim),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return DialogBaseWidget(config: config);
      },
    );
  }

  /// Hiển thị stepper tiến trình nhiều bước với cấu hình linh hoạt dạng config.
  static Future<void> showStepper(
    BuildContext context, {
    required List<AppProcessStepConfig> steps,
    String title = 'Tiến trình xử lý',
    String Function(List<dynamic> results)? summaryTitleBuilder,
    List<String> Function(List<dynamic> results)? summaryNotesBuilder,
    VoidCallback? onAllCompleted,
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      barrierDismissible: barrierDismissible,
      barrierLabel: 'app_stepper_dialog',
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnim),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: AppProcessStepperWidget(
              steps: steps,
              title: title,
              summaryTitleBuilder: summaryTitleBuilder,
              summaryNotesBuilder: summaryNotesBuilder,
              onAllCompleted: onAllCompleted,
            ),
          ),
        );
      },
    );
  }

  /// Hiển thị dialog tải xuống nhiều tệp cùng lúc (Multi-file Download)
  static Future<void> showMultiDownload(
    BuildContext context, {
    required List<AppTransferFileConfig> files,
    String title = 'Tải xuống tệp tin',
    VoidCallback? onCompleted,
    VoidCallback? onCanceled,
  }) {
    return _showTransferDialog(
      context,
      files: files,
      type: AppTransferType.download,
      title: title,
      onCompleted: onCompleted,
      onCanceled: onCanceled,
    );
  }

  /// Hiển thị dialog tải lên nhiều tệp cùng lúc (Multi-file Upload)
  static Future<void> showMultiUpload(
    BuildContext context, {
    required List<AppTransferFileConfig> files,
    String title = 'Tải lên tệp tin',
    VoidCallback? onCompleted,
    VoidCallback? onCanceled,
  }) {
    return _showTransferDialog(
      context,
      files: files,
      type: AppTransferType.upload,
      title: title,
      onCompleted: onCompleted,
      onCanceled: onCanceled,
    );
  }

  static Future<void> _showTransferDialog(
    BuildContext context, {
    required List<AppTransferFileConfig> files,
    required AppTransferType type,
    required String title,
    VoidCallback? onCompleted,
    VoidCallback? onCanceled,
  }) {
    return showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      barrierDismissible: false,
      barrierLabel: 'app_transfer_dialog',
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnim),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: AppMultiTransferDialog(
            files: files,
            type: type,
            title: title,
            onCompleted: onCompleted,
            onCanceled: onCanceled,
          ),
        );
      },
    );
  }
}
