import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/component/base_loading_screen/state/base_loading_state.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/src/lib/floating_draggable_widget/floating_draggable_widget.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/core/app/app_box_decoration.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

class BaseDraggableLoading extends StatefulWidget {
  const BaseDraggableLoading({
    super.key,
    this.isLoading = false,
    this.message = '',
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButtonLocation,
    required this.floatSize,
    this.hasDeletedWidget = true,
    this.onDragEvent,
    this.onDragging,
    this.autoAlign = true,
    this.disableBounceAnimation = true,
    this.onDeleteWidget,
    this.backgroundColor = Colors.white,
  });
  final bool isLoading;
  final String? message;
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Size floatSize;
  final bool hasDeletedWidget;
  final Function(double, double)? onDragEvent;
  final Function(bool)? onDragging;
  final Function()? onDeleteWidget;
  final bool autoAlign;
  final bool disableBounceAnimation;
  final Color backgroundColor;

  @override
  State<BaseDraggableLoading> createState() => BaseLoadingScreenState();
}

class BaseLoadingScreenState extends State<BaseDraggableLoading> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseLoadingCubit, BaseLoadingState>(
      builder: (context, state) {
        double widthText = UtilsHelper.getTextWidth(text: state.message ?? "Đang cập nhật dữ liệu...", textStyle: context.textTheme.bodyLarge!.copyWith(color: Colors.white));
        double heightText = UtilsHelper.getTextHeight(
          text: state.message ?? "",
          textStyle: context.textTheme.bodyMedium!.copyWith(color: Colors.white),
          maxWidthOfWidget: context.mediaQuery.size.width - 60,
        );
        widthText = widthText > context.mediaQuery.size.width ? context.mediaQuery.size.width - DeviceDimension.padding : widthText;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            FloatingDraggableWidget(
              floatingWidget: widget.floatingActionButton ??
                  FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
              onDragEvent: widget.onDragEvent,
              onDragging: widget.onDragging,
              autoAlign: widget.autoAlign,
              disableBounceAnimation: widget.disableBounceAnimation,
              autoAlignType: AlignmentType.both,
              floatingWidgetHeight: widget.floatSize.height,
              floatingWidgetWidth: widget.floatSize.width,
              dx: context.mediaQuery.size.width - widget.floatSize.width - DeviceDimension.padding / 2,
              dy: context.mediaQuery.size.height - widget.floatSize.height - DeviceDimension.padding / 2,
              deleteWidgetDecoration: widget.hasDeletedWidget
                  ? BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white12, Colors.grey],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [.0, 1],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    )
                  : null,
              deleteWidget: widget.hasDeletedWidget
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: Colors.black87),
                      ),
                      child: const Icon(Icons.close, color: Colors.black87),
                    )
                  : null,
              onDeleteWidget: widget.onDeleteWidget,
              mainScreenWidget: Scaffold(
                appBar: widget.appBar ?? AppBar(),
                body: widget.child,
                extendBody: true,
                backgroundColor: widget.backgroundColor,
              ),
            ),
            Visibility(
              visible: state.isLoading ?? false,
              child: Container(
                color: Colors.grey.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: (context.mediaQuery.size.width - widthText - DeviceDimension.padding) / 2),
                // width: context.mediaQuery.size.width,
                child: Center(
                    child: Container(
                  decoration: AppBoxDecoration.boxDecorationBorderRadius(
                    borderRadiusValue: 8.0,
                    colorBackground: Colors.white,
                  ),
                  height: widthText > context.mediaQuery.size.width ? heightText + 100 : heightText + 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: AppBoxDecoration.boxDecorationBorderRadius(
                          borderRadiusValue: 8.0,
                          colorBackground: Colors.white.withOpacity(0.8),
                        ),
                        child: Center(
                          child: Image.asset(
                            width: context.mediaQuery.size.width / 2,
                            height: heightText + 90,
                            'assets/images/loading_mobimap_rii.gif',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // const Center(
                      //   child: CircularProgressIndicator(
                      //     strokeWidth: 3.0,
                      //     valueColor: AlwaysStoppedAnimation(Colors.black54),
                      //     strokeAlign: 1,
                      //     color: Colors.red,
                      //   ),
                      // ),
                      Expanded(
                        child: Center(
                          child: Text(
                            state.message ?? "",
                            style: context.textTheme.bodyLarge!.copyWith(color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ),
            ),
          ],
        );
      },
    );
  }
}
