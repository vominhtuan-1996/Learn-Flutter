import 'package:flutter/material.dart';

class AppShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Widget? child;

  const AppShimmer._({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.child,
  });

  factory AppShimmer.box({
    required double width,
    required double height,
    double radius = 8,
  }) =>
      AppShimmer._(
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(radius),
      );

  factory AppShimmer.text({
    required double width,
    double height = 14,
  }) =>
      AppShimmer._(
        width: width,
        height: height,
        borderRadius: BorderRadius.circular(4),
      );

  factory AppShimmer.circle({
    required double size,
  }) =>
      AppShimmer._(
        width: size,
        height: size,
        borderRadius: BorderRadius.circular(size / 2),
      );

  // ponytail: custom child wraps the shimmer mask over arbitrary widget trees
  factory AppShimmer.custom({
    required Widget child,
    double width = double.infinity,
    double height = double.infinity,
  }) =>
      AppShimmer._(
        width: width,
        height: height,
        borderRadius: BorderRadius.zero,
        child: child,
      );

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE0E0E0);
    final highlight = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3A3A3A)
        : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [base, highlight, base],
                  stops: [
                    (_animation.value - 0.5).clamp(0.0, 1.0),
                    (_animation.value).clamp(0.0, 1.0),
                    (_animation.value + 0.5).clamp(0.0, 1.0),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
