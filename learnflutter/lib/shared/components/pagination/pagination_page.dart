import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// [PaginationPage] là một Widget bao bọc hỗ trợ phát hiện trạng thái hiển thị của trang.
/// Thường dùng trong hệ thống video feed hoặc animation để tự động Play/Pause khi vào/ra khỏi viewport.
class PaginationPage extends StatelessWidget {
  final int index;
  final Widget child;
  final Function(double visibilityFraction)? onVisibilityChanged;

  const PaginationPage({
    super.key,
    required this.index,
    required this.child,
    this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('pagination-page-$index'),
      onVisibilityChanged: (info) {
        if (onVisibilityChanged != null) {
          onVisibilityChanged!(info.visibleFraction);
        }
      },
      child: child,
    );
  }
}
