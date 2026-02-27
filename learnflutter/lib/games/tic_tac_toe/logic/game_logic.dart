/// Định nghĩa hai người chơi trong game Tic Tac Toe.
///
/// Enum này được dùng để nhận diện người chơi X và O trong toàn bộ module.
/// Giá trị [x] đại diện cho người chơi đầu tiên, [o] đại diện cho người chơi thứ hai.
enum Player { x, o }

/// Class chứa toàn bộ logic thuần Dart cho game Tic Tac Toe.
///
/// Class này không phụ thuộc vào Flame hay Flutter, giúp dễ dàng viết unit test
/// độc lập mà không cần khởi tạo môi trường giao diện. Nó quản lý trạng thái
/// bảng, người chơi hiện tại và kiểm tra các điều kiện kết thúc game.
class GameLogic {
  /// Ma trận 3x3 lưu trạng thái từng ô trên bảng.
  ///
  /// Mỗi phần tử có thể là [Player.x], [Player.o], hoặc [null] nếu ô còn trống.
  /// Board được khởi tạo với toàn bộ giá trị null (bảng trống) khi bắt đầu game.
  final List<List<Player?>> board =
      List.generate(3, (_) => List.filled(3, null));

  /// Người chơi đang đến lượt thực hiện nước đi.
  ///
  /// Mặc định là [Player.x] vì người chơi X luôn đi trước theo luật chuẩn.
  /// Giá trị này tự động chuyển đổi sau mỗi nước đi hợp lệ.
  Player currentPlayer = Player.x;

  /// Trả về người chơi đang thắng, hoặc [null] nếu chưa có kết quả.
  ///
  /// Getter này kiểm tra tất cả 8 tổ hợp thắng bao gồm 3 hàng ngang,
  /// 3 cột dọc và 2 đường chéo. Kết quả được tính toán lại mỗi lần truy xuất.
  Player? get winner => _checkWinner();

  /// Kiểm tra xem ván đấu có kết thúc với kết quả hoà hay không.
  ///
  /// Hoà xảy ra khi tất cả 9 ô đã được đánh nhưng không có người chơi nào
  /// tạo được tổ hợp thắng. Điều kiện này chỉ đúng khi [winner] trả về null.
  bool get isDraw =>
      winner == null && board.every((row) => row.every((cell) => cell != null));

  /// Thực hiện nước đi của người chơi tại vị trí hàng [row] và cột [col].
  ///
  /// Phương thức trả về [true] nếu nước đi hợp lệ và được ghi nhận thành công.
  /// Trả về [false] nếu ô đã có người đánh hoặc game đã kết thúc.
  /// Sau mỗi nước đi hợp lệ, nếu game chưa kết thúc, lượt chơi sẽ chuyển sang
  /// người chơi còn lại.
  bool makeMove(int row, int col) {
    if (board[row][col] != null || winner != null || isDraw) return false;

    board[row][col] = currentPlayer;

    // Chỉ đổi lượt nếu game chưa kết thúc sau nước đi này.
    if (winner == null && !isDraw) {
      currentPlayer = currentPlayer == Player.x ? Player.o : Player.x;
    }

    return true;
  }

  /// Đặt lại game về trạng thái ban đầu.
  ///
  /// Phương thức xoá tất cả các nước đi trên bảng và đặt lại người chơi
  /// hiện tại về [Player.x]. Sau khi gọi reset, game có thể bắt đầu lại từ đầu.
  void reset() {
    for (final row in board) {
      row.fillRange(0, 3, null);
    }
    currentPlayer = Player.x;
  }

  /// Kiểm tra nội bộ xem có người chơi nào thắng chưa.
  ///
  /// Phương thức lần lượt kiểm tra 3 hàng ngang, 3 cột dọc và 2 đường chéo.
  /// Nếu tìm thấy một dãy 3 ô liên tiếp của cùng một người chơi, trả về
  /// người chơi đó. Ngược lại trả về [null].
  Player? _checkWinner() {
    for (int i = 0; i < 3; i++) {
      // Kiểm tra hàng ngang thứ i.
      if (_allSame(board[i][0], board[i][1], board[i][2])) return board[i][0];

      // Kiểm tra cột dọc thứ i.
      if (_allSame(board[0][i], board[1][i], board[2][i])) return board[0][i];
    }

    // Kiểm tra đường chéo từ trái trên xuống phải dưới.
    if (_allSame(board[0][0], board[1][1], board[2][2])) return board[0][0];

    // Kiểm tra đường chéo từ phải trên xuống trái dưới.
    if (_allSame(board[0][2], board[1][1], board[2][0])) return board[0][2];

    return null;
  }

  /// Kiểm tra xem ba ô có cùng thuộc về một người chơi không.
  ///
  /// Điều kiện hợp lệ yêu cầu [a] không được là [null] và ba giá trị
  /// [a], [b], [c] phải bằng nhau. Điều này đảm bảo không xét các ô trống
  /// là điều kiện thắng.
  bool _allSame(Player? a, Player? b, Player? c) =>
      a != null && a == b && b == c;
}
