import 'package:flutter/material.dart';

/// Định nghĩa các người chơi tham gia vào lượt giải Rubik.
///
/// Trò chơi hỗ trợ hai đối thủ thực hiện các nước đi luân phiên nhau.
/// [playerA] và [playerB] sẽ thay đổi sau mỗi thao tác xoay hàng hoặc cột hợp lệ.
enum RubikPlayer { playerA, playerB }

/// Class quản lý trạng thái và logic điều khiển của bảng Rubik 2D.
///
/// Lớp này chịu trách nhiệm lưu trữ ma trận màu sắc, xử lý việc xoay các hàng/cột
/// theo cơ chế wrap-around, chuyển đổi lượt chơi và kiểm tra điều kiện kết thúc game.
/// Nó được thiết kế tách biệt hoàn toàn với lớp hiển thị để dễ dàng kiểm thử logic.
class RubikLogic {
  /// Ma trận 3x3 lưu giữ chỉ số màu sắc của từng ô trên bảng.
  ///
  /// Mỗi giá trị trong danh sách con đại diện cho một loại màu sắc cụ thể.
  /// Bảng được khởi tạo dưới dạng một danh sách hai chiều cố định kích thước 3x3.
  late List<List<int>> board;

  /// Danh sách các màu sắc cơ bản được sử dụng trong game Rubik.
  ///
  /// Bao gồm 6 màu chuẩn: Đỏ, Xanh lá, Xanh dương, Vàng, Cam và Trắng.
  /// Các chỉ số trong [board] sẽ tương ứng với chỉ số trong danh sách này.
  final List<Color> palette = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.white,
  ];

  /// Người chơi đang nắm quyền điều khiển ở lượt hiện tại.
  ///
  /// Mặc định [RubikPlayer.playerA] sẽ bắt đầu cuộc chơi trước.
  /// Trạng thái này sẽ tự động đảo ngược sau khi một hành động xoay hoàn tất.
  RubikPlayer currentPlayer = RubikPlayer.playerA;

  RubikLogic() {
    _initBoard();
  }

  /// Khởi tạo trạng thái ban đầu của bảng Rubik.
  ///
  /// Bảng bắt đầu với các khối màu đồng nhất (mỗi hàng/cột một màu)
  /// để người chơi có thể thấy rõ trạng thái "đã giải" trước khi xáo trộn.
  void _initBoard() {
    board = [
      [0, 1, 2],
      [0, 1, 2],
      [0, 1, 2],
    ];
  }

  /// Xáo trộn bảng màu một cách ngẫu nhiên để bắt đầu ván mới.
  ///
  /// Quá trình xáo trộn sẽ thực hiện một số lượng lớn các nước đi xoay hàng và cột
  /// ngẫu nhiên, đảm bảo khối Rubik nằm ở trạng thái phức tạp nhưng vẫn có thể giải được.
  void scramble() {
    // Thực hiện 20 nước đi ngẫu nhiên để xáo trộn bảng.
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 20; i++) {
      final isRow = (i + random) % 2 == 0;
      final index = (i * 7 + random) % 3;
      final direction = (i * 13 + random) % 2 == 0;

      if (isRow) {
        // Gọi trực tiếp để tránh chuyển Player liên tục trong lúc xáo trộn.
        _rotateRowInternal(index, direction);
      } else {
        _rotateColumnInternal(index, direction);
      }
    }
    currentPlayer = RubikPlayer.playerA;
  }

  void rotateRow(int rowIndex, bool isRight) {
    _rotateRowInternal(rowIndex, isRight);
    _switchPlayer();
  }

  void _rotateRowInternal(int rowIndex, bool isRight) {
    if (rowIndex < 0 || rowIndex >= 3) return;
    final row = board[rowIndex];
    if (isRight) {
      final last = row.removeLast();
      row.insert(0, last);
    } else {
      final first = row.removeAt(0);
      row.add(first);
    }
  }

  void rotateColumn(int colIndex, bool isDown) {
    _rotateColumnInternal(colIndex, isDown);
    _switchPlayer();
  }

  void _rotateColumnInternal(int colIndex, bool isDown) {
    if (colIndex < 0 || colIndex >= 3) return;

    final temp = [board[0][colIndex], board[1][colIndex], board[2][colIndex]];
    if (isDown) {
      board[0][colIndex] = temp[2];
      board[1][colIndex] = temp[0];
      board[2][colIndex] = temp[1];
    } else {
      board[0][colIndex] = temp[1];
      board[1][colIndex] = temp[2];
      board[2][colIndex] = temp[0];
    }
  }

  /// Chuyển đổi quyền điều khiển giữa hai người chơi.
  ///
  /// Hàm này đảm bảo tính công bằng bằng cách bắt buộc thay đổi người chơi
  /// ngay sau khi một thao tác xoay hợp lệ được thực hiện trên bảng.
  void _switchPlayer() {
    currentPlayer = currentPlayer == RubikPlayer.playerA
        ? RubikPlayer.playerB
        : RubikPlayer.playerA;
  }

  /// Kiểm tra xem toàn bộ bảng đã đạt trạng thái giải xong hay chưa.
  ///
  /// Một bảng được coi là đã giải khi tất cả các ô trên cùng một hàng
  /// hoặc toàn bộ bảng có cấu trúc màu sắc đồng nhất theo mẫu mục tiêu.
  /// Trong phiên bản này, ta kiểm tra xem mỗi hàng có đồng màu hay không.
  bool checkWin() {
    // Kiểm tra thắng theo hàng ngang.
    bool rowsWin = true;
    for (int i = 0; i < 3; i++) {
      final first = board[i][0];
      if (board[i][1] != first || board[i][2] != first) {
        rowsWin = false;
        break;
      }
    }
    if (rowsWin) return true;

    // Kiểm tra thắng theo cột dọc.
    bool colsWin = true;
    for (int j = 0; j < 3; j++) {
      final first = board[0][j];
      if (board[1][j] != first || board[2][j] != first) {
        colsWin = false;
        break;
      }
    }
    return colsWin;
  }

  /// Trả về màu sắc Flutter tương ứng với chỉ số được lưu trong bảng.
  ///
  /// Phương thức này giúp ánh xạ dữ liệu logic (số nguyên) sang dữ liệu hiển thị (Color).
  /// Nếu chỉ số nằm ngoài phạm vi palette, màu xám mặc định sẽ được trả về.
  Color getColor(int index) {
    if (index >= 0 && index < palette.length) {
      return palette[index];
    }
    return Colors.grey;
  }
}
