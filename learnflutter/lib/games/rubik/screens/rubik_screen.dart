import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../rubik_game.dart';
import '../logic/rubik_logic.dart';
import 'result_overlay.dart';

/// Màn hình Flutter chính tích hợp game Rubik chạy bằng Flame engine.
///
/// Lớp này cung cấp giao diện bổ trợ bao gồm tiêu đề, thông tin lượt chơi và các nút
/// điều khiển nhanh (như xoay hàng/cột thủ công) bên cạnh vùng hiển thị game chính.
/// Nó sử dụng [GameWidget] của Flame để nhúng engine vào cây widget của Flutter.
class RubikScreen extends StatefulWidget {
  const RubikScreen({super.key});

  @override
  State<RubikScreen> createState() => _RubikScreenState();
}

class _RubikScreenState extends State<RubikScreen> {
  /// Instance duy nhất của game Rubik được khởi tạo khi vào màn hình.
  late final RubikGame _game;

  @override
  void initState() {
    super.initState();
    _game = RubikGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Rubik 2D Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTurnIndicator(),
          Expanded(
            child: GameWidget(
              game: _game,
              overlayBuilderMap: {
                RubikGame.resultOverlayKey: (context, game) =>
                    RubikResultOverlay(game: game as RubikGame),
              },
            ),
          ),
          _buildManualControls(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Xây dựng thanh hiển thị người chơi hiện tại đang thực hiện lượt.
  ///
  /// Sử dụng [StreamBuilder] kết hợp với [Stream.periodic] để theo dõi
  /// và cập nhật trạng thái người chơi từ engine Flame một cách liên tục.
  Widget _buildTurnIndicator() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 200)),
      builder: (context, snapshot) {
        final player = _game.logic.currentPlayer;
        final isA = player == RubikPlayer.playerA;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Lượt của: ',
                  style: TextStyle(color: Colors.white70, fontSize: 18)),
              Text(
                isA ? 'Người chơi A' : 'Người chơi B',
                style: TextStyle(
                  color: isA ? Colors.redAccent : Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Cung cấp các nút bấm điều khiển xoay hàng/cột nhanh.
  ///
  /// Mặc dù game hỗ trợ thao tác vuốt trực tiếp, các nút này giúp người chơi
  /// làm quen với cơ chế xoay trượt hàng/cột chính xác và hỗ trợ gỡ lỗi nhanh.
  Widget _buildManualControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Text('Điều khiển nhanh:',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _game.rotateRow(0, true)),
                child: const Text('Hàng 1 →'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _game.rotateColumn(0, true)),
                child: const Text('Cột 1 ↓'),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                onPressed: () => setState(() => _game.reset()),
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
