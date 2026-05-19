import 'package:flutter/material.dart';

/// Một nút icon tròn tái sử dụng có nền mờ đen đặc trưng của giao diện camera,
/// giúp tăng khả năng hiển thị rõ nét trên bất kỳ nền preview camera sáng/tối nào.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 22,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
