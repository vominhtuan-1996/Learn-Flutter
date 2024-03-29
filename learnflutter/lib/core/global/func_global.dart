import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/modules/setting/cubit/setting_cubit.dart';

SettingThemeCubit getThemeBloc(BuildContext context) {
  return BlocProvider.of<SettingThemeCubit>(context);
}

BaseLoadingCubit getLoadingCubit(BuildContext context) {
  return BlocProvider.of<BaseLoadingCubit>(context);
}

void showLoading({BuildContext? context, String? message}) {
  getLoadingCubit(context!).showLoading(message: message);
}

void dismissLoading(BuildContext context) {
  getLoadingCubit(context).dissmissLoading();
}
