import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';

SettingThemeCubit getThemeBloc(BuildContext context) {
  return BlocProvider.of<SettingThemeCubit>(context);
}
