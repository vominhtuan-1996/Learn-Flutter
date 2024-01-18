import 'package:flutter/material.dart';
import 'package:learnflutter/core/extension/extension_context.dart';
import 'package:learnflutter/helpper/utills_helpper.dart';
import 'package:learnflutter/src/app_box_decoration.dart';

class BaseLoading extends StatefulWidget {
  BaseLoading({
    super.key,
    required this.isLoading,
    this.message = 'Đang cập nhật dữ liệu...',
    required this.child,
    this.appBar,
  });
  final bool isLoading;
  final String? message;
  final Widget child;
  final PreferredSizeWidget? appBar;
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
    double widthText = getTextWidth(text: widget.message ?? "Đang cập nhật dữ liệu...", textStyle: context.textTheme.bodyMedium!.copyWith(color: Colors.white));
    double heightText = getTextHeight(
      text: widget.message ?? "Đang cập nhật dữ liệu...",
      textStyle: context.textTheme.bodyMedium!.copyWith(color: Colors.white),
      maxWidthOfWidget: MediaQuery.of(context).size.width - 60,
    );
    return Stack(
      children: [
        Scaffold(
          appBar: widget.appBar ?? AppBar(),
          body: Container(
            color: Colors.white,
            child: widget.child,
          ),
        ),
        Visibility(
          visible: widget.isLoading,
          child: Container(
            color: Colors.grey.withOpacity(0.7),
            child: Center(
                child: Container(
              decoration: AppBoxDecoration.boxDecorationBorderRadius(
                borderRadiusValue: 8.0,
                colorBackground: Colors.black54,
              ),
              width: widthText > MediaQuery.of(context).size.width ? MediaQuery.of(context).size.width - 60 : widthText + 40,
              height: widthText > MediaQuery.of(context).size.width ? heightText + 100 : heightText + 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: heightText > 0 ? 15 : 10),
                  const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  SizedBox(height: heightText > 0 ? 15 : 10),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.message ?? "Đang cập nhật dữ liệu...",
                        style: context.textTheme.bodyMedium!.copyWith(color: Colors.white),
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
  }
}
