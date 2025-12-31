import 'package:flutter/material.dart';
import 'package:learnflutter/core/theme_token/colors_token.dart';
import 'package:learnflutter/core/theme_token/text_token.dart';
import 'package:learnflutter/core/theme_token/theme_controller.dart';

enum TextRole {
  displayLarge,
  displayMedium,
  displaySmall,

  headlineLarge,
  headlineMedium,
  headlineSmall,

  titleLarge,
  titleMedium,
  titleSmall,

  bodyLarge,
  bodyMedium,
  bodySmall,

  labelLarge,
  labelMedium,
  labelSmall,
}

extension ThemeTokensX on ThemeTokens {
  ThemeData toThemeData() {
    final brightness = isLight ? Brightness.light : Brightness.dark;
    final colorScheme = colors.toColorScheme(brightness);
    final textTheme = texts.toTextTheme(colorScheme);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // 🌈 Base colors
      scaffoldBackgroundColor: colorScheme.background,
      canvasColor: colorScheme.surface,
      dividerColor: colorScheme.outline ?? colorScheme.onSurface.withOpacity(0.12),

      // 🔤 Text
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // 🧭 AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium,
      ),

      // 🔘 Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // 📝 Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline ?? Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline ?? Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),

      // 🪟 Card
      cardTheme: CardTheme(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // 📋 ListTile
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurface,
        textColor: colorScheme.onSurface,
      ),

      // ⚠️ SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      ),
    );
  }
}

// ---------- Color ----------
extension ColorJson on Color {
  int toHex() => value;
  static Color fromHex(int hex) => Color(hex);
}

// ---------- ColorTokens ----------
extension ColorTokensJson on ColorTokens {
  Map<String, dynamic> toJson() => {
        'primary': primary.toHex(),
        'onPrimary': onPrimary.toHex(),
        'secondary': secondary.toHex(),
        'background': background.toHex(),
        'surface': surface.toHex(),
        'error': error.toHex(),
        'onBackground': onBackground.toHex(),
        'onSurface': onSurface.toHex(),
      };

  static ColorTokens fromJson(Map<String, dynamic> json) {
    return ColorTokens(
      primary: ColorJson.fromHex(json['primary']),
      onPrimary: ColorJson.fromHex(json['onPrimary']),
      secondary: ColorJson.fromHex(json['secondary']),
      background: ColorJson.fromHex(json['background']),
      surface: ColorJson.fromHex(json['surface']),
      error: ColorJson.fromHex(json['error']),
      onBackground: ColorJson.fromHex(json['onBackground']),
      onSurface: ColorJson.fromHex(json['onSurface']),
    );
  }
}

// ---------- FontWeight ----------
extension FontWeightJson on FontWeight {
  int toJson() => index;
  static FontWeight fromJson(int i) => FontWeight.values[i];
}

// ---------- TextToken ----------
extension TextTokenJson on TextToken {
  Map<String, dynamic> toJson() => {
        'size': size,
        'weight': weight.toJson(),
        'letterSpacing': letterSpacing,
        'fontFamily': fontFamily,
        'color': color?.toHex(),
      };

  static TextToken fromJson(Map<String, dynamic> json) {
    return TextToken(
      fontFamily: json['fontFamily'],
      size: (json['size'] as num).toDouble(),
      weight: FontWeightJson.fromJson(json['weight']),
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0,
      color: json['color'] != null ? ColorJson.fromHex(json['color']) : null,
    );
  }
}

// ---------- TextTokens ----------
extension TextTokensJson on TextTokens {
  Map<String, dynamic> toJson() => {
        'displayLarge': displayLarge.toJson(),
        'displayMedium': displayMedium.toJson(),
        'displaySmall': displaySmall.toJson(),
        'titleLarge': titleLarge.toJson(),
        'titleMedium': titleMedium.toJson(),
        'titleSmall': titleSmall.toJson(),
        'bodyLarge': bodyLarge.toJson(),
        'bodyMedium': bodyMedium.toJson(),
        'bodySmall': bodySmall.toJson(),
        'headlineLarge': headlineLarge.toJson(),
        'headlineMedium': headlineMedium.toJson(),
        'headlineSmall': headlineSmall.toJson(),
        'labelLarge': labelLarge.toJson(),
        'labelMedium': labelMedium.toJson(),
        'labelSmall': labelSmall.toJson(),
      };

  static TextTokens fromJson(Map<String, dynamic> json) {
    return TextTokens(
      displayLarge: TextTokenJson.fromJson(json['displayLarge']),
      displayMedium: TextTokenJson.fromJson(json['displayMedium']),
      displaySmall: TextTokenJson.fromJson(json['displaySmall']),
      titleLarge: TextTokenJson.fromJson(json['titleLarge']),
      titleMedium: TextTokenJson.fromJson(json['titleMedium']),
      titleSmall: TextTokenJson.fromJson(json['titleSmall']),
      bodyLarge: TextTokenJson.fromJson(json['bodyLarge']),
      bodyMedium: TextTokenJson.fromJson(json['bodyMedium']),
      bodySmall: TextTokenJson.fromJson(json['bodySmall']),
      headlineLarge: TextTokenJson.fromJson(json['headlineLarge']),
      headlineMedium: TextTokenJson.fromJson(json['headlineMedium']),
      headlineSmall: TextTokenJson.fromJson(json['headlineSmall']),
      labelLarge: TextTokenJson.fromJson(json['labelLarge']),
      labelMedium: TextTokenJson.fromJson(json['labelMedium']),
      labelSmall: TextTokenJson.fromJson(json['labelSmall']),
    );
  }
}

// ---------- ThemeTokens ----------
extension ThemeTokensJson on ThemeTokens {
  Map<String, dynamic> toJson() => {
        'isLight': isLight,
        'colors': colors.toJson(),
        'texts': texts.toJson(),
      };

  static ThemeTokens fromJson(Map<String, dynamic> json) {
    return ThemeTokens(
      isLight: json['isLight'],
      colors: ColorTokensJson.fromJson(json['colors']),
      texts: TextTokensJson.fromJson(json['texts']),
    );
  }
}

extension TextTokensUpdater on TextTokens {
  TextTokens update(TextRole role, TextToken token) {
    switch (role) {
      case TextRole.displayLarge:
        return copyWith(displayLarge: token);
      case TextRole.displayMedium:
        return copyWith(displayMedium: token);
      case TextRole.displaySmall:
        return copyWith(displaySmall: token);

      case TextRole.headlineLarge:
        return copyWith(headlineLarge: token);
      case TextRole.headlineMedium:
        return copyWith(headlineMedium: token);
      case TextRole.headlineSmall:
        return copyWith(headlineSmall: token);

      case TextRole.titleLarge:
        return copyWith(titleLarge: token);
      case TextRole.titleMedium:
        return copyWith(titleMedium: token);
      case TextRole.titleSmall:
        return copyWith(titleSmall: token);

      case TextRole.bodyLarge:
        return copyWith(bodyLarge: token);
      case TextRole.bodyMedium:
        return copyWith(bodyMedium: token);
      case TextRole.bodySmall:
        return copyWith(bodySmall: token);

      case TextRole.labelLarge:
        return copyWith(labelLarge: token);
      case TextRole.labelMedium:
        return copyWith(labelMedium: token);
      case TextRole.labelSmall:
        return copyWith(labelSmall: token);
    }
  }

  TextToken getByRole(TextRole role) {
    switch (role) {
      case TextRole.displayLarge:
        return displayLarge;
      case TextRole.displayMedium:
        return displayMedium;
      case TextRole.displaySmall:
        return displaySmall;

      case TextRole.headlineLarge:
        return headlineLarge;
      case TextRole.headlineMedium:
        return headlineMedium;
      case TextRole.headlineSmall:
        return headlineSmall;

      case TextRole.titleLarge:
        return titleLarge;
      case TextRole.titleMedium:
        return titleMedium;
      case TextRole.titleSmall:
        return titleSmall;

      case TextRole.bodyLarge:
        return bodyLarge;
      case TextRole.bodyMedium:
        return bodyMedium;
      case TextRole.bodySmall:
        return bodySmall;

      case TextRole.labelLarge:
        return labelLarge;
      case TextRole.labelMedium:
        return labelMedium;
      case TextRole.labelSmall:
        return labelSmall;
    }
  }
}
