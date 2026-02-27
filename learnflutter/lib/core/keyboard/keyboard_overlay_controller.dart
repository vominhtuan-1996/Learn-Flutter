import 'package:flutter/material.dart';

/// Lớp KeyboardOverlayController quản lý trạng thái của các thành phần giao diện được hiển thị đè lên (overlay) khi bàn phím xuất hiện.
/// Nó cung cấp một cơ chế tập trung để đồng bộ hóa kích thước và khả năng hiển thị của overlay với các chuyển động thực tế của bàn phím.
/// Việc sử dụng mô hình Singleton giúp cho bất kỳ thành phần nào trong ứng dụng cũng có thể truy cập và đăng ký nhận thông tin cập nhật trạng thái overlay một cách nhất quán.
/// Đây là giải pháp quan trọng để xây dựng các thanh công cụ (toolbar) hoặc gợi ý nhập liệu nằm ngay phía trên bàn phím.
class KeyboardOverlayController {
  /// Singleton instance của KeyboardOverlayController.
  static final KeyboardOverlayController instance =
      KeyboardOverlayController._internal();
  KeyboardOverlayController._internal();

  /// keyboardHeight lưu trữ giá trị chiều cao hiện tại của bàn phím để điều chỉnh vị trí của overlay.
  final ValueNotifier<double> keyboardHeight = ValueNotifier(0);

  /// keyboardVisible giúp các widget đăng ký lắng nghe biết được khi nào cần hiển thị hoặc ẩn overlay.
  final ValueNotifier<bool> keyboardVisible = ValueNotifier(false);

  /// Phương thức update được gọi để cập nhật đồng thời trạng thái hiển thị và chiều cao của bàn phím cho overlay.
  /// Nó thường được kích hoạt bởi các dịch vụ giám sát bàn phím cấp thấp hơn như KeyboardService để đảm bảo dữ liệu luôn tươi mới.
  /// Việc cập nhật thông qua ValueNotifier giúp các widget giao diện liên quan có thể tự động vẽ lại một cách hiệu quả.
  void update(bool visible, double height) {
    keyboardVisible.value = visible;
    keyboardHeight.value = visible ? height : 0;
  }
}
