import 'package:flutter/material.dart';

class NoKeyboardRebuild extends StatelessWidget {
  final Widget child;

  const NoKeyboardRebuild({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.only(bottom: 0); // ignore viewInsets
    return MediaQuery(
      data: MediaQuery.of(context).removeViewInsets(removeBottom: true),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
