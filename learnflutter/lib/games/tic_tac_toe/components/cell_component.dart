import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../tic_tac_toe_game.dart';

/// Component đại diện cho một ô đơn lẻ trong bảng 3x3.
///
/// Class này kế thừa [RectangleComponent] để có sẵn hình chữ nhật làm vùng
/// tương tác, đồng thời mixin [TapCallbacks] để lắng nghe sự kiện chạm.
/// Mỗi ô lưu chỉ số hàng [row] và cột [col] để giao tiếp với game logic.
class CellComponent extends RectangleComponent with TapCallbacks {
  /// Chỉ số hàng của ô này trong ma trận (0, 1 hoặc 2).
  ///
  /// Giá trị được dùng để xác định vị trí khi gọi [TicTacToeGame.onCellTapped].
  final int row;

  /// Chỉ số cột của ô này trong ma trận (0, 1 hoặc 2).
  ///
  /// Kết hợp với [row] tạo thành tọa độ duy nhất của ô trong bảng.
  final int col;

  CellComponent({
    required this.row,
    required this.col,
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
          paint: Paint()..color = Colors.transparent,
        );

  /// Xử lý sự kiện chạm vào ô.
  ///
  /// Khi người dùng chạm vào vùng của ô này, phương thức tìm đến game cha
  /// thông qua [findGame] và gọi [TicTacToeGame.onCellTapped] với tọa độ
  /// của ô. Game sẽ chịu trách nhiệm kiểm tra tính hợp lệ và cập nhật trạng thái.
  @override
  void onTapDown(TapDownEvent event) {
    final game = findGame() as TicTacToeGame;
    game.onCellTapped(row, col);
  }
}
