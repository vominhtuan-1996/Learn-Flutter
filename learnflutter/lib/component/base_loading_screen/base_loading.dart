import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learnflutter/component/base_loading_screen/cubit/base_loading_cubit.dart';
import 'package:learnflutter/component/base_loading_screen/state/base_loading_state.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';
import 'package:learnflutter/app/app_box_decoration.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

class BaseLoading extends StatefulWidget {
  const BaseLoading({
    super.key,
    this.isLoading = false,
    this.message = '',
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
  });
  final bool isLoading;
  final String? message;
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  @override
  State<BaseLoading> createState() => BaseLoadingScreenState();
}

class BaseLoadingScreenState extends State<BaseLoading> {
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
            Scaffold(
              // extendBody: false,
              appBar: widget.appBar ?? AppBar(),
              body: Container(
                width: context.mediaQuery.size.width,
                height: context.mediaQuery.size.height,
                child: widget.child,
              ),
              floatingActionButton: widget.floatingActionButton,
              drawer: widget.drawer,
              extendBodyBehindAppBar: false,
            ),
            Visibility(
              visible: state.isLoading ?? false,
              child: Container(
                color: Colors.grey.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: (context.mediaQuery.size.width - widthText - DeviceDimension.padding) / 2),
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
