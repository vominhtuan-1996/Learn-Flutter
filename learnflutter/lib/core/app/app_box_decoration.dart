import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/app_colors.dart';

class AppBoxDecoration {
  static BoxDecoration boxDecorationCircleColorPrimary = boxDecorationCircle(AppColors.primary);
  static BoxDecoration boxDecorationRectangleColorPrimary =
      boxDecorationRectangle(AppColors.primary);
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

  static BoxDecoration boxDecorationBorder(
      double borderRadiusValue, double borderWidth, Color color) {
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

class AppShadowBox {
  static BoxShadow boxShadowPrimary = boxShadow(AppColors.primaryText.withOpacity(0.8), 1, 4);
  static BoxShadow shadowLight = boxShadow(AppColors.black.withOpacity(0.3), 0, 3, Offset(0, 2));
  static BoxShadow shadowSuperLight =
      boxShadow(AppColors.grey.withOpacity(0.2), -0.5, 0.5, Offset(0, 1.5));

  static BoxShadow boxShadow(Color colors, double spreadRadius, double blurRadius,
      [Offset? offset = const Offset(0, 0)]) {
    return BoxShadow(
        color: colors, spreadRadius: spreadRadius, blurRadius: blurRadius, offset: offset!);
  }
}
