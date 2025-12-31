import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextToken {
  final String fontFamily;
  final double size;
  final FontWeight weight;
  final double letterSpacing;
  final double? height;
  final FontStyle? fontStyle;
  final Color? color;

  const TextToken({
    required this.fontFamily,
    required this.size,
    required this.weight,
    this.letterSpacing = 0,
    this.height,
    this.fontStyle,
    this.color,
  });

  TextStyle toTextStyle(Color fallbackColor) {
    return GoogleFonts.getFont(
      fontFamily.split('_').first,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
      color: color ?? fallbackColor,
    );
  }

  TextToken copyWith({
    String? fontFamily,
    double? size,
    FontWeight? weight,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    Color? color,
  }) {
    return TextToken(
      fontFamily: fontFamily ?? this.fontFamily,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      height: height ?? this.height,
      fontStyle: fontStyle ?? this.fontStyle,
      color: color ?? this.color,
    );
  }
}

class TextTokens {
  final TextToken displayLarge;
  final TextToken displayMedium;
  final TextToken displaySmall;

  final TextToken headlineLarge;
  final TextToken headlineMedium;
  final TextToken headlineSmall;

  final TextToken titleLarge;
  final TextToken titleMedium;
  final TextToken titleSmall;

  final TextToken bodyLarge;
  final TextToken bodyMedium;
  final TextToken bodySmall;

  final TextToken labelLarge;
  final TextToken labelMedium;
  final TextToken labelSmall;

  const TextTokens({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  TextTheme toTextTheme(ColorScheme scheme) {
    Color c(TextToken t) => t.color ?? scheme.onBackground;

    return TextTheme(
      displayLarge: displayLarge.toTextStyle(c(displayLarge)),
      displayMedium: displayMedium.toTextStyle(c(displayMedium)),
      displaySmall: displaySmall.toTextStyle(c(displaySmall)),
      headlineLarge: headlineLarge.toTextStyle(c(headlineLarge)),
      headlineMedium: headlineMedium.toTextStyle(c(headlineMedium)),
      headlineSmall: headlineSmall.toTextStyle(c(headlineSmall)),
      titleLarge: titleLarge.toTextStyle(c(titleLarge)),
      titleMedium: titleMedium.toTextStyle(c(titleMedium)),
      titleSmall: titleSmall.toTextStyle(c(titleSmall)),
      bodyLarge: bodyLarge.toTextStyle(c(bodyLarge)),
      bodyMedium: bodyMedium.toTextStyle(c(bodyMedium)),
      bodySmall: bodySmall.toTextStyle(c(bodySmall)),
      labelLarge: labelLarge.toTextStyle(c(labelLarge)),
      labelMedium: labelMedium.toTextStyle(c(labelMedium)),
      labelSmall: labelSmall.toTextStyle(c(labelSmall)),
    );
  }

  TextTokens copyWith({
    TextToken? displayLarge,
    TextToken? displayMedium,
    TextToken? displaySmall,
    TextToken? headlineLarge,
    TextToken? headlineMedium,
    TextToken? headlineSmall,
    TextToken? titleLarge,
    TextToken? titleMedium,
    TextToken? titleSmall,
    TextToken? bodyLarge,
    TextToken? bodyMedium,
    TextToken? bodySmall,
    TextToken? labelLarge,
    TextToken? labelMedium,
    TextToken? labelSmall,
  }) {
    return TextTokens(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }
}
