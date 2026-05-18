import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../logic/game_logic.dart';
import '../tic_tac_toe_game.dart';
import 'result_overlay.dart';

/// Màn hình Flutter chính bọc game Flame Tic Tac Toe.
///
/// [GameScreen] là điểm tiếp xúc giữa Flutter widget tree và Flame engine.
/// Nó khởi tạo [TicTacToeGame], hiển thị header thông báo lượt chơi hiện tại
/// và nhúng [GameWidget] vào layout. Overlay kết quả cũng được đăng ký tại đây.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  /// Instance của FlameGame được khởi tạo một lần và tái sử dụng xuyên suốt vòng đời widget.
  ///
  /// Khởi tạo trong [initState] thay vì trực tiếp trong [build] để đảm bảo
  /// game không bị tạo lại mỗi khi widget rebuild.
  late final TicTacToeGame _game;

  @override
  void initState() {
    super.initState();
    _game = TicTacToeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Header hiển thị lượt chơi hiện tại, cập nhật định kỳ.
            _buildTurnHeader(),
            Expanded(
              child: GameWidget(
                game: _game,
                overlayBuilderMap: {
                  // Đăng ký overlay kết quả và truyền callback reset cho nó.
                  TicTacToeGame.resultOverlayKey: (context, game) =>
                      ResultOverlay(
                        game: game as TicTacToeGame,
                        onRestart: () => setState(() => _game.resetGame()),
                      ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng header hiển thị người chơi đang đến lượt.
  ///
  /// Sử dụng [Stream.periodic] với chu kỳ 100ms để cập nhật định kỳ giá trị
  /// [GameLogic.currentPlayer] từ game engine vào Flutter widget tree.
  /// Đây là cách đơn giản nhất để đồng bộ state giữa Flame và Flutter
  /// mà không cần dùng StateNotifier hay stream phức tạp hơn.
  Widget _buildTurnHeader() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, _) {
        final player = _game.logic.currentPlayer;
        final isX = player == Player.x;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isX
                    ? const Color(0xFFE53935).withValues(alpha: 0.4)
                    : const Color(0xFF1E88E5).withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lượt của: ',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                player.name.toUpperCase(),
                style: TextStyle(
                  color:
                      isX ? const Color(0xFFE53935) : const Color(0xFF1E88E5),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
