import 'package:flame/game.dart';
import 'logic/rubik_logic.dart';
import 'components/cube_grid_component.dart';

/// Lớp engine chính kế thừa FlameGame cho trò chơi Rubik 2D.
///
/// Lớp này điều phối toàn bộ tài nguyên của game, bao gồm logic tính toán,
/// các thành phần hiển thị trên canvas và các hiệu ứng âm thanh/hình ảnh.
/// Nó cũng đóng vai trò là "cầu nối" để các component con truy cập vào dữ liệu chung.
class RubikGame extends FlameGame {
  /// Instance logic chứa ma trận màu sắc và các quy tắc xoay.
  final RubikLogic logic = RubikLogic();

  /// Thành phần hiển thị lưới 3x3 ô màu.
  late RubikGridComponent grid;

  /// Key xác định overlay kết quả trong hệ thống overlays của Flame.
  static const String resultOverlayKey = 'rubikResult';

  /// Khởi tạo tài nguyên và thiết lập bảng game khi bắt đầu.
  ///
  /// Phương thức tính toán kích thước lưới (80% chiều rộng màn hình) và
  /// vị trí trung tâm để tạo trải nghiệm cân đối cho người dùng. Bảng được
  /// xáo trộn ngay khi tải xong để sẵn sàng cho nước đi đầu tiên.
  @override
  Future<void> onLoad() async {
    // Xáo trộn bảng màu trước khi hiển thị.
    logic.scramble();

    final gridSize = size.x * 0.8;
    grid = RubikGridComponent(
      position: Vector2((size.x - gridSize) / 2, (size.y - gridSize) / 2),
      size: Vector2.all(gridSize),
    );

    add(grid);
  }

  /// Xử lý hành động xoay hàng được kích hoạt từ tương tác người dùng.
  ///
  /// Phương thức gọi đến logic xử lý ma trận và yêu cầu lưới hiển thị
  /// cập nhật lại màu sắc của các ô dựa trên trạng thái mới. Đồng thời,
  /// nó thực hiện kiểm tra điều kiện thắng sau mỗi nước đi.
  void rotateRow(int index, bool right) {
    logic.rotateRow(index, right);
    grid.refresh();
    checkGameState();
  }

  void rotateColumn(int index, bool down) {
    logic.rotateColumn(index, down);
    grid.refresh();
    checkGameState();
  }

  /// Kiểm tra trạng thái ván đấu để quyết định kết thúc game.
  void checkGameState() {
    if (logic.checkWin()) {
      overlays.add(resultOverlayKey);
    }
  }

  /// Đặt lại toàn bộ trạng thái game về ban đầu để chơi ván mới.
  ///
  /// Phương thức ẩn các overlay đang hiện, xáo trộn lại bảng màu logic
  /// và yêu cầu component lưới cập nhật lại hiển thị trực quan cho người chơi.
  void reset() {
    overlays.remove(resultOverlayKey);
    logic.scramble();
    grid.refresh();
  }
}
