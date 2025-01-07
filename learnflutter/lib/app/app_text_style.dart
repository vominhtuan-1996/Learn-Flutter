import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learnflutter/app/app_colors.dart';

import '../core/global/var_global.dart';

/// Never be use
class AppTextStyles {
  // textTheme
  static TextStyle themeDisplayLarge = textStyleManrope(AppColors.primaryText, 57, FontWeight.w400);
  static TextStyle themeDisplayMedium = textStyleManrope(AppColors.primaryText, 45, FontWeight.w400);
  static TextStyle themeDisplaySmall = textStyleManrope(AppColors.primaryText, 36, FontWeight.w400);

  static TextStyle themeHeadlineLarge = textStyleManrope(AppColors.primaryText, 32, FontWeight.w400);
  static TextStyle themeHeadlineMedium = textStyleManrope(AppColors.primaryText, 28, FontWeight.w400);
  static TextStyle themeHeadlineSmall = textStyleManrope(AppColors.primaryText, 24, FontWeight.w400);

  static TextStyle themeTitleLarge = textStyleManrope(AppColors.primaryText, 22, FontWeight.w400);
  static TextStyle themeTitleMedium = textStyleManrope(AppColors.primaryText, 16, FontWeight.w400);
  static TextStyle themeTitleSmall = textStyleManrope(AppColors.primaryText, 14, FontWeight.w400);

  static TextStyle themeBodyLarge = textStyleManrope(AppColors.primaryText, 16, FontWeight.w400);
  static TextStyle themeBodyMedium = textStyleManrope(AppColors.primaryText, 14, FontWeight.w400);
  static TextStyle themeBodySmall = textStyleManrope(AppColors.primaryText, 12, FontWeight.w400);

  static TextStyle themeLabelLarge = textStyleManrope(AppColors.primaryText, 14, FontWeight.w400);
  static TextStyle themeLabelMedium = textStyleManrope(AppColors.primaryText, 12, FontWeight.w400);
  static TextStyle themeLabelSmall = textStyleManrope(AppColors.primaryText, 11, FontWeight.w400);

  static TextStyle textStyleManrope(Color color, double fontSize, [FontWeight fontWe = FontWeight.w500, FontStyle fontStyle = FontStyle.normal]) {
    return textStyle(color, fontSize, GoogleFonts.manrope().fontFamily, fontWe, fontStyle);
  }

  static TextStyle textStyleInter(Color color, double fontSize, [FontWeight fontWe = FontWeight.w500, FontStyle fontStyle = FontStyle.normal]) {
    return textStyle(color, fontSize, GoogleFonts.inter().fontFamily, fontWe, fontStyle);
  }

  static TextStyle textStyle(Color color, double fontSize, String? fontFamily, [FontWeight fontWe = FontWeight.w500, FontStyle fontStyle = FontStyle.normal]) {
    return TextStyle(fontFamily: fontFamily, color: color, fontSize: fontSize * textScale, fontWeight: fontWe, fontStyle: fontStyle);
  }
}
