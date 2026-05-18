import 'package:flutter/material.dart';

class ColorTokens {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color onBackground;
  final Color onSurface;

  const ColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.onBackground,
    required this.onSurface,
  });

  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onPrimary,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      error: error,
      onError: Colors.white,
    );
  }

  ColorTokens copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? error,
    Color? onBackground,
    Color? onSurface,
  }) {
    return ColorTokens(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      onBackground: onBackground ?? this.onBackground,
      onSurface: onSurface ?? this.onSurface,
    );
  }
}
