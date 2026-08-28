import 'package:flutter/material.dart';
import 'package:learnflutter/app/theme/app_colors.dart';
import 'package:learnflutter/app/theme/app_text_style.dart';

class AppBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final bool showZero;
  final int maxCount;
  final Color? color;

  const AppBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.showZero = false,
    this.maxCount = 99,
    this.color,
  });

  bool get _visible => count > 0 || showZero;

  String get _label => count > maxCount ? '$maxCount+' : '$count';

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (_visible)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: color ?? AppColors.red,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(
                  _label,
                  style: AppTextStyles.textStyleManrope(
                    AppColors.white,
                    10,
                    FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
