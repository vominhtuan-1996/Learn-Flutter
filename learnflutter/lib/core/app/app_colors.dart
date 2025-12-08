import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color secondBlack = Color(0xFF333333);
  static const Color green = Color(0xFF55B436);
  static const Color lightGreen = Color(0xFF00AB59);
  static const Color green2 = Color(0xFFB6E13D);
  static const Color superLightGrey = Color(0xFFEEEEEE);
  static const Color lightGrey = Color(0xFFD3D3D3);
  static const Color grey = Color(0xFF747474);
  static const Color mainGrey = Color(0xFFF7F6FB);
  static const Color greyBlue = Color(0xFF748AA5);
  static const Color orange = Color(0xFFF79839);
  static const Color lightPurple = Color(0xFFBDACBB);
  static const Color blue = Color(0xFF2F80ED);
  static const Color solidBlue = Color(0xFF1668B2);
  static const Color lightBlue = Color(0xFFECF4FF);
  static const Color textLabel = Color(0xFF4b4b4b);
  static const Color hintTextLabel = Color(0xFFFFF3E9);
  static const Color backgroundGrey = Color(0xFFE1E3E6);
  static const Color red = Color(0xFFf53b57);
  static const Color red600 = Color(0xFFf53b57);
  static const Color blueContainer = Color(0xFFe5f6fe);

  static const Color second_03 = Color(0xFF795675);
  static const Color background_02 = Color(0xFFC8C1C8);
  static const Color background_03 = Color(0xFFF9F9F9);
  static const Color yellowBackground = Color(0xFFFFF3E9);
  static const Color scrollBarIndicator = Color(0XFFD9D9D9);

  /// Forgot Password
  static const Color textForgetPass = Color(0xFF18B3F9);
  static const Color containerUser = Color(0xFFFFF2DD);
  static const Color colorHintText = Color(0xFFB7B7B7);
  static const Color colorButtonGetPassword = Color(0xFFf5c697);

  static const Color primary = Color(0xFFFDA758);
  static Color primaryLight = const Color(0xFFFDA758).withOpacity(0.2);
  static const Color primaryText = Color(0xFF795675);
  static const Color secondaryDark = Color(0xFF0D1748);
  static const Color defaultBackground = Color(0xFFFFF3E9);
  static const Color whiteBackground = Color(0xFFFFFFFF);
  static const Color shadowBackground = Color(0xFFDBD2CA);
  static const Color shadow = Color(0xFFCBCBCB);

  /// Print QR Code
  static const Color printed = Color(0xFF4ECB71);
  static const Color notPrinted = Color(0xFFFDA758);
  static const Color printedFailed = Color(0xFFFF4545);

  /// Maintenance component
  static const Color backButtonColor = Color(0xFF8C8C8C);
}

/// Convert hex color (#000000) code to Flutter [Color]
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

extension LighterColor on Color {
  Color get lighter {
    int lighter(int value) {
      return (value + (225 - value) * 0.3).toInt();
    }

    return Color.fromARGB(255, lighter(red), lighter(green), lighter(blue));
  }

  Color get darker {
    int darker(int value) {
      return (value - (value) * 0.3).toInt();
    }

    return Color.fromARGB(255, darker(red), darker(green), darker(blue));
  }
}
