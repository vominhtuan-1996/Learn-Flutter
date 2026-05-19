import 'package:flutter/material.dart';
import 'package:learnflutter/core/engine_dialog/models/dialog_config.dart';

/// Widget nền tảng hiển thị nội dung dialog với layout chuẩn.
/// Tất cả 4 loại dialog (info, error, success, warning) đều dùng chung widget này.
class DialogBaseWidget extends StatelessWidget {
  const DialogBaseWidget({
    super.key,
    required this.config,
  });

  final AppDialogConfig config;

  @override
  Widget build(BuildContext context) {
    final type = config.type;
    final iconColor = type.iconColor;
    final borderColor = type.borderColor;
    final bgColor = type.backgroundColor;
    final buttonColor = type.buttonColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final titleColor = isDark ? Colors.white : DialogColorToken.titleDark;
    final messageColor = isDark ? const Color(0xFF94A3B8) : DialogColorToken.messageGrey;
    final dividerColor = isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: borderColor.withOpacity(isDark ? 0.4 : 0.18),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon + Title + Message ─────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon badge
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isDark ? bgColor.withOpacity(0.15) : bgColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor.withOpacity(0.3), width: 2),
                        ),
                        child: config.customIcon ??
                            Icon(
                              type.icon,
                              color: iconColor,
                              size: 32,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        config.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Message or custom content
                      config.contentWidget ??
                          Text(
                            config.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: messageColor,
                              height: 1.6,
                            ),
                          ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Divider ───────────────────────────────────
              Divider(height: 1, thickness: 1, color: dividerColor),

              // ── Action buttons ────────────────────────────
              _ActionButtons(
                config: config,
                buttonColor: buttonColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget chứa các nút hành động (Confirm / Cancel).
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.config,
    required this.buttonColor,
  });

  final AppDialogConfig config;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    final showConfirm = config.showConfirmButton;
    final showCancel = config.showCancelButton;

    if (!showConfirm && !showCancel) {
      return const SizedBox(height: 20);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Cancel button
          if (showCancel) ...[
            Expanded(
              child: _OutlinedBtn(
                label: config.cancelText ?? 'Huỷ',
                color: buttonColor,
                onTap: () {
                  Navigator.of(context).pop();
                  config.onCancel?.call();
                },
              ),
            ),
            if (showConfirm) const SizedBox(width: 12),
          ],

          // Confirm button
          if (showConfirm)
            Expanded(
              child: _FilledBtn(
                label: config.confirmText ?? 'Đồng ý',
                color: buttonColor,
                onTap: () {
                  Navigator.of(context).pop();
                  config.onConfirm?.call();
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Nút filled (nền đặc).
class _FilledBtn extends StatelessWidget {
  const _FilledBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút outlined (viền).
class _OutlinedBtn extends StatelessWidget {
  const _OutlinedBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
