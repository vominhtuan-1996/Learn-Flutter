import 'dart:math';

import 'package:flutter/material.dart';

class ExplosionEffect extends StatefulWidget {
  final VoidCallback? onComplete;
  final Offset center;

  const ExplosionEffect({super.key, this.onComplete, required this.center});

  @override
  State<ExplosionEffect> createState() => _ExplosionEffectState();
}

class _ExplosionEffectState extends State<ExplosionEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Offset> _directions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete?.call();
        }
      });

    // 6 hướng bay (có thể tăng số lượng)
    _directions = List.generate(
      6,
      (index) {
        final angle = 2 * pi * index / 6;
        return Offset(cos(angle), sin(angle));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeOut.transform(_controller.value);
        return Stack(
          children: _directions.map((dir) {
            final offset = widget.center + dir * 60 * progress;
            final opacity = 1.0 - progress;
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
