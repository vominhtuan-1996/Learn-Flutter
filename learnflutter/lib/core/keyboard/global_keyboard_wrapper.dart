import 'package:flutter/material.dart';
import 'keyboard_service.dart';

/// Lớp GlobalKeyboardWrapper đóng vai trò là một lớp bao bọc (wrapper) ở cấp độ toàn cục để quản lý khoảng trống giao diện khi bàn phím xuất hiện.
/// Nó lắng nghe các thay đổi về chiều cao của bàn phím từ KeyboardService và tự động điều chỉnh phần đệm lót (padding) phía dưới của các widget con.
/// Việc sử dụng hiệu ứng AnimatedPadding giúp cho quá trình thay đổi kích thước diễn ra mượt mà, tránh hiện tượng giao diện bị nhảy đột ngột.
/// Đây là một giải pháp hữu hiệu để đảm bảo các trường nhập liệu không bị bàn phím che khuất mà không cần cấu hình thủ công cho từng màn hình.
class GlobalKeyboardWrapper extends StatefulWidget {
  const GlobalKeyboardWrapper({super.key, required this.child});
  final Widget child;
  @override
  State<GlobalKeyboardWrapper> createState() => _GlobalKeyboardWrapperState();
}

class _GlobalKeyboardWrapperState extends State<GlobalKeyboardWrapper> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: KeyboardService.instance.keyboardHeight,
      builder: (_, height, child) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(bottom: height),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
