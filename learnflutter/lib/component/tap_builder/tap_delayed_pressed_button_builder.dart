import 'package:flutter/material.dart';
import 'package:learnflutter/src/lib/tap_builder/src/tap_builder.dart';
import 'package:learnflutter/src/lib/tap_builder/src/tap_state.dart';

class TapDelayedPressedButton extends StatelessWidget {
  const TapDelayedPressedButton({
    super.key,
    this.child,
    this.onPressed,
    this.minPressedDuration = const Duration(milliseconds: 500),
    this.padding,
    this.pressedColor = const Color(0xFF0AAF97),
    this.inactiveColor = Colors.grey,
    this.isEnabled = true,
  });
  final Widget? child;
  final void Function()? onPressed;
  final Duration minPressedDuration;
  final EdgeInsetsGeometry? padding;
  final Color pressedColor;
  final Color inactiveColor;
  final bool isEnabled;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !isEnabled,
      child: TapBuilder(
        onTap: () {
          onPressed?.call();
        },
        minPressedDuration: minPressedDuration,
        hitTestBehavior: HitTestBehavior.translucent,
        builder: (context, state, isFocused) => AnimatedContainer(
          padding: padding ??
              const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 28,
              ),
          duration: minPressedDuration,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.white.withOpacity(isFocused ? 0.2 : 0.0),
              width: 2,
            ),
            color: () {
              switch (state) {
                case TapState.disabled:
                  return Colors.grey;
                case TapState.hover:
                  return const Color(0xFF0AAF97);
                case TapState.inactive:
                  return inactiveColor;
                case TapState.pressed:
                  return pressedColor;
              }
            }(),
          ),
          child: child,
        ),
      ),
    );
  }
}
