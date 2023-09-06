import 'package:flutter/material.dart';

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
}
