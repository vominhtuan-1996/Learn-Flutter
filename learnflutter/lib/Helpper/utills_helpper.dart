import 'package:flutter/cupertino.dart';

Future<T?> pushToController<T>({required BuildContext context, bool useRootNavigator = true, required String route}) {
  return Navigator.of(context, rootNavigator: useRootNavigator).pushNamed(route);
}

void popToRootControler({
  required BuildContext context,
}) {
  Navigator.of(context).popUntil((route) => route.isFirst);
}
