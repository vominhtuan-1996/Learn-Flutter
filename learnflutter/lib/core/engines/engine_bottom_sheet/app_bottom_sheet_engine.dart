import 'package:flutter/material.dart';
import 'package:learnflutter/core/engines/engine_bottom_sheet/models/bottom_sheet_config.dart';
import 'package:learnflutter/core/engines/engine_bottom_sheet/widgets/bottom_sheet_base_widget.dart';
import 'package:learnflutter/core/engines/engine_dialog/models/dialog_config.dart';

/// Static Controller trung tâm điều phối việc hiển thị Bottom Sheets toàn hệ thống.
///
/// Hỗ trợ các kiểu hiển thị chuẩn hoá cực kỳ premium:
/// 1. `showInfo`, `showSuccess`, `showError`, `showWarning`: Xác nhận nhanh.
/// 2. `showActionSheet`: Danh sách menu tuỳ chọn (Action menu).
/// 3. `showCustom`: Custom Content trượt đáy màn hình.
class AppBottomSheetEngine {
  /// Core method để mở Bottom Sheet với cấu hình tuỳ chọn.
  static Future<T?> show<T>(
    BuildContext context, {
    required AppBottomSheetConfig config,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: config.isDismissible,
      enableDrag: config.enableDrag,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BottomSheetBaseWidget(config: config),
        );
      },
    );
  }

  /// Hiển thị Bottom Sheet thông tin màu xanh dương.
  static Future<T?> showInfo<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show<T>(
      context,
      config: AppBottomSheetConfig(
        title: title,
        subtitle: subtitle,
        type: AppDialogType.info,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  /// Hiển thị Bottom Sheet lỗi màu đỏ chủ đạo.
  static Future<T?> showError<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show<T>(
      context,
      config: AppBottomSheetConfig(
        title: title,
        subtitle: subtitle,
        type: AppDialogType.error,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  /// Hiển thị Bottom Sheet thành công màu xanh lá chủ đạo.
  static Future<T?> showSuccess<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show<T>(
      context,
      config: AppBottomSheetConfig(
        title: title,
        subtitle: subtitle,
        type: AppDialogType.success,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  /// Hiển thị Bottom Sheet cảnh báo nguy hiểm màu cam chủ đạo.
  static Future<T?> showWarning<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show<T>(
      context,
      config: AppBottomSheetConfig(
        title: title,
        subtitle: subtitle,
        type: AppDialogType.warning,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  /// Hiển thị menu danh sách dòng tuỳ chọn nhanh (Action/Option Sheet).
  static Future<T?> showActionSheet<T>(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<AppBottomSheetActionItem> actions,
  }) {
    return show<T>(
      context,
      config: AppBottomSheetConfig(
        title: title,
        subtitle: subtitle,
        actions: actions,
      ),
    );
  }

  /// Hiển thị Bottom Sheet tuỳ biến Widget con.
  static Future<T?> showCustom<T>(
    BuildContext context, {
    required String title,
    required Widget contentWidget,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return show<T>(
      context,
      config: AppBottomSheetConfig(
        title: title,
        contentWidget: contentWidget,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
