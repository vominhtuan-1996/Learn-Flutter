// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/component/pagination/cubit/pagination_cubit.dart';
import 'package:learnflutter/component/pagination/helper/pagination_helper.dart';
import 'package:learnflutter/component/pagination/mixin/handle_scroll_mixin.dart';
import 'package:learnflutter/component/pagination/state/pagination_state.dart';
import 'package:learnflutter/component/pagination/widget/pagination_bottom_bar.dart';
import 'package:learnflutter/component/pagination/widget/pagination_item.dart';
import 'package:learnflutter/utils_helper/image_helper.dart';

class PaginationWidget extends StatefulWidget {
  PaginationWidget({
    Key? key,
    required this.content,
    this.numbStep = 0,
    this.hasCompleteStep = false,
    this.onNextStep,
    this.onPreviousStep,
    this.onCompleteStep,
    this.goToThisStep,
    required this.tabType,
  }) : super(key: key);
  final Widget content;
  final int numbStep;
  final String tabType;
  bool hasCompleteStep;
  Future<bool> Function(int indexCurrentStep, int indexNextStep)? onNextStep;
  Future<bool> Function(int index)? onPreviousStep;
  Future<bool> Function(int index)? onCompleteStep;
  Future<bool> Function(int index)? goToThisStep;

  @override
  State<PaginationWidget> createState() => _PaginationWidgetState();
}

class _PaginationWidgetState extends State<PaginationWidget> with HandleScrollMixin {
  @override
  void initState() {
    initScroll();
    super.initState();
  }

  @override
  void dispose() {
    disposeScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaginationCubit>(
      create: (context) {
        return PaginationCubit(
            scrollController, widget.numbStep, widget.tabType == TabType.maintained);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BlocBuilder<PaginationCubit, PaginationState>(
            builder: (context, state) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: DeviceDimension.horizontalSize(10)),
                  height: DeviceDimension.verticalSize(70),
                  child: CustomScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    slivers: [
                      SliverFillRemaining(
                          hasScrollBody: false,
                          child: Builder(builder: (context) {
                            List<Widget> children = [];
                            for (int index = 1; index <= widget.numbStep; index++) {
                              children.add(ItemPagination(
                                goToThisStep: widget.goToThisStep,
                                currentStep: state.currentStep,
                                indexStep: index,
                                paginationModel: state.paginationModel[index - 1],
                                isCompleteStep: state.currentStep == widget.numbStep + 1,
                                tabType: widget.tabType,
                              ));
                              if (index < widget.numbStep) {
                                children.add(
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: DeviceDimension.horizontalSize(5)),
                                    child: ImageHelper.loadFromAsset(
                                      state.paginationModel[index - 1].isUploadedStep ||
                                              widget.tabType == TabType.maintained
                                          ? PaginationAsset.orangeDivider
                                          : PaginationAsset.dashDivider,
                                      width: DeviceDimension.horizontalSize(20),
                                    ),
                                  ),
                                );
                              }
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: children,
                            );
                          }))
                    ],
                  ));
            },
          ),
          Expanded(
            child: widget.content,
          ),
          BlocBuilder<PaginationCubit, PaginationState>(builder: (context, state) {
            return (widget.numbStep != null)
                ? BottomBarPagination(
                    tabType: widget.tabType,
                    onNextStep: widget.onNextStep,
                    onCompleteStep: widget.onCompleteStep,
                    onPreviousStep: widget.onPreviousStep,
                    isFirstStep: state.currentStep == 1,
                    isLastStep: widget.hasCompleteStep
                        ? state.currentStep == widget.numbStep + 1
                        : state.currentStep == widget.numbStep,
                  )
                : Container();
          })
        ],
      ),
    );
  }
}
