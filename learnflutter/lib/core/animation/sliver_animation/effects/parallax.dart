import 'package:flutter/widgets.dart';

/// Hiệu ứng Parallax: item dịch chuyển theo trục Y khi ra xa tâm viewport.
class ParallaxEffect extends StatelessWidget {
  final double progress;
  final Widget child;
  final double maxOffset;

  const ParallaxEffect({
    super.key,
    required this.progress,
    required this.child,
    this.maxOffset = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    final dy = (1.0 - progress) * maxOffset;
    return Transform.translate(offset: Offset(0, dy), child: child);
  }
}
