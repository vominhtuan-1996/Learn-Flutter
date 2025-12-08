import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/src/lib/tap_builder/src/animated_tap_builder.dart';
import 'package:learnflutter/src/lib/tap_builder/src/tap_state.dart';
import 'package:learnflutter/utils_helper/extension/extension_context.dart';

class AnimatedTapButtonBuilder extends StatelessWidget {
  const AnimatedTapButtonBuilder({
    super.key,
    this.child,
    this.onTap,
    this.padding,
    this.onLongPress,
    this.isEnabled = true,
    this.background,
  });
  final Widget? child;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final EdgeInsetsGeometry? padding;
  final bool isEnabled;
  final Color? background;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !isEnabled,
      child: AnimatedTapBuilder(
        onLongPress: onLongPress,
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap?.call();
        },
        builder: (context, state, isFocused, cursorLocation, cursorAlignment) {
          cursorAlignment = state == TapState.pressed ? Alignment(-cursorAlignment.x, -cursorAlignment.y) : Alignment.center;
          return AnimatedContainer(
            transformAlignment: Alignment.center,
            transform: Matrix4.rotationX(-cursorAlignment.y * 0.2)
              ..rotateY(cursorAlignment.x * 0.2)
              ..scale(
                state == TapState.pressed ? 0.94 : 1.0,
              ),
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: background ?? context.colorScheme.primaryContainer,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding: padding ?? EdgeInsets.all(DeviceDimension.padding / 2),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: state == TapState.pressed ? 0.6 : 0.8,
                      child: child,
                    ),
                    Positioned.fill(
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment(-cursorAlignment.x, -cursorAlignment.y),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.01),
                            boxShadow: [
                              BoxShadow(
                                color: context.theme.primaryColor.withOpacity(state == TapState.pressed ? 0.5 : 0.0),
                                blurRadius: 200,
                                spreadRadius: 130,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
