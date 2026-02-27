// 📦 sliver_effects.dart
import 'package:flutter/material.dart';

/// Làm mờ widget theo scroll
class SliverFadeOnScroll extends StatelessWidget {
  final ScrollController controller;
  final double fadeStart;
  final double fadeEnd;
  final Widget child;

  const SliverFadeOnScroll({
    super.key,
    required this.controller,
    required this.fadeStart,
    required this.fadeEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final offset = controller.hasClients ? controller.offset : 0.0;
          final progress = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);
          final opacity = 1.0 - progress;
          return Opacity(opacity: opacity, child: child);
        },
      ),
    );
  }
}

/// Widget fade + scale theo scroll offset
class SliverFadeScaleOnScroll extends StatelessWidget {
  final ScrollController controller;
  final double fadeStart;
  final double fadeEnd;
  final double scaleStart;
  final double scaleEnd;
  final Widget child;

  const SliverFadeScaleOnScroll({
    super.key,
    required this.controller,
    required this.fadeStart,
    required this.fadeEnd,
    this.scaleStart = 1.0,
    this.scaleEnd = 0.7,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final offset = controller.hasClients ? controller.offset : 0.0;
          final progress = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);
          final opacity = 1.0 - progress;
          final scale = scaleStart + (scaleEnd - scaleStart) * progress;

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

/// Hero-style banner: translate lên, fade dần, scale nhỏ lại
class SliverHeroBanner extends StatelessWidget {
  final ScrollController controller;
  final double fadeStart;
  final double fadeEnd;
  final double translateY;
  final double scaleEnd;
  final Widget child;

  const SliverHeroBanner({
    super.key,
    required this.controller,
    this.fadeStart = 0,
    this.fadeEnd = 200,
    this.translateY = -40,
    this.scaleEnd = 0.7,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final offset = controller.hasClients ? controller.offset : 0.0;
          final progress = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);

          final opacity = 1.0 - progress;
          final scale = 1.0 - (1.0 - scaleEnd) * progress;
          final translate = translateY * progress;

          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, translate),
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
