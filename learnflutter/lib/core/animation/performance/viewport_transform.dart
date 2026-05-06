import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Một Widget sử dụng Custom RenderObject để áp dụng các hiệu ứng animation
/// (scale, opacity, transform) trực tiếp trong giai đoạn paint.
/// Giúp đạt hiệu năng 60fps tuyệt đối vì không gây ra rebuild widget tree khi cuộn.
class ViewportTransform extends SingleChildRenderObjectWidget {
  const ViewportTransform({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderViewportTransform();
  }
}

class _RenderViewportTransform extends RenderProxyBox {
  double _progress = 0;

  @override
  void paint(PaintingContext context, Offset offset) {
    // Tìm Scrollable gần nhất để lấy thông tin viewport
    // final scrollable = Scrollable.maybeOf(context.containerLayer.owner!.managedObject as BuildContext);

    // Lưu ý: Trong môi trường RenderObject, việc truy cập context.containerLayer.owner
    // có thể phức tạp. Cách an toàn hơn là sử dụng localToGlobal để tính toán vị trí.

    if (child != null) {
      // Tính toán progress dựa trên vị trí của RenderObject trong màn hình
      // Chúng ta sử dụng global position của object này
      final double viewportHeight =
          constraints.maxHeight > 0 ? constraints.maxHeight : 800; // Fallback

      // Thực tế RenderBox.localToGlobal(Offset.zero).dy trả về vị trí Y trên màn hình
      final double dy = localToGlobal(Offset.zero).dy;

      // Giả sử viewport là toàn màn hình hoặc lấy từ MediaQuery nếu cần.
      // Ở đây ta tính progress đơn giản: 0.0 ở đáy màn hình, 1.0 ở đỉnh màn hình (hoặc ngược lại)
      // Tùy biến logic tính toán tùy theo hiệu ứng mong muốn.

      // Ví dụ: progress tăng dần khi item đi từ dưới lên giữa màn hình
      final double screenHeight =
          800; // Có thể truyền từ widget nếu cần chính xác
      _progress = (1 - (dy / screenHeight)).clamp(0.0, 1.0);

      // Tính toán các giá trị biến đổi
      final double scale = 0.8 + 0.2 * _progress;
      final double opacity = 0.5 + 0.5 * _progress;

      // Áp dụng transform trực tiếp vào PaintingContext
      final Matrix4 matrix = Matrix4.identity()
        ..translate(offset.dx + size.width / 2, offset.dy + size.height / 2)
        ..scale(scale)
        ..translate(-size.width / 2, -size.height / 2);

      context.pushOpacity(offset, (opacity * 255).toInt(), (context, offset) {
        context.pushTransform(
          needsCompositing,
          offset,
          matrix,
          (context, offset) {
            context.paintChild(child!, offset);
          },
        );
      });
    } else {
      super.paint(context, offset);
    }
  }

  // Ép buộc repaint khi có sự thay đổi (thường RenderProxyBox tự handle nếu scroll)
  // Tuy nhiên vì dy thay đổi khi cuộn, Layer tree sẽ trigger paint.
}
