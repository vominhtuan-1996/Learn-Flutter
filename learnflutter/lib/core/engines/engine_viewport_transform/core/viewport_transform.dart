import 'viewport_context.dart';
import 'viewport_item.dart';

/// Lớp lưu trữ trạng thái hiển thị của một Item sau khi được xử lý qua Transform Pipeline.
class TransformState {
  /// Scale uniform — kết hợp với scaleX/scaleY khi map sang Transform.
  double scale = 1.0;
  double scaleX = 1.0;
  double scaleY = 1.0;
  double opacity = 1.0;
  double translateX = 0.0;
  double translateY = 0.0;
  double blur = 0.0;

  /// Rotation 2D (radian) — `Transform.rotate`.
  double rotation = 0.0;

  /// Rotation 3D quanh trục X (radian) — flip ngang trong Matrix4.
  double rotationX = 0.0;

  /// Rotation 3D quanh trục Y (radian) — coverflow / flip dọc.
  double rotationY = 0.0;

  /// Skew radian theo từng trục.
  double skewX = 0.0;
  double skewY = 0.0;

  /// 0 = grayscale, 1 = giữ nguyên màu. Map qua `ColorFiltered` saturation matrix.
  double saturation = 1.0;

  /// Tint color blend (ARGB). Null = không tint.
  int? tintARGB;

  /// Chỉ số xếp lớp — widget có thể render Stack theo zIndex để item ở tâm nổi trên.
  double zIndex = 0.0;
}

/// Lớp cơ sở cho các phép toán transform dựa vào khoảng cách của Item và Viewport.
abstract class ViewportTransform {
  /// Hàm áp dụng phép biến đổi.
  /// Thay đổi trực tiếp các giá trị bên trong [state].
  void apply(
    TransformState state,
    ViewportItem item,
    ViewportContext context,
  );
}
