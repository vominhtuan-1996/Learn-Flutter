import 'dart:math';

import 'package:learnflutter/component/bottom_sheet/state/bottom_sheet_state.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';

class BottomSheetCubit extends BaseCubit<BottomSheetState> {
  BottomSheetCubit(BottomSheetState initialState) : super(BottomSheetState());

  void updateHeight({
    double? newHeight,
  }) async {
    if (newHeight == 0) {
      return;
    }
    emit(state.copyWith(height: newHeight));
  }
}
