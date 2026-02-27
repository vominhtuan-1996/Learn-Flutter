import 'package:flutter/material.dart';

/// Lớp KeyboardObserver là một Widget tiện ích được thiết kế để theo dõi các thay đổi về kích thước do bàn phím ảo gây ra tại chỗ.
/// Khác với các giải pháp toàn cục, nó cho phép một vùng giao diện cụ thể có thể tự phản ứng với sự xuất hiện của bàn phím thông qua việc đăng ký observer cục bộ.
/// Widget này tự động quản lý việc thêm và xóa observer trong vòng đời của nó để tránh rò rỉ bộ nhớ (memory leaks).
/// Đây là giải pháp linh hoạt khi bạn chỉ muốn áp dụng hiệu ứng đệm lót cho một phần của màn hình thay vì toàn bộ ứng dụng.
class KeyboardObserver extends StatefulWidget {
  final Widget child;
  const KeyboardObserver({super.key, required this.child});

  @override
  State<KeyboardObserver> createState() => _KeyboardObserverState();
}

class _KeyboardObserverState extends State<KeyboardObserver>
    with WidgetsBindingObserver {
  /// bottomPadding lưu trữ giá trị chiều cao của bàn phím đang chiếm dụng trên màn hình.
  double bottomPadding = 0;

  @override
  void initState() {
    super.initState();
    // Bắt đầu lắng nghe các thay đổi về chỉ số hệ thống ngay khi widget được khởi tạo.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Luôn đảm bảo xóa observer khi widget không còn tồn tại để bảo vệ tài nguyên hệ thống.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Phương thức didChangeMetrics được gọi tự động khi bàn phím xuất hiện hoặc biến mất.
  /// Nó thực hiện việc trích xuất thông tin view insets từ platform dispatcher và cập nhật lại trạng thái local của widget.
  /// Việc gọi setState trong hàm này sẽ kích hoạt quá trình vẽ lại widget con với khoảng đệm phù hợp.
  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final bottom = view.viewInsets.bottom;

    if (mounted) {
      setState(() {
        bottomPadding = bottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: widget.child,
    );
  }
}
