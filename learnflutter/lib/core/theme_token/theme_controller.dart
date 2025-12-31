import 'package:flutter/material.dart';
import 'package:learnflutter/core/theme_token/colors_token.dart';
import 'package:learnflutter/core/theme_token/text_token.dart';

class ThemeController extends ChangeNotifier {
  ThemeTokens tokens;

  ThemeController(this.tokens);

  void updateColor(ColorTokens newColors) {
    tokens = tokens.copyWith(colors: newColors);
    notifyListeners();
  }

  void updateText(TextTokens newTexts) {
    tokens = tokens.copyWith(texts: newTexts);
    notifyListeners();
  }

  void updateDisplayLarge(TextTokens newTexts) {
    tokens = tokens.copyWith(texts: newTexts);
    notifyListeners();
  }

  void updateTitleMedium(TextTokens newTexts) {
    tokens = tokens.copyWith(texts: newTexts);
    notifyListeners();
  }

  void updateBodyMedium(TextTokens newTexts) {
    tokens = tokens.copyWith(texts: newTexts);
    notifyListeners();
  }

  void toggleBrightness(bool light) {
    tokens = tokens.copyWith(isLight: light);
    notifyListeners();
  }
}

class ThemeTokens {
  final ColorTokens colors;
  final TextTokens texts;
  final bool isLight;

  const ThemeTokens({
    required this.colors,
    required this.texts,
    this.isLight = true,
  });

  ThemeTokens copyWith({
    ColorTokens? colors,
    TextTokens? texts,
    bool? isLight,
  }) {
    return ThemeTokens(
      colors: colors ?? this.colors,
      texts: texts ?? this.texts,
      isLight: isLight ?? this.isLight,
    );
  }
}
