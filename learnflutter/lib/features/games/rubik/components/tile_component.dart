import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../rubik_game.dart';

/// Component hiển thị từng ô vuông màu sắc riêng lẻ trong khối Rubik.
///
/// Lớp này kế thừa [RectangleComponent] để tận dụng khả năng vẽ hình chữ nhật có sẵn.
/// Nó nhận vào thông tin về màu sắc và xử lý việc hiển thị trực quan lên màn hình game.
/// Tile có khả năng cập nhật lại diện mạo của mình khi trạng thái màu trong bảng logic thay đổi.
class RubikTileComponent extends RectangleComponent with HasGameRef<RubikGame> {
  /// Màu sắc thực tế của ô vuông này.
  Color tileColor;

  /// Vị trí hàng/cột hiện tại của ô (không phải vị trí đích).
  int rowIndex;
  int colIndex;

  /// Tọa độ tâm của toàn bộ lưới Rubik để tính toán phối cảnh.
  Vector2? gridCenter;

  RubikTileComponent({
    required this.tileColor,
    required this.rowIndex,
    required this.colIndex,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          paint: Paint()..color = tileColor,
        );

  /// Cập nhật màu sắc hiển thị của ô vuông.
  void updateColor(Color newColor) {
    tileColor = newColor;
    paint.color = newColor;
  }

  /// Vẽ ô với hiệu ứng Perspective (chiều sâu).
  ///
  /// Khi ô ở gần trung tâm, nó hiển thị kích thước bình thường. Khi ở gần mép,
  /// nó sẽ bị "ép" nhẹ và mờ dần để mô phỏng việc xoay ra phía sau khối lập phương.
  @override
  void render(Canvas canvas) {
    if (gridCenter == null) {
      super.render(canvas);
      return;
    }

    // Tính khoảng cách từ tâm ô đến tâm lưới.
    final tileCenter = position + size / 2;
    final distanceFromCenter = (tileCenter - gridCenter!).length;
    final maxDistance = gridCenter!.x; // Giả định lưới vuông.

    // Tỉ lệ scale dựa trên khoảng cách ( Perspective effect).
    // Ô càng xa tâm càng nhỏ lại một chút.
    final scale = 1.0 - (distanceFromCenter / maxDistance) * 0.15;
    final opacity = 1.0 - (distanceFromCenter / maxDistance) * 0.3;

    canvas.save();
    // Di chuyển đến tâm ô để thực hiện phép biến đổi.
    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(scale);
    canvas.translate(-size.x / 2, -size.y / 2);

    final currentPaint = Paint()
      ..color = tileColor.withOpacity(opacity.clamp(0.1, 1.0))
      ..style = PaintingStyle.fill;

    canvas.drawRect(size.toRect(), currentPaint);

    // Vẽ viền 3D.
    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.4 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(size.toRect(), borderPaint);

    canvas.restore();
  }
}
