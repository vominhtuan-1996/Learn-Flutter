import 'package:flutter/material.dart';
import '../ticker/core_ticker.dart';
import '../controller/core_anim_controller.dart';

/// Widget core - lắng nghe [CoreAnimController] thông qua [CoreTicker] global
/// và rebuild tối thiểu bằng [RepaintBoundary].
class AnimatedRepaint extends StatefulWidget {
  final CoreAnimController controller;
  final Widget child;
  final Widget Function(double value, Widget child) builder;

  const AnimatedRepaint({
    super.key,
    required this.controller,
    required this.child,
    required this.builder,
  });

  @override
  State<AnimatedRepaint> createState() => _AnimatedRepaintState();
}

class _AnimatedRepaintState extends State<AnimatedRepaint>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Đảm bảo CoreTicker đã được start
    CoreTicker().start(this);
    // Đăng ký listener với key = hashCode của widget instance này
    CoreTicker().add(this, _onTick);
  }

  @override
  void dispose() {
    // Bắt buộc gỡ listener để tránh memory leak
    CoreTicker().remove(this);
    super.dispose();
  }

  void _onTick(double dt) {
    widget.controller.update(dt);
    // Chỉ rebuild nếu animation chưa ổn định
    if (mounted && !widget.controller.isSettled) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: widget.builder(
        widget.controller.value,
        widget.child,
      ),
    );
  }
}
