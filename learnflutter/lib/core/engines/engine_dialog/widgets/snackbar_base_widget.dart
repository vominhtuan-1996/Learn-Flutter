import 'package:flutter/material.dart';
import 'package:learnflutter/core/engines/engine_dialog/models/dialog_config.dart';

/// Widget nội dung snackbar engine.
/// Hỗ trợ 4 loại: info, error, success, warning với animation slide-in.
class SnackbarBaseWidget extends StatelessWidget {
  const SnackbarBaseWidget({
    super.key,
    required this.config,
    required this.onClose,
  });

  final AppSnackbarConfig config;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final type = config.type;
    final bgColor = type.backgroundColor;
    final iconWidget = config.customIcon ?? Icon(type.icon, color: Colors.white, size: 20);

    // 1. Build leading widget
    final Widget leadingSection = config.leading ?? 
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: iconWidget,
        );

    // 2. Build content widget (Message or custom widget)
    final Widget contentSection = Expanded(
      child: config.contentWidget ?? 
          Text(
            config.message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
    );

    // 3. Build trailing widget / actions
    Widget trailingSection;
    if (config.trailing != null) {
      trailingSection = config.trailing!;
    } else {
      trailingSection = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút action tiêu chuẩn
          if (config.actionLabel != null) ...[
            GestureDetector(
              onTap: () {
                onClose();
                config.onAction?.call();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  config.actionLabel!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],

          // Thêm các custom action buttons khác nếu được truyền
          if (config.additionalActions != null) ...[
            ...config.additionalActions!.map((act) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: act,
                )),
          ],

          // Nút Close
          if (config.showCloseButton) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
            ),
          ],
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leadingSection,
          const SizedBox(width: 12),
          contentSection,
          const SizedBox(width: 8),
          trailingSection,
        ],
      ),
    );
  }
}
