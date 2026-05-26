import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Làm mờ item dựa vào khoảng cách tới tâm viewport.
/// Càng xa tâm màn hình, độ mờ (blur sigma) càng tăng.
class BlurTransform extends ViewportTransform {
  /// Mức độ blur tối đa để tránh lỗi giật lag hiệu năng.
  final double maxBlur;

  /// Tốc độ tăng blur. Số càng lớn, phải cuộn càng xa mới đạt maxBlur.
  final double distanceDivisor;

  BlurTransform({
    this.maxBlur = 20.0,
    this.distanceDivisor = 100.0,
  });

  @override
  void apply(
    TransformState state,
    ViewportItem item,
    ViewportContext context,
  ) {
    // Tối ưu: Nếu tốc độ cuộn rất cao (velocity lớn), ta có thể quyết định tắt blur
    // để giữ vững 60FPS. Giả sử ngưỡng velocity là 2000 px/s.
    if (context.velocity.abs() > 2000.0) {
      state.blur = 0.0;
      return;
    }

    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final distance = (itemCenter - center).abs();

    // Tính blur tỉ lệ thuận với khoảng cách, giới hạn từ 0 đến maxBlur
    state.blur = (distance / distanceDivisor).clamp(0.0, maxBlur);
  }
}
