// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/app/app_colors.dart';
import 'package:learnflutter/core/app/app_text_style.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/pagination/cubit/pagination_cubit.dart';
import 'package:learnflutter/component/pagination/helper/pagination_helper.dart';
import 'package:learnflutter/component/pagination/model/pagination_model.dart';
import 'package:learnflutter/component/pagination/widget/mb_tap.dart';
import 'package:learnflutter/utils_helper/image_helper.dart';

class ItemPagination extends StatefulWidget {
  ItemPagination({
    Key? key,
    required this.currentStep,
    required this.indexStep,
    required this.paginationModel,
    required this.isCompleteStep,
    required this.goToThisStep,
    required this.tabType,
  }) : super(key: key);
  int currentStep;
  int indexStep;
  bool isCompleteStep;
  String tabType;
  PaginationModel paginationModel;
  Future<bool> Function(int index)? goToThisStep;

  @override
  State<ItemPagination> createState() => _ItemPaginationState();
}

class _ItemPaginationState extends State<ItemPagination> {
  @override
  Widget build(BuildContext context) {
    return MbTap(
      delayRate: 400,
      isDelay: true,
      onTap: () async {
        final isUploadedStep = context
            .read<PaginationCubit>()
            .state
            .paginationModel[widget.indexStep - 1]
            .isUploadedStep;
        if (!isUploadedStep) {
          return;
        }
        if (await widget.goToThisStep!(widget.indexStep)) {
          context.read<PaginationCubit>().goToThisStep(widget.indexStep);
        }
      },
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: widget.paginationModel.isUploadedStep ||
                    (widget.tabType == TabType.maintained && widget.currentStep != widget.indexStep)
                ? AppColors.primary
                : AppColors.yellowBackground,
            shape: BoxShape.circle,
            border: Border.all(
              width: 1,
              color: widget.paginationModel.isUploadedStep ||
                      (widget.isCompleteStep ? widget.currentStep - 1 : widget.currentStep) ==
                          widget.indexStep ||
                      widget.tabType == TabType.maintained
                  ? AppColors.primary
                  : Colors.transparent,
            ),
          ),
          padding: EdgeInsets.all(DeviceDimension.defaultSize(5)),
          child: Builder(
            builder: (context) {
              if (widget.isCompleteStep) {
                if (widget.currentStep - 1 == widget.indexStep) {
                  return ImageHelper.loadFromAsset(
                      widget.tabType == TabType.maintained
                          ? PaginationAsset.icCircleEye
                          : PaginationAsset.icCirclePencil,
                      width: DeviceDimension.horizontalSize(40),
                      height: DeviceDimension.verticalSize(40));
                }
              } else {
                if (widget.currentStep == widget.indexStep) {
                  return ImageHelper.loadFromAsset(
                      widget.tabType == TabType.maintained
                          ? PaginationAsset.icCircleEye
                          : PaginationAsset.icCirclePencil,
                      width: DeviceDimension.horizontalSize(40),
                      height: DeviceDimension.verticalSize(40));
                }
              }
              return SizedBox(
                height: DeviceDimension.verticalSize(35),
                width: DeviceDimension.horizontalSize(35),
                child: Center(
                  child: Text(
                    widget.indexStep + 1 < 10 ? "0${widget.indexStep}" : "${widget.indexStep}",
                    style: AppTextStyles.themeBodyMedium.copyWith(
                      color: widget.paginationModel.isUploadedStep ||
                              widget.tabType == TabType.maintained
                          ? AppColors.white
                          : AppColors.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
