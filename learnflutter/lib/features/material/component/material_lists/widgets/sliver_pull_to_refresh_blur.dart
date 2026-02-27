// example/sliver_pull_to_refresh_blur.dart

// lib/src/sliver_backdrop_header.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class SliverBackdropHeader extends StatelessWidget {
  final double blurAmount;
  final Widget child;
  final Color backgroundColor;

  const SliverBackdropHeader({
    super.key,
    required this.blurAmount,
    required this.child,
    this.backgroundColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 160,
      backgroundColor: Colors.transparent,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: backgroundColor),
          if (blurAmount > 0)
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurAmount,
                sigmaY: blurAmount,
              ),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
          child,
        ],
      ),
    );
  }
}
