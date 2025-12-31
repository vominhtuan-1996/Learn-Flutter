import 'package:flutter/material.dart';

class KeyboardObserver extends StatefulWidget {
  final Widget child;
  const KeyboardObserver({super.key, required this.child});

  @override
  State<KeyboardObserver> createState() => _KeyboardObserverState();
}

class _KeyboardObserverState extends State<KeyboardObserver> with WidgetsBindingObserver {
  double bottomPadding = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottom = view.viewInsets.bottom;

    setState(() {
      bottomPadding = bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: widget.child,
    );
  }
}
