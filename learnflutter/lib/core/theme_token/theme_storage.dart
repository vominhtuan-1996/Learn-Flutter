import 'dart:convert';
import 'package:learnflutter/core/theme_token/extension_theme.dart';
import 'package:learnflutter/core/theme_token/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  static const _key = 'app_theme_tokens';

  /// Save
  static Future<void> save(ThemeTokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tokens.toJson());
    await prefs.setString(_key, jsonString);
  }

  /// Load
  static Future<ThemeTokens?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;

    return ThemeTokensJson.fromJson(
      jsonDecode(jsonString),
    );
  }

  /// Clear (reset)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
