import 'package:flutter/cupertino.dart';

Future<T?> pushToController<T>({required BuildContext context, bool useRootNavigator = true, required String route}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).pushNamed(route);
}

void popToRootControler({
  required BuildContext context,
}) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}

/// Text height
double getTextHeight({required String text, required TextStyle textStyle, required double maxWidthOfWidget, double minWidthOfWidget = 0}) {
  final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr, text: TextSpan(text: text, style: textStyle))
    ..layout(maxWidth: maxWidthOfWidget, minWidth: minWidthOfWidget);
  return textPainter.height;
}

/// Text Width
double getTextWidth({required String text, required TextStyle textStyle}) {
  final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr, text: TextSpan(text: text, style: textStyle))..layout();
  return textPainter.size.width;
}
