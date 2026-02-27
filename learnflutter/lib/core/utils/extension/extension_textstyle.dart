import 'package:flutter/material.dart';

/// Extension cho TextStyle cung cấp các phương thức tạo hiệu ứng gạch chân, gạch trên và gạch ngang cho text.
/// Các phương thức này sử dụng Shadow và TextDecoration để tạo ra các kiểu trang trí text đa dạng với khoảng cách, độ dày và kiểu nét có thể tùy chỉnh.
extension ExtensionTextStyle on TextStyle {
  /// Tạo hiệu ứng gạch chân (underline) cho text với khoảng cách, màu sắc, độ dày và kiểu nét tùy chỉnh.
  /// Sử dụng Shadow để tạo khoảng cách giữa text và đường gạch chân.
  TextStyle underlined({
    Color? color,
    double distance = 1,
    double thickness = 1,
    TextDecorationStyle style = TextDecorationStyle.dashed,
  }) {
    return copyWith(
      shadows: [
        Shadow(
          color: this.color ?? Colors.black,
          offset: Offset(0, -distance),
        )
      ],
      color: Colors.transparent,
      decoration: TextDecoration.underline,
      decorationThickness: thickness,
      decorationColor: color ?? this.color,
      decorationStyle: style,
    );
  }

  /// Tạo hiệu ứng gạch trên (overline) cho text với khoảng cách, màu sắc, độ dày và kiểu nét tùy chỉnh.
  /// Đường gạch sẽ xuất hiện phía trên text.
  TextStyle toplined({
    Color? color,
    double distance = 1,
    double thickness = 1,
    TextDecorationStyle style = TextDecorationStyle.solid,
  }) {
    return copyWith(
      shadows: [
        Shadow(
          color: this.color ?? Colors.black,
          offset: Offset(0, -distance),
          blurRadius: 0,
        )
      ],
      color: Colors.transparent,
      decoration: TextDecoration.overline,
      decorationThickness: thickness,
      decorationColor: color ?? this.color,
      decorationStyle: style,
    );
  }

  /// Tạo hiệu ứng gạch ngang (line-through) cho text với khoảng cách, màu sắc, độ dày và kiểu nét tùy chỉnh.
  /// Đường gạch sẽ đi qua giữa text, thường dùng để biểu thị nội dung đã xóa hoặc không còn hiệu lực.
  TextStyle centerlined({
    Color? color,
    double distance = 1,
    double thickness = 1,
    TextDecorationStyle style = TextDecorationStyle.solid,
  }) {
    return copyWith(
      shadows: [
        Shadow(
          color: this.color ?? Colors.black,
          offset: Offset(0, -distance),
          blurRadius: 0,
        )
      ],
      color: Colors.transparent,
      decoration: TextDecoration.lineThrough,
      decorationThickness: thickness,
      decorationColor: color ?? this.color,
      decorationStyle: style,
    );
  }
}
