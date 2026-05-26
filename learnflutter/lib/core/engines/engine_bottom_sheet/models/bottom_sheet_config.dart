import 'package:flutter/material.dart';
import 'package:learnflutter/core/engines/engine_dialog/models/dialog_config.dart';

/// Cấu hình cho từng dòng tùy chọn (action item) trong Action list bottom sheet.
class AppBottomSheetActionItem {
  /// Tiêu đề dòng
  final String label;

  /// Icon đại diện
  final IconData icon;

  /// Callback khi nhấn chọn dòng
  final VoidCallback onTap;

  /// Có phải là hành động nguy hiểm/phá hủy (sẽ hiển thị màu đỏ)
  final bool isDestructive;

  const AppBottomSheetActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Cấu hình tổng quan cho Bottom Sheet.
class AppBottomSheetConfig {
  /// Tiêu đề chính hiển thị ở đầu
  final String title;

  /// Tiêu đề phụ/mô tả ngắn
  final String? subtitle;

  /// Phân loại (để quyết định hiển thị icon badge màu sắc ở tiêu đề như Info, Success, Warning, Error)
  final AppDialogType? type;

  /// Widget nội dung tùy biến hoàn toàn (ghi đè subtitle nếu được truyền)
  final Widget? contentWidget;

  /// Danh sách các tùy chọn dòng lệnh (dành cho Action/Option Sheet)
  final List<AppBottomSheetActionItem>? actions;

  /// Text cho nút Xác nhận
  final String? confirmText;

  /// Text cho nút Hủy bỏ
  final String? cancelText;

  /// Callback khi bấm nút Xác nhận
  final VoidCallback? onConfirm;

  /// Callback khi bấm nút Hủy bỏ
  final VoidCallback? onCancel;

  /// Có thể chạm ra ngoài để đóng không
  final bool isDismissible;

  /// Có cho phép vuốt/kéo để đóng không
  final bool enableDrag;

  /// Có hiển thị thanh trượt kéo nhỏ ở đỉnh không
  final bool showDragHandle;

  const AppBottomSheetConfig({
    required this.title,
    this.subtitle,
    this.type,
    this.contentWidget,
    this.actions,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle = true,
  });
}
