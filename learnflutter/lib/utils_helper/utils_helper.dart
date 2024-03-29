// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:learnflutter/src/extension.dart';

class UtilsHelper {
  UtilsHelper._();

  /// For the current context
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Back util [RoutePredicate] is true
  /// EX:
  /// UtilsHelper.popUntil(UtilsHelper.navigatorKey.currentContext!, (route) => route.settings.name == Routes.splash);
  static void popUntil(BuildContext context, RoutePredicate predicate) {
    final navigator = Navigator.of(context);
    navigator.popUntil(predicate);
  }

  /// back pop all and route to routeName
  static void popUntilRouteTo(BuildContext context, String routeName) {
    popUntil(context, (route) => route.settings.name == routeName);
  }

  /// back pop all and route to routeName
  static void popAndPushName(BuildContext context, String routeName, [dynamic result]) {
    Navigator.popAndPushNamed(context, routeName, result: result);
  }

  static Future<dynamic> navigationPushNamed(BuildContext context, String route, {dynamic data}) async {
    var navigator = Navigator.of(context);
    return await navigator.pushNamed(route, arguments: data);
  }

  static void fMapLog(String fmt, [Object? arg1, Object? arg2, Object? arg3, Object? arg4]) {
    print('${StackTrace.current} --> $fmt');
  }

  static void logDebug(dynamic label) {
    print(label);
    Iterable<String> lines = StackTrace.current.toString().trimRight().split('\n');
    for (var element in lines) {
      if (element.substring(1, 3).toInt == 1) {
        String temp = element;
        final tempss = temp.split("dart");
        final pack = tempss.first;
        final packs = pack.split('(');
        final line = tempss.last.split(':');
        print("package : ${packs.last}dart\t\t\t\tline : ${line[1]}");
        break;
      }
    }
  }

  /// Text height
  static double getTextHeight({required String text, required TextStyle textStyle, required double maxWidthOfWidget, double minWidthOfWidget = 0}) {
    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr, text: TextSpan(text: text, style: textStyle))
      ..layout(maxWidth: maxWidthOfWidget, minWidth: minWidthOfWidget);
    return textPainter.height;
  }

  /// Text Width
  static double getTextWidth({required String text, required TextStyle textStyle}) {
    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr, text: TextSpan(text: text, style: textStyle))..layout();
    return textPainter.size.width;
  }
}
