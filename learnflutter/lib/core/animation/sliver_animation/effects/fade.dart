import 'package:flutter/widgets.dart';

/// Hiệu ứng Fade: item mờ dần khi ra xa tâm viewport.
class FadeEffect extends StatelessWidget {
  final double progress;
  final Widget child;
  final double minOpacity;

  const FadeEffect({
    super.key,
    required this.progress,
    required this.child,
    this.minOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = (minOpacity + (1.0 - minOpacity) * progress).clamp(0.0, 1.0);
    return Opacity(opacity: opacity, child: child);
  }
}
