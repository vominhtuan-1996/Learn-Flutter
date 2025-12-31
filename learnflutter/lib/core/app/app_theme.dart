import 'package:flutter/material.dart';
import 'package:learnflutter/core/theme_token/extension_theme.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';

class AppThemes {
  static ThemeData primaryTheme(
    BuildContext context,
    SettingThemeState state,
  ) {
    return state.tokens.toThemeData();
  }
}
