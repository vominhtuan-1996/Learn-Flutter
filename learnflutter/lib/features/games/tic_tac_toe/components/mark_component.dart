import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../logic/game_logic.dart';

/// Component hiển thị dấu X hoặc O tại một ô trên bảng.
///
/// Class này kế thừa [CustomPainterComponent] để tận dụng khả năng vẽ tùy chỉnh
/// của Flutter thông qua [Canvas]. Mỗi instance đại diện cho một nước đi đã được
/// thực hiện và sẽ tồn tại trên bảng cho đến khi game được reset.
class MarkComponent extends CustomPainterComponent {
  /// Người chơi đã thực hiện nước đi này.
  ///
  /// Giá trị [Player.x] sẽ hiển thị dấu X màu đỏ, [Player.o] hiển thị
  /// dấu O màu xanh dương để phân biệt rõ ràng giữa hai người chơi.
  final Player player;

  MarkComponent({
    required this.player,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          painter: _MarkPainter(player),
          position: position,
          size: size,
        );
}

/// Painter nội bộ thực hiện vẽ dấu X hoặc O lên canvas.
///
/// Class này không public vì chỉ được sử dụng bởi [MarkComponent].
/// Nó triển khai [CustomPainter] để cung cấp logic vẽ cụ thể cho mỗi loại dấu.
class _MarkPainter extends CustomPainter {
  final Player player;

  _MarkPainter(this.player);

  /// Vẽ dấu X hoặc O lên canvas theo kích thước [size].
  ///
  /// Tất cả dấu đều có padding bằng 20% kích thước ô để không chạm viền lưới.
  /// Dấu X được vẽ bằng hai đường chéo màu đỏ (#E53935), trong khi dấu O là
  /// một hình tròn rỗng màu xanh dương (#1E88E5). Cả hai dùng strokeWidth = 8
  /// và StrokeCap.round để tạo nét bút mềm mại.
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = player == Player.x
          ? const Color(0xFFE53935)
          : const Color(0xFF1E88E5);

    final padding = size.width * 0.2;

    if (player == Player.x) {
      // Vẽ đường chéo từ góc trên-trái xuống góc dưới-phải.
      canvas.drawLine(
        Offset(padding, padding),
        Offset(size.width - padding, size.height - padding),
        paint,
      );

      // Vẽ đường chéo từ góc trên-phải xuống góc dưới-trái.
      canvas.drawLine(
        Offset(size.width - padding, padding),
        Offset(padding, size.height - padding),
        paint,
      );
    } else {
      // Vẽ hình tròn rỗng căn giữa ô, bán kính = nửa chiều rộng trừ padding.
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2 - padding,
        paint,
      );
    }
  }

  /// Trả về [false] vì nội dung không thay đổi sau khi được vẽ lần đầu.
  ///
  /// Mỗi [MarkComponent] chỉ đại diện cho một nước đi cố định, vì vậy
  /// không cần vẽ lại khi widget thay đổi.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
