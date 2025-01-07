import 'dart:async';

import 'package:learnflutter/component/base_loading_screen/state/base_loading_state.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';

class BaseLoadingCubit extends BaseCubit<BaseLoadingState> {
  BaseLoadingCubit() : super(BaseLoadingState());

  void showLoading({
    String? message,
    required Function() func,
    Function(Object error)? onFailed,
    Function(dynamic e)? onSuccess,
  }) async {
    bool loaded = state.isLoading ?? false;
    emit(state.copyWith(isLoading: !loaded, message: message));
    try {
      final result = await func();
      await Future.delayed(const Duration(seconds: 4));
      dissmissLoading();
      if (onSuccess != null) onSuccess(result);
    } catch (e) {
      Future<void> onFail(error) async {
        if (onFailed != null) {
          await onFailed(error);
        }
      }
    }
  }

  void dissmissLoading() {
    bool loaded = state.isLoading ?? false;
    emit(state.copyWith(isLoading: !loaded));
  }
}
