import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_colors.dart';
import 'package:learnflutter/app/theme/app_text_style.dart';
import 'package:learnflutter/shared/widgets/app_button.dart';

class AppDialog {
  AppDialog._();

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Xác nhận',
    String cancelLabel = 'Huỷ',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AppDialogWidget(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showCancel: true,
      ),
    );
  }

  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Đóng',
    VoidCallback? onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => _AppDialogWidget(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        showCancel: false,
      ),
    );
  }

  static Future<T?> custom<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: child,
      ),
    );
  }
}

class _AppDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showCancel;

  const _AppDialogWidget({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.showCancel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: AppTextStyles.textStyleManrope(
                AppColors.primaryText,
                18,
                FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.textStyleManrope(
                AppColors.grey,
                14,
                FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (showCancel) ...[
              AppButton.outline(
                label: cancelLabel ?? 'Huỷ',
                onTap: () {
                  onCancel?.call();
                  Navigator.of(context).pop(false);
                },
              ),
              const SizedBox(height: 12),
            ],
            AppButton.primary(
              label: confirmLabel,
              onTap: () {
                onConfirm?.call();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
