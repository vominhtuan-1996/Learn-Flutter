import 'package:flutter/material.dart';
import 'package:learnflutter/core/debound.dart';
import 'package:learnflutter/shared/widgets/enable_widget.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';


class Tap extends StatefulWidget {
  final VoidCallback? onTap;
  final VoidCallback? onLongTap;
  final Widget? child;
  final bool dismissKeyboard;
  final bool isDelay;
  final int? delayRate;
  final Color? highLightColor;
  final Color? splashColor;
  final bool enable;
  final Color? disableColor;

  const Tap({
    super.key,
    this.onTap,
    this.onLongTap,
    this.child,
    this.delayRate,
    this.highLightColor,
    this.splashColor,
    this.enable = true,
    this.disableColor,
    this.isDelay = false,
    this.dismissKeyboard = true,
  });

  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  final SingleDebounce debounce = SingleDebounce();

  @override
  Widget build(BuildContext context) {
    final Color color = widget.highLightColor ?? Colors.transparent;

    return EnableWidget(
      enable: widget.enable,
      overLayDisableColor: widget.disableColor,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: color,
          hoverColor: color,
          focusColor: color,
          splashColor: widget.splashColor ?? Colors.transparent,
          onLongPress: widget.onLongTap,
          onTap: () {
            if (widget.dismissKeyboard) UtilsHelper.dismissKeyBoard(context: context);

            if (widget.isDelay) {
              debounce.runBefore(
                action: () {
                  if (widget.onTap != null) widget.onTap!();
                },
                rate: widget.delayRate,
              );
            } else {
              if (widget.onTap != null) widget.onTap!();
            }
          },
          child: widget.child,
        ),
      ),
    );
  }
}
