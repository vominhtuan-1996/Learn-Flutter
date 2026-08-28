import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_colors.dart';
import 'package:learnflutter/app/theme/app_text_style.dart';
import 'package:learnflutter/shared/widgets/tap.dart';

enum _ChipType { filter, label, action }

class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Widget? icon;
  final Color? color;
  final _ChipType _type;

  const AppChip._({
    required this.label,
    required _ChipType type,
    this.selected = false,
    this.onTap,
    this.onDelete,
    this.icon,
    this.color,
  }) : _type = type;

  factory AppChip.filter({
    required String label,
    bool selected = false,
    VoidCallback? onTap,
    Widget? icon,
    Color? color,
  }) =>
      AppChip._(
        label: label,
        type: _ChipType.filter,
        selected: selected,
        onTap: onTap,
        icon: icon,
        color: color,
      );

  factory AppChip.label({
    required String label,
    Widget? icon,
    Color? color,
  }) =>
      AppChip._(
        label: label,
        type: _ChipType.label,
        icon: icon,
        color: color,
      );

  factory AppChip.action({
    required String label,
    VoidCallback? onTap,
    VoidCallback? onDelete,
    Widget? icon,
    Color? color,
  }) =>
      AppChip._(
        label: label,
        type: _ChipType.action,
        onTap: onTap,
        onDelete: onDelete,
        icon: icon,
        color: color,
      );

  Color get _bgColor {
    final base = color ?? AppColors.primary;
    if (_type == _ChipType.filter) {
      return selected ? base : base.withOpacity(0.1);
    }
    return base.withOpacity(0.12);
  }

  Color get _textColor {
    final base = color ?? AppColors.primary;
    if (_type == _ChipType.filter && selected) return AppColors.white;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: _type == _ChipType.filter && !selected
            ? Border.all(color: (color ?? AppColors.primary).withOpacity(0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.textStyleManrope(_textColor, 13, FontWeight.w500),
          ),
          if (_type == _ChipType.action && onDelete != null) ...[
            const SizedBox(width: 4),
            Tap(
              onTap: onDelete,
              child: Icon(Icons.close, size: 14, color: _textColor),
            ),
          ],
        ],
      ),
    );

    if (onTap == null && _type != _ChipType.action) return content;
    return Tap(onTap: onTap, child: content);
  }
}
