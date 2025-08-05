import 'dart:ui';
import 'package:flutter/material.dart';

class SliverCollapseToFAB extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Widget fab;
  final double maxHeight;
  final double minHeight;
  final Offset fabOffset;
  final double fabSize;
  final double childSize;

  SliverCollapseToFAB({
    required this.child,
    required this.fab,
    this.maxHeight = 200,
    this.minHeight = 60,
    this.fabOffset = const Offset(20, 20),
    this.fabSize = 56,
    this.childSize = 100,
  });

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final double size = lerpDouble(childSize, fabSize, progress)!;
    final double top = lerpDouble(40, MediaQuery.of(context).size.height - fabOffset.dy - size, progress)!;
    final double left = lerpDouble(20, MediaQuery.of(context).size.width - fabOffset.dx - size, progress)!;
    final double scale = lerpDouble(1.0, fabSize / childSize, progress)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: top,
          left: left,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: SizedBox(
              width: childSize,
              height: childSize,
              child: fab,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant SliverCollapseToFAB oldDelegate) => true;
}
