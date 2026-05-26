import 'dart:ui';
import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Thu nhỏ (scale down) item khi item rời xa tâm màn hình.
class ScaleTransform extends ViewportTransform {
  /// Kích thước nhỏ nhất của item khi nó nằm ở biên màn hình.
  final double minScale;

  ScaleTransform({
    this.minScale = 0.8,
  });

  @override
  void apply(
    TransformState state,
    ViewportItem item,
    ViewportContext context,
  ) {
    // Tâm của viewport
    final center = context.scrollOffset + context.viewportSize / 2;

    // Tâm của item
    final itemCenter = item.itemOffset + item.itemExtent / 2;

    // Khoảng cách từ tâm item tới tâm viewport
    final distance = (itemCenter - center).abs();

    // Chuẩn hóa khoảng cách từ 0.0 (ở tâm) đến 1.0 (ở biên màn hình)
    // Giả định viewportSize / 2 là ra tới biên màn hình.
    // Thực tế có thể chia cho context.viewportSize nguyên bản nếu muốn scale mượt hơn ra ngoài màn hình.
    final normalized = (distance / (context.viewportSize / 2)).clamp(0.0, 1.0);

    // Tính toán scale: nội suy (lerp) từ 1.0 (ở tâm) xuống minScale (ở biên)
    state.scale = lerpDouble(1.0, minScale, normalized)!;
  }
}
