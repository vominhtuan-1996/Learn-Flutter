import 'package:flutter/material.dart';
import 'package:learnflutter/core/engines/engine_dialog/models/dialog_config.dart';
import 'package:learnflutter/core/engines/engine_dialog/widgets/snackbar_base_widget.dart';
import 'package:learnflutter/features/material/component/material_banner/material_banner_overlay.dart';

/// AppSnackbarEngine – Engine hiển thị snackbar với 4 loại chuẩn hóa.
///
/// | Position | Cơ chế |
/// |---|---|
/// | **top** | `TopOverlayBanner` – Overlay với hàng đợi (Queue) + slide-from-top animation |
/// | **bottom** | `ScaffoldMessenger` – Flutter native snackbar |
///
/// ### Cách dùng:
/// ```dart
/// // Bottom snackbar (mặc định)
/// AppSnackbarEngine.showSuccess(context, message: 'Lưu thành công!');
///
/// // Top snackbar – dùng TopOverlayBanner (queue hỗ trợ nhiều banner liên tiếp)
/// AppSnackbarEngine.showError(
///   context,
///   message: 'Kết nối thất bại',
///   position: AppSnackbarPosition.top,
/// );
///
/// // Snackbar với action (chỉ bottom)
/// AppSnackbarEngine.showInfo(
///   context,
///   message: 'Email đã được gửi',
///   actionLabel: 'Hoàn tác',
///   onAction: () => bloc.add(UndoEvent()),
/// );
///
/// // Xoá hàng đợi top banner
/// AppSnackbarEngine.clearTopQueue();
/// ```
class AppSnackbarEngine {
  AppSnackbarEngine._();

  // ────────────────────────────────────────────
  // Shortcut methods
  // ────────────────────────────────────────────

  /// Snackbar thông báo – màu xanh dương.
  static void showInfo(
    BuildContext context, {
    required String message,
    AppSnackbarPosition position = AppSnackbarPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Widget? contentWidget,
    List<Widget>? additionalActions,
    Widget? leading,
    Widget? trailing,
    Widget? customIcon,
  }) {
    show(
      context,
      config: AppSnackbarConfig(
        message: message,
        type: AppSnackbarType.info,
        position: position,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        showCloseButton: showCloseButton,
        contentWidget: contentWidget,
        additionalActions: additionalActions,
        leading: leading,
        trailing: trailing,
        customIcon: customIcon,
      ),
    );
  }

  /// Snackbar lỗi – màu đỏ.
  static void showError(
    BuildContext context, {
    required String message,
    AppSnackbarPosition position = AppSnackbarPosition.bottom,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Widget? contentWidget,
    List<Widget>? additionalActions,
    Widget? leading,
    Widget? trailing,
    Widget? customIcon,
  }) {
    show(
      context,
      config: AppSnackbarConfig(
        message: message,
        type: AppSnackbarType.error,
        position: position,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        showCloseButton: showCloseButton,
        contentWidget: contentWidget,
        additionalActions: additionalActions,
        leading: leading,
        trailing: trailing,
        customIcon: customIcon,
      ),
    );
  }

  /// Snackbar thành công – màu xanh lá.
  static void showSuccess(
    BuildContext context, {
    required String message,
    AppSnackbarPosition position = AppSnackbarPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Widget? contentWidget,
    List<Widget>? additionalActions,
    Widget? leading,
    Widget? trailing,
    Widget? customIcon,
  }) {
    show(
      context,
      config: AppSnackbarConfig(
        message: message,
        type: AppSnackbarType.success,
        position: position,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        showCloseButton: showCloseButton,
        contentWidget: contentWidget,
        additionalActions: additionalActions,
        leading: leading,
        trailing: trailing,
        customIcon: customIcon,
      ),
    );
  }

  /// Snackbar cảnh báo – màu cam.
  static void showWarning(
    BuildContext context, {
    required String message,
    AppSnackbarPosition position = AppSnackbarPosition.bottom,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Widget? contentWidget,
    List<Widget>? additionalActions,
    Widget? leading,
    Widget? trailing,
    Widget? customIcon,
  }) {
    show(
      context,
      config: AppSnackbarConfig(
        message: message,
        type: AppSnackbarType.warning,
        position: position,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        showCloseButton: showCloseButton,
        contentWidget: contentWidget,
        additionalActions: additionalActions,
        leading: leading,
        trailing: trailing,
        customIcon: customIcon,
      ),
    );
  }

  // ────────────────────────────────────────────
  // Core method
  // ────────────────────────────────────────────

  /// Phương thức cốt lõi – phân nhánh theo [AppSnackbarConfig.position]:
  /// - **top** → `TopOverlayBanner` (Overlay, Queue, slide-from-top)
  /// - **bottom** → `ScaffoldMessenger` (Flutter native)
  static void show(
    BuildContext context, {
    required AppSnackbarConfig config,
  }) {
    if (config.position == AppSnackbarPosition.top) {
      _showTop(context, config: config);
    } else {
      _showBottom(context, config: config);
    }
  }

  /// Xoá toàn bộ hàng đợi top banner và đóng banner đang hiển thị.
  /// Nên gọi khi navigate sang màn hình khác hoặc logout.
  static void clearTopQueue() => TopOverlayBanner.clearQueue();

  // ────────────────────────────────────────────
  // Private – Top (TopOverlayBanner)
  // ────────────────────────────────────────────

  /// Hiển thị snackbar ở **đầu màn hình** qua `TopOverlayBanner`.
  ///
  /// - Hỗ trợ **Queue**: nhiều snackbar top gọi liên tiếp → xếp hàng, không đè nhau.
  /// - Animation: **slide từ trên xuống** + auto-dismiss.
  /// - Nút close gọi `clearTopQueue()` để dismiss toàn bộ hàng đợi.
  static void _showTop(
    BuildContext context, {
    required AppSnackbarConfig config,
  }) {
    TopOverlayBanner.show(
      context: context,
      duration: config.duration,
      backgroundColor: config.type.backgroundColor,
      content: SnackbarBaseWidget(
        config: config,
        onClose: () => TopOverlayBanner.clearQueue(),
      ),
    );
  }

  // ────────────────────────────────────────────
  // Private – Bottom (ScaffoldMessenger)
  // ────────────────────────────────────────────

  /// Hiển thị snackbar ở **cuối màn hình** qua `ScaffoldMessenger`.
  static void _showBottom(
    BuildContext context, {
    required AppSnackbarConfig config,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    // Dismiss snackbar đang hiện (nếu có) trước khi hiện cái mới.
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        duration: config.duration,
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.only(bottom: 12, left: 0, right: 0),
        content: SnackbarBaseWidget(
          config: config,
          onClose: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
