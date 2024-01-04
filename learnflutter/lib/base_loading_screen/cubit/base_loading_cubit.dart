import 'dart:async';

import 'package:learnflutter/base_loading_screen/state/base_loading_state.dart';
import 'package:learnflutter/cubit/base_cubit.dart';

class BaseLoadingCubit extends BaseCubit<BaseLoadingState> {
  BaseLoadingCubit(init) : super(BaseLoadingState(isLoading: false));

  void showLoading({String? message}) {
    bool loaded = state.isLoading ?? false;
    emit(state.copyWith(isLoading: !loaded, message: message));
    Timer(Duration(seconds: 2), () {
      dissmissLoading();
    });
  }

  void dissmissLoading() {
    bool loaded = state.isLoading ?? false;
    emit(state.copyWith(isLoading: !loaded));
  }
}
