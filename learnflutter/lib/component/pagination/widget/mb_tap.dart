import 'package:flutter/material.dart';
import 'package:learnflutter/core/debound.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

class MbTap extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? child;
  final bool dismissKeyboard;
  final bool isDelay;
  final int? delayRate;
  final Color? highLightColor;
  final Color? splashColor;
  final bool enable;
  final Color? disableColor;

  MbTap({
    Key? key,
    this.onTap,
    this.child,
    this.delayRate,
    this.highLightColor,
    this.splashColor,
    this.enable = true,
    this.disableColor,
    this.isDelay = false,
    this.dismissKeyboard = true,
  }) : super(key: key);

  final SingleDebounce debounce = SingleDebounce();

  @override
  Widget build(BuildContext context) {
    final Color color = highLightColor ?? Colors.transparent;

    return AbsorbPointer(
      absorbing: !enable,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: color,
          hoverColor: color,
          focusColor: color,
          splashColor: splashColor ?? Colors.transparent,
          onTap: () {
            if (isDelay) {
              debounce.runBefore(
                action: () {
                  if (onTap != null) onTap!();
                },
                rate: delayRate,
              );
            } else {
              if (onTap != null) onTap!();
            }
          },
          child: child,
        ),
      ),
    );
  }
}
