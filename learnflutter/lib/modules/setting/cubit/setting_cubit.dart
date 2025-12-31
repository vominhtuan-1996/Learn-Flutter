import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/theme_token/colors_token.dart';
import 'package:learnflutter/core/theme_token/text_token.dart';
import 'package:learnflutter/core/theme_token/theme_controller.dart';
import 'package:learnflutter/core/theme_token/theme_storage.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';

enum ThemeEvent { toggleDark, toggleLight }

class SettingThemeCubit extends Cubit<SettingThemeState> {
  SettingThemeCubit() : super(SettingThemeState(defaultThemeTokens)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await ThemeStorage.load();
    if (saved != null) {
      emit(SettingThemeState(saved));
    }
  }

  void updateColors(ColorTokens colors) {
    final newTokens = state.tokens.copyWith(colors: colors);
    emit(SettingThemeState(newTokens));
    ThemeStorage.save(newTokens); // auto-save
  }

  void updateTexts(TextTokens texts) {
    final newTokens = state.tokens.copyWith(texts: texts);
    emit(SettingThemeState(newTokens));
    ThemeStorage.save(newTokens);
  }

  void updateDisplayLarge(TextToken token) {
    final newTexts = state.tokens.texts.copyWith(displayLarge: token);
    final newTokens = state.tokens.copyWith(texts: newTexts);
    emit(SettingThemeState(newTokens));
    ThemeStorage.save(newTokens);
  }

  void updateTextTokens(TextTokens texts) {
    // emit(
    //   state.copyWith(
    //     tokens: state.tokens.copyWith(texts: texts),
    //   ),
    // );
    final newTokens = state.copyWith(tokens: state.tokens.copyWith(texts: texts));

    emit(newTokens);
    ThemeStorage.save(newTokens.tokens);
  }

  void toggleBrightness(bool isLight) {
    final newTokens = state.tokens.copyWith(isLight: isLight);
    emit(SettingThemeState(newTokens));
    ThemeStorage.save(newTokens);
  }

  void resetTheme() {
    ThemeStorage.clear();
    emit(SettingThemeState(defaultThemeTokens));
    ThemeStorage.save(defaultThemeTokens);
  }
}

final defaultThemeTokens = ThemeTokens(
  isLight: true,

  // 🎨 Colors
  colors: ColorTokens(
    primary: const Color(0xFF6750A4),
    onPrimary: Colors.white,
    secondary: const Color(0xFF625B71),
    background: const Color(0xFFFFFBFE),
    surface: const Color(0xFFFFFBFE),
    error: const Color(0xFFB3261E),
    onBackground: const Color(0xFF1C1B1F),
    onSurface: const Color(0xFF1C1B1F),
  ),

  // 🔤 Text
  texts: TextTokens(
    displayLarge: const TextToken(
      fontFamily: 'Roboto',
      size: 32,
      weight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    displayMedium: const TextToken(
      fontFamily: 'Roboto',
      size: 28,
      weight: FontWeight.w600,
    ),
    displaySmall: const TextToken(
      fontFamily: 'Roboto',
      size: 24,
      weight: FontWeight.w600,
    ),
    titleLarge: const TextToken(
      fontFamily: 'Roboto',
      size: 20,
      weight: FontWeight.w600,
    ),
    titleMedium: const TextToken(
      fontFamily: 'Roboto',
      size: 18,
      weight: FontWeight.w600,
    ),
    titleSmall: const TextToken(
      fontFamily: 'Roboto',
      size: 16,
      weight: FontWeight.w600,
    ),
    bodyLarge: const TextToken(
      fontFamily: 'Roboto',
      size: 16,
      weight: FontWeight.w400,
    ),
    bodyMedium: const TextToken(
      fontFamily: 'Roboto',
      size: 14,
      weight: FontWeight.w400,
    ),
    bodySmall: const TextToken(
      fontFamily: 'Roboto',
      size: 12,
      weight: FontWeight.w400,
    ),
    headlineLarge: const TextToken(
      fontFamily: 'Roboto',
      size: 22,
      weight: FontWeight.w500,
    ),
    headlineMedium: const TextToken(
      fontFamily: 'Roboto',
      size: 20,
      weight: FontWeight.w500,
    ),
    headlineSmall: const TextToken(
      fontFamily: 'Roboto',
      size: 18,
      weight: FontWeight.w500,
    ),
    labelLarge: const TextToken(
      fontFamily: 'Roboto',
      size: 14,
      weight: FontWeight.w500,
    ),
    labelMedium: const TextToken(
      fontFamily: 'Roboto',
      size: 12,
      weight: FontWeight.w500,
    ),
    labelSmall: const TextToken(
      fontFamily: 'Roboto',
      size: 11,
      weight: FontWeight.w500,
    ),
  ),
);
