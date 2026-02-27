import 'package:learnflutter/core/theme/theme_controller.dart';

class SettingThemeState {
  final ThemeTokens tokens;

  const SettingThemeState(this.tokens);

  SettingThemeState copyWith({
    ThemeTokens? tokens,
  }) {
    return SettingThemeState(
      tokens ?? this.tokens,
    );
  }
}
