import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';

class ScaleTranslateBuilder extends StatefulWidget {
  const ScaleTranslateBuilder({super.key, required this.index, required this.pageController, required this.child});
  final int index;
  final PageController pageController;
  final Widget child;
  @override
  State<ScaleTranslateBuilder> createState() => _ScaleTranslateBuilderState();
}

class _ScaleTranslateBuilderState extends State<ScaleTranslateBuilder> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pageController,
      builder: (context, child) {
        double value = 1.0;
        if (widget.pageController.position.haveDimensions) {
          value = widget.pageController.page! - widget.index;
          value = (1 - (value.abs())).clamp(0.0, 1.0);
        }
        return Container(
          padding: EdgeInsets.all(DeviceDimension.padding / 2),
          child: Transform(
            transform: Matrix4.identity()
              ..scale(value)
              ..rotateY(value * 0.2),
            child: widget.child,
          ),
        );
      },
    );
  }
}
