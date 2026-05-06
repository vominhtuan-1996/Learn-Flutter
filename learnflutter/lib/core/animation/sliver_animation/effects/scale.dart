import 'package:flutter/widgets.dart';

/// Hiệu ứng Scale: item thu nhỏ khi ra xa tâm viewport.
class ScaleEffect extends StatelessWidget {
  final double progress;
  final Widget child;
  final double minScale;

  const ScaleEffect({
    super.key,
    required this.progress,
    required this.child,
    this.minScale = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    final scale = minScale + (1.0 - minScale) * progress;
    return Transform.scale(scale: scale, child: child);
  }
}
