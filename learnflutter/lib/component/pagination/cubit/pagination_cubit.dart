import 'package:flutter/material.dart';
import 'package:learnflutter/component/pagination/state/pagination_state.dart';
import 'package:learnflutter/core/cubit/base_cubit.dart';

class PaginationCubit extends BaseCubit<PaginationState> {
  PaginationCubit(this.scrollController, int? numbStep, bool isMaintainedTab) : super(PaginationState.initial(numbStep, isMaintainedTab));
  ScrollController scrollController;

  Future<void> nextStep(bool isLastStep) async {
    int currentStep = state.currentStep + 1;
    emit(state.setUploadedStep());
    emit(state.cloneWith(currentStep: currentStep));
    _scrollAnimatedListStep(currentStep);
  }

  Future<void> previousStep() async {
    int currentStep = state.currentStep - 1;
    emit(state.cloneWith(currentStep: currentStep));
    _scrollAnimatedListStep(currentStep);
  }

  Future<void> goToThisStep(int index) async {
    // step has not maintenance cant be click
    if (!state.paginationModel[index - 1].isUploadedStep) {
      return;
    }

    emit(state.cloneWith(currentStep: index));
  }

  void _scrollAnimatedListStep(int index) {
    if (index == 1) {
      scrollController.animateTo(scrollController.position.minScrollExtent, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
      return;
    }

    final lengthOneStep = scrollController.position.maxScrollExtent / (state.paginationModel.length - 1);
    final currentStepLength = index * lengthOneStep;

    scrollController.animateTo(currentStepLength, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }
}
