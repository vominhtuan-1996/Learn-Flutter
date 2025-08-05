import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum RippleEffectType {
  zoom,
  fade,
  none,
  defaultRipple,
}

class RippleOverride extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final RippleEffectType effect;
  final bool enableHaptic;

  const RippleOverride({
    super.key,
    required this.child,
    this.onTap,
    this.effect = RippleEffectType.zoom,
    this.enableHaptic = false,
  });

  @override
  State<RippleOverride> createState() => _RippleOverrideState();
}

class _RippleOverrideState extends State<RippleOverride> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _opacity = 1.0;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    _animation = _controller;
    super.initState();
  }

  void _onTapDown(_) {
    if (widget.effect == RippleEffectType.zoom) {
      _controller.reverse();
    } else if (widget.effect == RippleEffectType.fade) {
      setState(() => _opacity = 0.5);
    }
  }

  void _onTapUp(_) {
    if (widget.effect == RippleEffectType.zoom) {
      _controller.forward();
    } else if (widget.effect == RippleEffectType.fade) {
      setState(() => _opacity = 1.0);
    }
  }

  void _onTapCancel() {
    if (widget.effect == RippleEffectType.zoom) {
      _controller.forward();
    } else if (widget.effect == RippleEffectType.fade) {
      setState(() => _opacity = 1.0);
    }
  }

  void _handleTap() {
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget animatedChild = widget.child;

    if (widget.effect == RippleEffectType.zoom) {
      animatedChild = AnimatedBuilder(
        animation: _animation,
        builder: (_, child) => Transform.scale(
          scale: _animation.value,
          child: child,
        ),
        child: widget.child,
      );
    } else if (widget.effect == RippleEffectType.fade) {
      animatedChild = AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _opacity,
        child: widget.child,
      );
    }

    if (widget.effect == RippleEffectType.defaultRipple) {
      return InkWell(
        onTap: _handleTap,
        child: widget.child,
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _handleTap,
      child: animatedChild,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
