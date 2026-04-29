import 'package:flutter/material.dart';
import 'package:learnflutter/core/theme/colors_token.dart';
import 'package:learnflutter/core/theme/text_token.dart';
import 'package:learnflutter/core/theme/theme_controller.dart';

/// [HabitBuilderTheme] — Bộ theme được sinh từ Figma design tokens
/// của file "Pixel True - Habit Builder UI Kit" (key: 6PX83qFaUYLQsCnff1YhkW).
///
/// Màu sắc và typography được trích xuất trực tiếp từ Figma nodes:
/// - Primary:   #573353 (tím đậm — branding chính)
/// - CTA:       #FDA758 (cam ấm — button)
/// - Background:#FFF3E9 (trắng kem ấm)
/// - Font:      Poppins (heading) + Manrope (body)
///
/// Cách dùng:
/// ```dart
/// // Light theme
/// final tokens = HabitBuilderTheme.light;
/// // Dark theme
/// final tokens = HabitBuilderTheme.dark;
/// // Trong MaterialApp
/// theme: tokens.toThemeData(),
/// ```
class HabitBuilderTheme {
  HabitBuilderTheme._();

  // ─────────────────────────────────────────────
  // MARK: Color Palette (từ Figma nodes)
  // ─────────────────────────────────────────────

  /// Màu chính — tím đậm branding (#573353)
  static const Color _primary = Color(0xFF573353);

  /// Màu text trên primary (trắng)
  static const Color _onPrimary = Color(0xFFFFFFFF);

  /// Màu secondary — cam ấm CTA (#FDA758)
  static const Color _secondary = Color(0xFFFDA758);

  /// Background ấm — trắng kem (#FFF3E9)
  static const Color _backgroundLight = Color(0xFFFFF3E9);

  /// Surface sáng — trắng thuần
  static const Color _surfaceLight = Color(0xFFFFFFFF);

  /// Text chính trên nền sáng — gần đen (#040920)
  static const Color _onBackgroundLight = Color(0xFF040920);

  /// Text phụ trên surface sáng
  static const Color _onSurfaceLight = Color(0xFF573353);

  /// Background tối — navy sâu (#040920)
  static const Color _backgroundDark = Color(0xFF040920);

  /// Surface tối — navy nhạt hơn
  static const Color _surfaceDark = Color(0xFF0D1233);

  /// Text chính trên nền tối
  static const Color _onBackgroundDark = Color(0xFFFFF3E9);

  /// Text phụ trên surface tối
  static const Color _onSurfaceDark = Color(0xFFFDA758);

  /// Màu lỗi
  static const Color _error = Color(0xFFFF6767);

  // ─────────────────────────────────────────────
  // MARK: Color Tokens
  // ─────────────────────────────────────────────

  static const ColorTokens _colorsLight = ColorTokens(
    primary: _primary,
    onPrimary: _onPrimary,
    secondary: _secondary,
    background: _backgroundLight,
    surface: _surfaceLight,
    error: _error,
    onBackground: _onBackgroundLight,
    onSurface: _onSurfaceLight,
  );

  static const ColorTokens _colorsDark = ColorTokens(
    primary: _secondary,         // cam ấm làm primary trong dark
    onPrimary: _backgroundDark,
    secondary: _primary,         // tím làm secondary trong dark
    background: _backgroundDark,
    surface: _surfaceDark,
    error: _error,
    onBackground: _onBackgroundDark,
    onSurface: _onSurfaceDark,
  );

  // ─────────────────────────────────────────────
  // MARK: Text Tokens
  // Poppins — heading / display
  // Manrope — body / label
  // ─────────────────────────────────────────────

  static const TextTokens _texts = TextTokens(
    // Display — Poppins, dùng cho hero section
    displayLarge: TextToken(
      fontFamily: 'Poppins',
      size: 57,
      weight: FontWeight.w700,
      letterSpacing: -0.25,
    ),
    displayMedium: TextToken(
      fontFamily: 'Poppins',
      size: 45,
      weight: FontWeight.w700,
    ),
    displaySmall: TextToken(
      fontFamily: 'Poppins',
      size: 36,
      weight: FontWeight.w600,
    ),

    // Headline — Poppins, dùng cho tiêu đề trang
    headlineLarge: TextToken(
      fontFamily: 'Poppins',
      size: 32,
      weight: FontWeight.w700,
    ),
    headlineMedium: TextToken(
      fontFamily: 'Poppins',
      size: 28,
      weight: FontWeight.w700,
    ),
    headlineSmall: TextToken(
      fontFamily: 'Poppins',
      size: 24,
      weight: FontWeight.w600,
    ),

    // Title — Poppins, dùng cho section header / card title
    titleLarge: TextToken(
      fontFamily: 'Poppins',
      size: 22,
      weight: FontWeight.w600,
    ),
    titleMedium: TextToken(
      fontFamily: 'Poppins',
      size: 16,
      weight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    titleSmall: TextToken(
      fontFamily: 'Poppins',
      size: 14,
      weight: FontWeight.w600,
      letterSpacing: 0.1,
    ),

    // Body — Manrope, dùng cho nội dung chính
    bodyLarge: TextToken(
      fontFamily: 'Manrope',
      size: 16,
      weight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextToken(
      fontFamily: 'Manrope',
      size: 14,
      weight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextToken(
      fontFamily: 'Manrope',
      size: 12,
      weight: FontWeight.w400,
      letterSpacing: 0.4,
    ),

    // Label — Manrope, dùng cho button / chip / caption
    labelLarge: TextToken(
      fontFamily: 'Manrope',
      size: 14,
      weight: FontWeight.w700,
      letterSpacing: 0.1,
    ),
    labelMedium: TextToken(
      fontFamily: 'Manrope',
      size: 12,
      weight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    labelSmall: TextToken(
      fontFamily: 'Manrope',
      size: 11,
      weight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // ─────────────────────────────────────────────
  // MARK: ThemeTokens instances
  // ─────────────────────────────────────────────

  /// Theme sáng — background kem ấm, primary tím đậm.
  static const ThemeTokens light = ThemeTokens(
    colors: _colorsLight,
    texts: _texts,
    isLight: true,
  );

  /// Theme tối — background navy sâu, primary cam ấm.
  static const ThemeTokens dark = ThemeTokens(
    colors: _colorsDark,
    texts: _texts,
    isLight: false,
  );
}
