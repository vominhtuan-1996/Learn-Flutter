import 'dart:ui';
import 'package:flutter/widgets.dart';

/// Hiệu ứng Blur: item bị mờ (gaussian blur) khi ra xa tâm viewport.
class BlurEffect extends StatelessWidget {
  final double progress;
  final Widget child;
  final double maxBlur;

  const BlurEffect({
    super.key,
    required this.progress,
    required this.child,
    this.maxBlur = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final blur = (1.0 - progress) * maxBlur;
    if (blur < 0.1) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: child,
    );
  }
}
