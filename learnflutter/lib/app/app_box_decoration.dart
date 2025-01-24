import 'package:flutter/material.dart';
import 'package:learnflutter/app/app_colors.dart';

class AppBoxDecoration {
  static BoxDecoration boxDecorationCircleColorPrimary = boxDecorationCircle(AppColors.primary);
  static BoxDecoration boxDecorationRectangleColorPrimary = boxDecorationRectangle(AppColors.primary);
  static BoxDecoration boxDecorationGreyBorder = boxDecorationBorder(4, 1, AppColors.background_02);

  static BoxDecoration boxDecorationCircle(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    );
  }

  static BoxDecoration boxDecorationRectangle(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration boxDecorationRadius(double borderRadiusValue, Color colors) {
    return BoxDecoration(borderRadius: BorderRadius.circular(borderRadiusValue), color: colors);
  }

  static BoxDecoration boxDecorationBorder(double borderRadiusValue, double borderWidth, Color color) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadiusValue),
      border: Border.all(width: borderWidth, color: color),
    );
  }

  static BoxDecoration boxDecorationBorderRadius({
    required double borderRadiusValue,
    double? borderWidth,
    Color? colorBorder,
    Color? colorBackground,
  }) {
    return BoxDecoration(
      color: colorBackground ?? Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadiusValue),
      border: Border.all(width: borderWidth ?? 0, color: colorBorder ?? Colors.transparent),
    );
  }
}
