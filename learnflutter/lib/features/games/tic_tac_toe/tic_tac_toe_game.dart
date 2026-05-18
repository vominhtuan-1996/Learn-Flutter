import 'package:flame/game.dart';
import 'components/board_component.dart';
import 'components/cell_component.dart';
import 'components/mark_component.dart';
import 'logic/game_logic.dart';

/// Lớp game Flame chính điều phối toàn bộ module Tic Tac Toe.
///
/// [TicTacToeGame] kế thừa [FlameGame] để tích hợp vào vòng lặp game của Flame.
/// Lớp này đóng vai trò trung tâm: khởi tạo bảng, quản lý các component,
/// xử lý input từ người dùng và quyết định khi nào game kết thúc.
class TicTacToeGame extends FlameGame {
  /// Instance logic game thuần Dart.
  ///
  /// [GameLogic] được truy cập từ bên ngoài (ví dụ từ [GameScreen]) để đọc
  /// trạng thái hiện tại như [GameLogic.currentPlayer], [GameLogic.winner].
  final GameLogic logic = GameLogic();

  /// Kích thước cạnh của bảng hình vuông (tính bằng pixel logic Flame).
  late double _boardSize;

  /// Tọa độ góc trên-trái của bảng, căn giữa màn hình.
  late Vector2 _boardOrigin;

  /// Kích thước mỗi ô trong lưới 3x3, bằng 1/3 [_boardSize].
  late double _cellSize;

  /// Tên key dùng để quản lý overlay kết quả trong [GameWidget.overlayBuilderMap].
  static const String resultOverlayKey = 'result';

  /// Khởi tạo toàn bộ component khi game được tải lần đầu.
  ///
  /// Phương thức tính toán kích thước và vị trí của bảng sao cho luôn căn giữa
  /// màn hình. Sau đó thêm [BoardComponent] để vẽ lưới, và 9 [CellComponent]
  /// tương ứng với từng vị trí trong ma trận 3x3.
  @override
  Future<void> onLoad() async {
    _boardSize = size.x * 0.85;
    _boardOrigin = Vector2(
      (size.x - _boardSize) / 2,
      (size.y - _boardSize) / 2,
    );
    _cellSize = _boardSize / 3;

    // Thêm component vẽ lưới bảng 3x3.
    add(BoardComponent(boardPosition: _boardOrigin, boardSize: _boardSize));

    // Thêm 9 ô tương tác, lần lượt từ hàng trên xuống hàng dưới.
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        add(CellComponent(
          row: row,
          col: col,
          position: Vector2(
            _boardOrigin.x + col * _cellSize,
            _boardOrigin.y + row * _cellSize,
          ),
          size: Vector2.all(_cellSize),
        ));
      }
    }
  }

  /// Xử lý sự kiện khi người dùng chạm vào ô tại [row], [col].
  ///
  /// Phương thức yêu cầu [GameLogic] thực hiện nước đi. Nếu nước đi không hợp lệ
  /// (ô đã có người đánh hoặc game kết thúc), phương thức kết thúc sớm. Nếu hợp lệ,
  /// một [MarkComponent] sẽ được thêm vào màn hình tại vị trí tương ứng. Sau đó
  /// kiểm tra ngay nếu có người thắng hoặc hoà để hiện overlay thông báo kết quả.
  void onCellTapped(int row, int col) {
    if (!logic.makeMove(row, col)) return;

    // Tính vị trí và kích thước của dấu X/O, có padding 10% mỗi phía.
    final padding = _cellSize * 0.1;
    add(MarkComponent(
      player: logic.board[row][col]!,
      position: Vector2(
        _boardOrigin.x + col * _cellSize + padding,
        _boardOrigin.y + row * _cellSize + padding,
      ),
      size: Vector2.all(_cellSize - padding * 2),
    ));

    // Hiện overlay kết quả nếu game đã kết thúc (thắng hoặc hoà).
    if (logic.winner != null || logic.isDraw) {
      overlays.add(resultOverlayKey);
    }
  }

  /// Đặt lại game về trạng thái ban đầu.
  ///
  /// Phương thức ẩn overlay kết quả, gọi [GameLogic.reset] để xoá board,
  /// và xoá tất cả [MarkComponent] đang hiển thị trên màn hình. Sau khi
  /// gọi xong, bảng trống hoàn toàn và sẵn sàng cho ván đấu mới.
  void resetGame() {
    overlays.remove(resultOverlayKey);
    logic.reset();
    removeWhere((component) => component is MarkComponent);
  }
}
