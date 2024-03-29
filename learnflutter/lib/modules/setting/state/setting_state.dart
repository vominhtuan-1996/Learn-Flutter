import 'package:flutter/material.dart';
import 'package:learnflutter/core/global/var_global.dart';

class SettingThemeState {
  final ThemeData? themeData;
  final bool? light;
  final double? scaleText;
  Color? themeBackgound = themeBackgoundGlobal;
  SettingThemeState({this.themeData, this.light = true, this.scaleText = 1.0, this.themeBackgound});

  factory SettingThemeState.initial({
    ThemeData? themeData,
  }) {
    return SettingThemeState(
      themeData: themeData,
    );
  }

  SettingThemeState copyWith({
    ThemeData? themeData,
    bool? light,
    double? scaleText,
    Color? themeBackgound,
  }) {
    return SettingThemeState(
      themeData: themeData ?? this.themeData,
      light: light ?? this.light,
      scaleText: scaleText ?? this.scaleText,
      themeBackgound: themeBackgound ?? this.themeBackgound,
    );
  }

  List<Object?> get props => [themeData, light, scaleText, themeBackgound];
}
