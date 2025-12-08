import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/core/app/app_text_style.dart';
import 'package:learnflutter/component/pagination/widget/mb_tap.dart';

const double edgSize = 8;
const Color primaryColor = Colors.orangeAccent;

class MbButton extends StatelessWidget {
  MbButton({
    Key? key,
    this.label = 'none',
    required this.onPress,
    this.color = primaryColor,
    this.textColor = Colors.white,
    this.borderColor = primaryColor,
    this.width,
    this.minWidth = 50,
    this.enable = true,
    this.disableColor,
    this.dismissKeyboard = true,
    this.delayRate,
    this.isDelay = true,
    this.child,
  }) : super(key: key);

  final String label;
  final Color textColor;
  final VoidCallback onPress;
  final Color color;
  final Color borderColor;
  final double? width;
  final double minWidth;
  final bool enable;
  final Color? disableColor;
  final bool dismissKeyboard;
  final bool isDelay;
  final int? delayRate;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.hardEdge,
      color: color,
      borderRadius: BorderRadius.circular(edgSize),
      child: MbTap(
        onTap: () {
          HapticFeedback.mediumImpact();
          onPress();
        },
        enable: enable,
        isDelay: isDelay,
        delayRate: delayRate,
        dismissKeyboard: dismissKeyboard,
        disableColor: disableColor ?? AppColors.white.withOpacity(0.4),
        child: Container(
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(edgSize),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(edgSize),
            border: Border.all(width: 1, color: borderColor),
          ),
          width: width,
          constraints: BoxConstraints(minWidth: minWidth),
          child: Center(
            child: child ??
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.themeBodyMedium.copyWith(color: textColor),
                ),
          ),
        ),
      ),
    );
  }
}
