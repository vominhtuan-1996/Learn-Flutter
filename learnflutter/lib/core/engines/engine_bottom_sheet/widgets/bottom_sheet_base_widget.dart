import 'package:flutter/material.dart';
import 'package:learnflutter/core/engines/engine_bottom_sheet/models/bottom_sheet_config.dart';
import 'package:learnflutter/core/engines/engine_dialog/models/dialog_config.dart';

/// Khung layout nền tảng cho Bottom Sheets trong hệ thống.
///
/// Hỗ trợ:
/// 1. **Dark Mode**: Tự động chuyển đổi màu nền Slate/White tối ưu.
/// 2. **Tablet & Landscape**: Giới hạn kích thước `maxWidth: 480` ở trung tâm đáy màn hình.
/// 3. **Drag Handle & Gestures**: Hiển thị thanh kéo tinh xảo.
/// 4. **Header & Badge**: Tích hợp icon badge trạng thái chuẩn màu DialogColorToken.
class BottomSheetBaseWidget extends StatelessWidget {
  final AppBottomSheetConfig config;

  const BottomSheetBaseWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tokens màu động hỗ trợ Dark Mode
    final surfaceBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);
    final dragHandleColor = isDark ? const Color(0xFF475569) : const Color(0xFFE5E7EB);

    // Xây dựng Header
    Widget? headerSection;
    if (config.title.isNotEmpty) {
      Widget? leadingIcon;
      if (config.type != null) {
        final type = config.type!;
        leadingIcon = Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: type.backgroundColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            type.icon,
            color: type.borderColor,
            size: 18,
          ),
        );
      }

      headerSection = Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            if (leadingIcon != null) leadingIcon,
            Expanded(
              child: Text(
                config.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Xây dựng Body Content
    Widget bodySection = const SizedBox.shrink();
    if (config.contentWidget != null) {
      bodySection = config.contentWidget!;
    } else if (config.subtitle != null) {
      bodySection = Text(
        config.subtitle!,
        style: TextStyle(
          fontSize: 14,
          color: subtitleColor,
          height: 1.5,
        ),
      );
    }

    // Xây dựng Footer Actions (Nút Xác nhận / Hủy)
    Widget? footerSection;
    final showConfirm = config.confirmText != null;
    final showCancel = config.cancelText != null;

    if (showConfirm || showCancel) {
      final typeColor = config.type?.buttonColor ?? const Color(0xFF3B82F6);

      footerSection = Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showConfirm)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  config.onConfirm?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  config.confirmText!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            if (showConfirm && showCancel) const SizedBox(height: 10),
            if (showCancel)
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  config.onCancel?.call();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: subtitleColor,
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  config.cancelText!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      );
    }

    // Wrap toàn bộ trong ConstrainedBox để hỗ trợ Tablet responsive
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  if (config.showDragHandle)
                    Center(
                      child: Container(
                        width: 38,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: dragHandleColor,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),

                  // Header Title
                  if (headerSection != null) headerSection,

                  // Body Content
                  bodySection,

                  // List actions (nếu có)
                  if (config.actions != null && config.actions!.isNotEmpty) ...[
                    if (headerSection != null || config.subtitle != null) ...[
                      const SizedBox(height: 12),
                      Divider(color: dividerColor, height: 1),
                      const SizedBox(height: 8),
                    ],
                    // Danh sách action list sẽ render ở đây
                    ...config.actions!.map((action) => _ActionTile(action: action, isDark: isDark)),
                  ],

                  // Footer buttons
                  if (footerSection != null) footerSection,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget nhỏ hiển thị từng dòng tuỳ chọn trong Action Sheet.
class _ActionTile extends StatelessWidget {
  final AppBottomSheetActionItem action;
  final bool isDark;

  const _ActionTile({
    required this.action,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = action.isDestructive ? const Color(0xFFEF4444) : (isDark ? Colors.white : const Color(0xFF374151));
    final iconColor = action.isDestructive ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280));
    final hoverColor = isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFF9FAFB);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            action.onTap();
          },
          borderRadius: BorderRadius.circular(12),
          hoverColor: hoverColor,
          splashColor: hoverColor,
          highlightColor: hoverColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(action.icon, color: iconColor, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    action.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFD1D5DB),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
