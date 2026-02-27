
import 'package:flutter/material.dart';
import 'package:learnflutter/core/global/func_global.dart';

class AppText extends StatelessWidget {
  AppText(
    this.text, {
    super.key,
    this.requiredMark = false,
    this.style,
    this.color,
    this.fontSize,
    this.weight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  });

  final String text;
  final bool requiredMark;
  TextStyle? style;
  final Color? color;
  final double? fontSize;
  final FontWeight? weight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final newStyle = (style ??= getThemeBloc(context).state.tokens.texts.bodyMedium.toTextStyle(color ?? Colors.transparent)).copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: weight,
      decoration: decoration,
      decorationColor: color,
    );

    final newTextAlign = textAlign ?? TextAlign.start;
    final newOverFlow = overflow ?? TextOverflow.clip;

    if (requiredMark) {
      return RichText(
        textAlign: newTextAlign,
        maxLines: maxLines,
        overflow: newOverFlow,
        text: TextSpan(
          text: text,
          style: newStyle,
          children: [
            TextSpan(text: ' *', style: TextStyle(color: getThemeBloc(context).state.tokens.colors.primary)),
          ],
        ),
      );
    }

    return Text(text, style: newStyle, textAlign: newTextAlign, maxLines: maxLines, overflow: newOverFlow);
  }
}
