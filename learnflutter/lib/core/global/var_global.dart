import 'package:flutter/material.dart';

/// Biến textScale lưu trữ tỷ lệ phóng đại của phông chữ trên toàn bộ ứng dụng để hỗ trợ khả năng truy cập tốt hơn.
/// Nó được tính toán động dựa trên kích thước màn hình thiết bị thực tế so với kích thước thiết kế gốc trong Figma.
/// Việc duy trì biến này giúp các thành phần giao diện chứa văn bản có thể tự điều chỉnh kích thước một cách mượt mà và đồng bộ.
double textScale = 1.0;

/// Biến themeBackgoundGlobal nắm giữ màu nền chủ đạo đang được áp dụng cho toàn bộ phạm vi ứng dụng.
/// Nó cho phép hệ thống dễ dàng truy xuất và đồng bộ màu sắc nền của các trang (Scaffold) mà không cần cấu hình lặp lại.
/// Tham số này có thể thay đổi linh hoạt khi người dùng thực hiện chuyển đổi giữa các chế độ giao diện sáng hoặc tối.
Color? themeBackgoundGlobal;
