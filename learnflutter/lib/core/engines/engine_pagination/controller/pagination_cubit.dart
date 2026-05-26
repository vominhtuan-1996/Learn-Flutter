import 'package:flutter/material.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';
import 'package:learnflutter/core/engines/engine_pagination/controller/pagination_state.dart';

/// Cubit điều phối trạng thái, tiến trình chuyển bước của Stepper.
class AppPaginationCubit extends BaseCubit<AppPaginationState> {
  final ScrollController scrollController;

  AppPaginationCubit(this.scrollController, int? numbStep, bool isMaintainedTab)
      : super(AppPaginationState.initial(numbStep, isMaintainedTab));

  /// Chuyển sang bước tiếp theo
  Future<void> nextStep(bool isLastStep) async {
    final next = state.currentStep + 1;
    emit(state.setUploadedStep());
    emit(state.cloneWith(currentStep: next));
    _scrollAnimatedListStep(next);
  }

  /// Quay lại bước phía trước
  Future<void> previousStep() async {
    final prev = state.currentStep - 1;
    emit(state.cloneWith(currentStep: prev));
    _scrollAnimatedListStep(prev);
  }

  /// Nhảy trực tiếp tới bước cụ thể (nếu bước đó đã hoàn thành dữ liệu)
  Future<void> goToThisStep(int index) async {
    if (index - 1 < 0 || index - 1 >= state.paginationModel.length) {
      return;
    }
    
    // Nếu bước đó chưa được làm và không phải tab bảo trì thì không cho phép click nhảy trực tiếp
    if (!state.paginationModel[index - 1].isUploadedStep) {
      return;
    }

    emit(state.cloneWith(currentStep: index));
    _scrollAnimatedListStep(index);
  }

  /// Điều khiển thanh indicator cuộn theo bước hiện tại (Animated Scroll)
  void _scrollAnimatedListStep(int index) {
    if (!scrollController.hasClients) return;

    if (index == 1) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final maxScroll = scrollController.position.maxScrollExtent;
    final totalSteps = state.paginationModel.length;
    
    if (totalSteps <= 1) return;

    final lengthOneStep = maxScroll / (totalSteps - 1);
    final currentStepLength = (index - 1) * lengthOneStep;

    scrollController.animateTo(
      currentStepLength.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
