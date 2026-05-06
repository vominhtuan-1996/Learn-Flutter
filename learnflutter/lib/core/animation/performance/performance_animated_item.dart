import 'package:flutter/widgets.dart';
import 'viewport_transform.dart';

/// Một thành phần Sliver item hiệu năng cao.
/// Kết hợp [RepaintBoundary] để tách lớp vẽ và [ViewportTransform] để tạo animation 60fps.
class PerformanceAnimatedItem extends StatelessWidget {
  final Widget child;

  const PerformanceAnimatedItem({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ViewportTransform(
        child: child,
      ),
    );
  }
}
