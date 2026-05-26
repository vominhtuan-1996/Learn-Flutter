import 'package:flutter/material.dart';
import 'render_layer.dart';

/// Bộ điều khiển chịu trách nhiệm quản lý danh sách các [RenderLayer].
/// Kế thừa ChangeNotifier để có thể thông báo cho widget (RenderObject) vẽ lại khi cần.
class RenderLayerController extends ChangeNotifier {
  final List<RenderLayer> _layers = [];

  /// Lấy danh sách các layer hiện tại (chỉ đọc)
  List<RenderLayer> get layers => List.unmodifiable(_layers);

  /// Thêm một layer vào engine.
  void add(RenderLayer layer) {
    _layers.add(layer);
    notifyListeners();
  }

  /// Xoá một layer khỏi engine.
  void remove(RenderLayer layer) {
    _layers.remove(layer);
    notifyListeners();
  }

  /// Làm sạch tất cả các layer.
  void clear() {
    _layers.clear();
    notifyListeners();
  }

  /// Cập nhật logic cho tất cả các layer (gọi từ Timeline/Ticker).
  /// Sau khi cập nhật, tự động gọi [notifyListeners] để kích hoạt paint lại nếu cần.
  void update(double dt) {
    bool needsPaint = false;
    for (final layer in _layers) {
      if (!layer.visible) continue;
      layer.update(dt);
      // Giả định rằng mỗi lần update dt, ta cần vẽ lại.
      // (Trong tương lai có thể tối ưu bằng cách để layer tự đánh dấu needsPaint).
      needsPaint = true;
    }

    if (needsPaint) {
      notifyListeners();
    }
  }

  /// Thực hiện vẽ tất cả các layer lên [Canvas].
  /// Sẽ duyệt tuần tự từ dưới lên trên.
  void paint(Canvas canvas, Size size) {
    for (final layer in _layers) {
      if (!layer.visible) continue;

      // Nếu opacity < 1.0, ta có thể áp dụng saveLayer để alpha blend toàn bộ layer.
      if (layer.opacity < 1.0) {
        final bounds = Offset.zero & size;
        canvas.saveLayer(
          bounds,
          Paint()
            ..color = Color.fromRGBO(0, 0, 0,
                layer.opacity), // Flutter 3.10+ hỗ trợ dùng color cho alpha
        );
        layer.paint(canvas, size);
        canvas.restore();
      } else {
        layer.paint(canvas, size);
      }
    }
  }
}
