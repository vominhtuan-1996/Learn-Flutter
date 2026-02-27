import 'package:flutter/material.dart';

/// BalanceBar là một widget hiển thị thanh số dư tài chính trong ứng dụng.
/// Nó được thiết kế để tích hợp mượt mà vào SliverAppBar hoặc các khu vực hiển thị trạng thái tài khoản.
/// Widget hỗ trợ tùy chỉnh định dạng, căn lề và đệm nội dung để phù hợp với nhiều ngữ cảnh sử dụng khác nhau.
class BalanceBar extends StatelessWidget {
  const BalanceBar(
      {super.key, this.decoration, this.contentAlignment, this.contentPadding});

  /// Cấu hình trang trí nền cho thanh số dư (màu sắc, viền, bóng đổ).
  final Decoration? decoration;

  /// Xác định vị trí căn chỉnh của nội dung bên trong thanh số dư.
  final AlignmentGeometry? contentAlignment;

  /// Khoảng cách đệm nội bộ cho các thành phần hiển thị số dư.
  final EdgeInsetsGeometry? contentPadding;

  /// Chiều cao cố định của thanh số dư để đảm bảo tính nhất quán trong bố cục Sliver.
  static const double height = 60;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: contentAlignment,
      padding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 8),
      decoration: decoration,
      child: const Text('data'),
      // TODO: Implement actual balance display logic here
    );
  }
}
