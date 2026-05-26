/// Cung cấp ngữ cảnh môi trường (viewport) hiện tại cho hệ thống Transform.
class ViewportContext {
  /// Kích thước chiều dài hoặc chiều rộng của Viewport (tùy theo hướng cuộn).
  final double viewportSize;

  /// Khoảng cách cuộn hiện tại của Sliver/List.
  final double scrollOffset;

  /// Tốc độ cuộn hiện tại của người dùng (pixels per giây).
  final double velocity;

  const ViewportContext({
    required this.viewportSize,
    required this.scrollOffset,
    required this.velocity,
  });
}
