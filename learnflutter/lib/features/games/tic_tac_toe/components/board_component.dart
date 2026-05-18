import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Component chịu trách nhiệm vẽ lưới bảng 3x3 của game Tic Tac Toe.
///
/// Class này kế thừa [Component] và mixin [HasGameRef] để có thể truy cập
/// thông tin về game đang chạy. Lưới được vẽ bằng cách render 4 đường thẳng
/// (2 dọc + 2 ngang) lên canvas mỗi frame.
class BoardComponent extends Component with HasGameRef {
  /// Tọa độ góc trên-trái của bảng trong không gian Flame.
  ///
  /// Điểm gốc này được tính toán từ [TicTacToeGame] sao cho bảng
  /// luôn nằm chính giữa màn hình theo cả chiều ngang lẫn chiều dọc.
  final Vector2 boardPosition;

  /// Kích thước cạnh của bảng hình vuông (tính bằng pixel logic).
  ///
  /// Giá trị này bằng 85% chiều rộng màn hình, đảm bảo bảng đủ lớn
  /// để tương tác nhưng vẫn có khoảng đệm hai bên.
  final double boardSize;

  BoardComponent({required this.boardPosition, required this.boardSize});

  /// Vẽ lưới bảng lên canvas mỗi frame.
  ///
  /// Phương thức tính kích thước mỗi ô bằng cách chia [boardSize] cho 3.
  /// Sau đó vẽ 2 đường dọc tại vị trí 1/3 và 2/3 chiều ngang, và 2 đường
  /// ngang tại vị trí 1/3 và 2/3 chiều dọc. Tất cả đường kẻ có màu trắng
  /// mờ với độ dày 4 pixel và đầu bo tròn để tạo cảm giác mềm mại.
  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cellSize = boardSize / 3;

    // Vẽ 2 đường kẻ dọc phân chia bảng thành 3 cột.
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(boardPosition.x + cellSize * i, boardPosition.y),
        Offset(boardPosition.x + cellSize * i, boardPosition.y + boardSize),
        paint,
      );
    }

    // Vẽ 2 đường kẻ ngang phân chia bảng thành 3 hàng.
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(boardPosition.x, boardPosition.y + cellSize * i),
        Offset(boardPosition.x + boardSize, boardPosition.y + cellSize * i),
        paint,
      );
    }
  }
}
