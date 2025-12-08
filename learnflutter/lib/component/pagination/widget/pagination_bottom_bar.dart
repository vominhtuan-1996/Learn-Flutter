// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/pagination/cubit/pagination_cubit.dart';
import 'package:learnflutter/component/pagination/state/pagination_state.dart';
import 'package:learnflutter/component/pagination/widget/mb_button.dart';

import '../helper/pagination_helper.dart';

class BottomBarPagination extends StatefulWidget {
  BottomBarPagination({
    Key? key,
    required this.isFirstStep,
    required this.isLastStep,
    this.onNextStep,
    this.onPreviousStep,
    this.onCompleteStep,
    required this.tabType,
  }) : super(key: key);
  bool isFirstStep;
  bool isLastStep;
  Future<bool> Function(int indexCurrentStep, int indexNextStep)? onNextStep;
  Future<bool> Function(int index)? onPreviousStep;
  Future<bool> Function(int index)? onCompleteStep;
  String tabType;

  @override
  State<BottomBarPagination> createState() => _BottomBarPaginationState();
}

class _BottomBarPaginationState extends State<BottomBarPagination> {
  double paddingVertical = DeviceDimension.verticalSize(20);
  double paddingHorizontal = DeviceDimension.horizontalSize(10);
  double buttonMinHorizontalSize = DeviceDimension.horizontalSize(120);

  @override
  Widget build(BuildContext context) {
    bool isLastStepMaintainedTab = widget.tabType == TabType.maintained && widget.isLastStep;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
      child: BlocBuilder<PaginationCubit, PaginationState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: !widget.isFirstStep,
                child: MbButton(
                  delayRate: 400,
                  isDelay: true,
                  minWidth: isLastStepMaintainedTab ? DeviceDimension.screenWidth - (paddingHorizontal * 2) : buttonMinHorizontalSize,
                  color: Colors.transparent,
                  borderColor: Colors.transparent,
                  textColor: AppColors.backButtonColor,
                  label: "< Trở về",
                  onPress: () async {
                    if (await widget.onPreviousStep!(state.currentStep - 1)) {
                      context.read<PaginationCubit>().previousStep();
                    }
                  },
                ),
              ),
              Visibility(
                visible: !isLastStepMaintainedTab,
                child: MbButton(
                  delayRate: 400,
                  isDelay: true,
                  minWidth: widget.isFirstStep ? DeviceDimension.screenWidth - (paddingHorizontal * 2) : buttonMinHorizontalSize,
                  //check logic has complete step
                  label: (widget.isLastStep) ? "Hoàn tất >" : "Tiếp tục ${widget.isFirstStep ? "" : " >"}",
                  onPress: () async {
                    if (widget.isLastStep) {
                      await widget.onCompleteStep!(state.currentStep);
                    } else {
                      if (await widget.onNextStep!(state.currentStep, state.currentStep + 1)) {
                        context.read<PaginationCubit>().nextStep(widget.isLastStep);
                      }
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
