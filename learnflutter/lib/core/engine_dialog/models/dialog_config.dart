import 'package:flutter/material.dart';

/// Định nghĩa các kiểu dialog trong hệ thống Engine Dialog.
enum AppDialogType {
  /// Dialog thông báo thông thường (màu xanh dương)
  info,

  /// Dialog lỗi (màu đỏ)
  error,

  /// Dialog thành công (màu xanh lá)
  success,

  /// Dialog cảnh báo (màu cam)
  warning,
}

/// Định nghĩa các kiểu snackbar.
enum AppSnackbarType {
  info,
  error,
  success,
  warning,
}

/// Định nghĩa vị trí hiển thị snackbar.
enum AppSnackbarPosition {
  top,
  bottom,
}

/// Cấu hình cho dialog.
class AppDialogConfig {
  /// Tiêu đề dialog
  final String title;

  /// Nội dung dialog
  final String message;

  /// Widget nội dung tùy chỉnh (override message nếu có)
  final Widget? contentWidget;

  /// Loại dialog (xác định màu sắc & icon)
  final AppDialogType type;

  /// Text nút xác nhận
  final String? confirmText;

  /// Text nút huỷ
  final String? cancelText;

  /// Callback khi nhấn xác nhận
  final VoidCallback? onConfirm;

  /// Callback khi nhấn huỷ
  final VoidCallback? onCancel;

  /// Có thể đóng bằng cách tap ra ngoài không
  final bool barrierDismissible;

  /// Widget icon tùy chỉnh (override icon mặc định)
  final Widget? customIcon;

  /// Hiển thị nút xác nhận không
  final bool showConfirmButton;

  /// Hiển thị nút huỷ không
  final bool showCancelButton;

  const AppDialogConfig({
    required this.title,
    required this.message,
    this.contentWidget,
    this.type = AppDialogType.info,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
    this.customIcon,
    this.showConfirmButton = true,
    this.showCancelButton = false,
  });
}

/// Cấu hình cho snackbar.
class AppSnackbarConfig {
  /// Nội dung hiển thị
  final String message;

  /// Loại snackbar
  final AppSnackbarType type;

  /// Vị trí hiển thị
  final AppSnackbarPosition position;

  /// Thời gian hiển thị
  final Duration duration;

  /// Widget icon tùy chỉnh (thay thế icon tròn mặc định)
  final Widget? customIcon;

  /// Widget nội dung tuỳ chỉnh hoàn toàn (thay thế message text)
  final Widget? contentWidget;

  /// Danh sách các widget hành động tuỳ chỉnh thêm (hiển thị bên cạnh hoặc phía dưới)
  final List<Widget>? additionalActions;

  /// Widget thay thế phần icon đầu dòng (nếu cần)
  final Widget? leading;

  /// Widget thay thế phần action/close button cuối dòng (nếu cần)
  final Widget? trailing;

  /// Text nút hành động (action button)
  final String? actionLabel;

  /// Callback khi nhấn action button
  final VoidCallback? onAction;

  /// Có hiển thị nút đóng không
  final bool showCloseButton;

  const AppSnackbarConfig({
    required this.message,
    this.type = AppSnackbarType.info,
    this.position = AppSnackbarPosition.bottom,
    this.duration = const Duration(seconds: 3),
    this.customIcon,
    this.contentWidget,
    this.additionalActions,
    this.leading,
    this.trailing,
    this.actionLabel,
    this.onAction,
    this.showCloseButton = true,
  });
}

/// Các màu sắc token cho từng loại dialog/snackbar.
class DialogColorToken {
  DialogColorToken._();

  // ── Info ──────────────────────────────────────
  static const Color infoBackground = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFF3B82F6);
  static const Color infoIcon = Color(0xFF3B82F6);
  static const Color infoButton = Color(0xFF2563EB);

  // ── Error ─────────────────────────────────────
  static const Color errorBackground = Color(0xFFFFF1F2);
  static const Color errorBorder = Color(0xFFEF4444);
  static const Color errorIcon = Color(0xFFEF4444);
  static const Color errorButton = Color(0xFFDC2626);

  // ── Success ───────────────────────────────────
  static const Color successBackground = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFF22C55E);
  static const Color successIcon = Color(0xFF22C55E);
  static const Color successButton = Color(0xFF16A34A);

  // ── Warning ───────────────────────────────────
  static const Color warningBackground = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFF59E0B);
  static const Color warningIcon = Color(0xFFF59E0B);
  static const Color warningButton = Color(0xFFD97706);

  // ── Text ──────────────────────────────────────
  static const Color titleDark = Color(0xFF111827);
  static const Color messageGrey = Color(0xFF6B7280);

  // ── Snackbar ──────────────────────────────────
  static const Color snackbarInfoBg = Color(0xFF1E40AF);
  static const Color snackbarErrorBg = Color(0xFFB91C1C);
  static const Color snackbarSuccessBg = Color(0xFF15803D);
  static const Color snackbarWarningBg = Color(0xFFB45309);
}

/// Extension để lấy màu theo loại dialog.
extension AppDialogTypeX on AppDialogType {
  Color get backgroundColor => switch (this) {
        AppDialogType.info => DialogColorToken.infoBackground,
        AppDialogType.error => DialogColorToken.errorBackground,
        AppDialogType.success => DialogColorToken.successBackground,
        AppDialogType.warning => DialogColorToken.warningBackground,
      };

  Color get borderColor => switch (this) {
        AppDialogType.info => DialogColorToken.infoBorder,
        AppDialogType.error => DialogColorToken.errorBorder,
        AppDialogType.success => DialogColorToken.successBorder,
        AppDialogType.warning => DialogColorToken.warningBorder,
      };

  Color get iconColor => switch (this) {
        AppDialogType.info => DialogColorToken.infoIcon,
        AppDialogType.error => DialogColorToken.errorIcon,
        AppDialogType.success => DialogColorToken.successIcon,
        AppDialogType.warning => DialogColorToken.warningIcon,
      };

  Color get buttonColor => switch (this) {
        AppDialogType.info => DialogColorToken.infoButton,
        AppDialogType.error => DialogColorToken.errorButton,
        AppDialogType.success => DialogColorToken.successButton,
        AppDialogType.warning => DialogColorToken.warningButton,
      };

  IconData get icon => switch (this) {
        AppDialogType.info => Icons.info_rounded,
        AppDialogType.error => Icons.error_rounded,
        AppDialogType.success => Icons.check_circle_rounded,
        AppDialogType.warning => Icons.warning_rounded,
      };

  String get defaultTitle => switch (this) {
        AppDialogType.info => 'Thông báo',
        AppDialogType.error => 'Lỗi',
        AppDialogType.success => 'Thành công',
        AppDialogType.warning => 'Cảnh báo',
      };
}

/// Extension để lấy màu theo loại snackbar.
extension AppSnackbarTypeX on AppSnackbarType {
  Color get backgroundColor => switch (this) {
        AppSnackbarType.info => DialogColorToken.snackbarInfoBg,
        AppSnackbarType.error => DialogColorToken.snackbarErrorBg,
        AppSnackbarType.success => DialogColorToken.snackbarSuccessBg,
        AppSnackbarType.warning => DialogColorToken.snackbarWarningBg,
      };

  IconData get icon => switch (this) {
        AppSnackbarType.info => Icons.info_rounded,
        AppSnackbarType.error => Icons.error_rounded,
        AppSnackbarType.success => Icons.check_circle_rounded,
        AppSnackbarType.warning => Icons.warning_rounded,
      };
}
