import 'package:flutter/material.dart';
import 'package:learnflutter/core/theme/extension_theme.dart';
import 'package:learnflutter/features/setting/state/setting_state.dart';

/// Lớp AppThemes chịu trách nhiệm cung cấp cấu hình giao diện (ThemeData) tập trung cho toàn bộ ứng dụng.
/// Nó đóng vai trò là điểm truy cập duy nhất để lấy thông tin về chủ đề, bao gồm màu sắc, phông chữ và các thành phần giao diện khác.
/// Lớp này đảm bảo rằng ứng dụng luôn có một vẻ ngoài nhất quán và tuân thủ các hướng dẫn về thiết kế đã đề ra.
/// Bằng cách tách biệt logic giao diện vào đây, chúng tôi có thể dễ dàng quản lý và cập nhật nhiều chủ đề khác nhau một cách linh hoạt.
class AppThemes {
  /// Phương thức primaryTheme tạo ra đối tượng ThemeData dựa trên trạng thái hiện tại của ứng dụng.
  /// Nó lấy các thông tin từ SettingThemeState để quyết định việc áp dụng các thuộc tính giao diện phù hợp như chế độ sáng hoặc tối.
  /// Dữ liệu này sau đó được chuyển đổi trực tiếp từ các token thiết kế sang cấu hình chuẩn mà Flutter có thể hiểu và hiển thị.
  /// Đây là hàm trung tâm giúp đồng bộ hóa các tùy chỉnh của người dùng với giao diện thực tế của ứng dụng.
  static ThemeData primaryTheme(
    BuildContext context,
    SettingThemeState state,
  ) {
    return state.tokens.toThemeData();
  }
}
