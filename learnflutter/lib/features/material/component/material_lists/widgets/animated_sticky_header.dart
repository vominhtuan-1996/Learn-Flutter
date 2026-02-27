import 'package:flutter/material.dart';

class AnimatedStickyHeader extends SliverPersistentHeaderDelegate {
  final String title;
  final double minExtentHeight;
  final double maxExtentHeight;

  AnimatedStickyHeader({
    required this.title,
    this.minExtentHeight = 60,
    this.maxExtentHeight = 120,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / (maxExtentHeight - minExtentHeight);
    final clamped = progress.clamp(0.0, 1.0);

    final scale = 1.0 - (0.2 * clamped); // scale từ 1.0 -> 0.8
    final opacity = 1.0 - (0.3 * clamped); // mờ dần nhẹ

    return Container(
      color: Colors.white,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.centerLeft,
        child: Opacity(
          opacity: opacity,
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }

  @override
  double get minExtent => minExtentHeight;

  @override
  double get maxExtent => maxExtentHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
