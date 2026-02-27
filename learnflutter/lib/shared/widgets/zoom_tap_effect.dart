import 'package:flutter/widgets.dart';

class ZoomTapEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ZoomTapEffect({required this.child, required this.onTap});

  @override
  State<ZoomTapEffect> createState() => _ZoomTapEffectState();
}

class _ZoomTapEffectState extends State<ZoomTapEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
    super.initState();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, child) => Transform.scale(
          scale: _animation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
