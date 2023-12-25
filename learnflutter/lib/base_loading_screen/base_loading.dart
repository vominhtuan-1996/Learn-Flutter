import 'package:flutter/material.dart';
import 'package:learnflutter/Helpper/utills_helpper.dart';
import 'package:learnflutter/src/app_box_decoration.dart';

class BaseLoading extends StatefulWidget {
  BaseLoading({
    super.key,
    required this.isLoading,
    required this.message,
    this.styleMessage = const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
    required this.child,
  });
  final bool isLoading;
  final String message;
  final TextStyle? styleMessage;
  final Widget child;
  @override
  State<BaseLoading> createState() => BaseLoadingState();
}

class BaseLoadingState extends State<BaseLoading> {
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
    double widthText = getTextWidth(text: widget.message, textStyle: widget.styleMessage!);
    double heightText = getTextHeight(
      text: widget.message,
      textStyle: widget.styleMessage!,
      maxWidthOfWidget: MediaQuery.of(context).size.width - 60,
    );
    return Scaffold(
        body: Stack(
      children: [
        Container(
          color: Colors.white,
          child: widget.child,
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
                          widget.message,
                          style: widget.styleMessage,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ))
      ],
    ));
  }
}
