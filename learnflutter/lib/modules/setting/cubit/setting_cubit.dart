import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/global/var_global.dart';
import 'package:learnflutter/cubit/base_cubit.dart';
import 'package:learnflutter/modules/setting/state/setting_state.dart';

enum ThemeEvent { toggleDark, toggleLight }

class SettingThemeCubit extends BaseCubit<SettingThemeState> {
  SettingThemeCubit() : super(SettingThemeState());

  void changeBrightness(bool? value) {
    emit(state.copyWith(light: value));
  }

  void changeScaleText(double? value) {
    emit(state.copyWith(scaleText: value));
  }

  void changeThemeBackground(Color? value) {
    themeBackgoundGlobal = value;
    emit(state.copyWith(themeBackgound: value));
  }
}
