import 'package:flutter/cupertino.dart';

class KeyboardAvoiding extends StatelessWidget {
  final Widget child;
  final Curve curve;
  final Duration duration;
  final double kFactor;

  const KeyboardAvoiding({
    required this.child,
    this.curve = Curves.easeInOut,
    this.duration = const Duration(milliseconds: 200),
    this.kFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final verticalOffset = MediaQuery.of(context).viewInsets.bottom * -kFactor;

    return AnimatedContainer(
      duration: duration,
      curve: curve,
      transform: Matrix4.translationValues(
        0.0,
        verticalOffset,
        0.0,
      ),
      child: child,
    );
  }
}
