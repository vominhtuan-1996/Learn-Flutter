import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_colors.dart';
import 'package:learnflutter/app/theme/app_text_style.dart';
import 'package:learnflutter/shared/widgets/tap.dart';

enum _ButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enable;
  final Widget? icon;
  final double? width;
  final _ButtonType _type;

  const AppButton._({
    required this.label,
    required _ButtonType type,
    this.onTap,
    this.isLoading = false,
    this.enable = true,
    this.icon,
    this.width,
  }) : _type = type;

  factory AppButton.primary({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
    bool enable = true,
    Widget? icon,
    double? width,
  }) =>
      AppButton._(
        label: label,
        type: _ButtonType.primary,
        onTap: onTap,
        isLoading: isLoading,
        enable: enable,
        icon: icon,
        width: width,
      );

  factory AppButton.secondary({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
    bool enable = true,
    Widget? icon,
    double? width,
  }) =>
      AppButton._(
        label: label,
        type: _ButtonType.secondary,
        onTap: onTap,
        isLoading: isLoading,
        enable: enable,
        icon: icon,
        width: width,
      );

  factory AppButton.outline({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
    bool enable = true,
    Widget? icon,
    double? width,
  }) =>
      AppButton._(
        label: label,
        type: _ButtonType.outline,
        onTap: onTap,
        isLoading: isLoading,
        enable: enable,
        icon: icon,
        width: width,
      );

  factory AppButton.text({
    required String label,
    VoidCallback? onTap,
    bool isLoading = false,
    bool enable = true,
    Widget? icon,
    double? width,
  }) =>
      AppButton._(
        label: label,
        type: _ButtonType.text,
        onTap: onTap,
        isLoading: isLoading,
        enable: enable,
        icon: icon,
        width: width,
      );

  Color get _backgroundColor {
    switch (_type) {
      case _ButtonType.primary:
        return AppColors.primary;
      case _ButtonType.secondary:
        return AppColors.primaryLight;
      case _ButtonType.outline:
      case _ButtonType.text:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    switch (_type) {
      case _ButtonType.primary:
        return AppColors.white;
      case _ButtonType.secondary:
      case _ButtonType.outline:
      case _ButtonType.text:
        return AppColors.primary;
    }
  }

  Border? get _border {
    if (_type == _ButtonType.outline) {
      return Border.all(color: AppColors.primary, width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isActive = enable && !isLoading;

    return Tap(
      onTap: isActive ? onTap : null,
      enable: isActive,
      child: AnimatedOpacity(
        opacity: enable ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: width,
          height: 48,
          decoration: BoxDecoration(
            color: _backgroundColor,
            border: _border,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _foregroundColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.textStyleManrope(
                          _foregroundColor,
                          16,
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
