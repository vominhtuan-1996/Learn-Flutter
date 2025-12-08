import 'package:flutter/material.dart';

class GlobalNoKeyboardRebuild extends StatelessWidget {
  final Widget child;
  const GlobalNoKeyboardRebuild({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = WidgetsBinding.instance.platformDispatcher.views.first;
    final viewInsets = mq.viewInsets;

    return MediaQuery(
      data: MediaQueryData.fromView(mq).removeViewInsets(removeBottom: true),
      child: child,
    );
  }
}
