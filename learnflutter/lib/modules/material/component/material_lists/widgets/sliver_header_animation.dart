import 'package:flutter/material.dart';

class SliverHeaderAnimation extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final Widget Function(BuildContext context, double progress) builder;

  SliverHeaderAnimation({
    required this.maxHeight,
    required this.minHeight,
    required this.builder,
  });

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return builder(context, progress);
  }

  @override
  bool shouldRebuild(covariant SliverHeaderAnimation oldDelegate) =>
      oldDelegate.maxHeight != maxHeight ||
      oldDelegate.minHeight != minHeight ||
      oldDelegate.builder != builder;
}
