import 'package:flutter/material.dart';
import 'package:learnflutter/core/global/func_global.dart';

class AppDivider extends StatelessWidget {
  const AppDivider._(
      {super.key, required this.height, required this.width, this.color});

  factory AppDivider.vertical(
      {Key? key, double width = 1, Color? color, height = double.infinity}) {
    return AppDivider._(key: key, height: height, width: width, color: color);
  }

  factory AppDivider.horizontal({Key? key, double height = 1, Color? color}) {
    return AppDivider._(
        key: key, height: height, width: double.infinity, color: color);
  }

  final double height;
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      color: color ?? getThemeBloc(context).state.tokens.colors.primary,
    );
  }
}
