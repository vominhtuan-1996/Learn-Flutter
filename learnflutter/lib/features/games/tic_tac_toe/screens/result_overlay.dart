import 'package:flutter/material.dart';
import '../logic/game_logic.dart';
import '../tic_tac_toe_game.dart';

/// Overlay hiển thị kết quả khi ván đấu kết thúc.
///
/// Widget này được đăng ký trong [GameWidget.overlayBuilderMap] với key
/// [TicTacToeGame.resultOverlayKey]. Nó xuất hiện phía trên game canvas để
/// thông báo ai thắng hoặc thông báo kết quả hoà, và cung cấp nút chơi lại.
class ResultOverlay extends StatelessWidget {
  /// Instance của game để đọc kết quả từ [TicTacToeGame.logic].
  final TicTacToeGame game;

  /// Callback được gọi khi người dùng nhấn nút "Chơi lại".
  ///
  /// [GameScreen] sẽ truyền vào closure gọi [TicTacToeGame.resetGame]
  /// và [setState] để cập nhật lại header hiển thị lượt chơi.
  final VoidCallback onRestart;

  const ResultOverlay({
    super.key,
    required this.game,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final winner = game.logic.winner;

    // Xác định thông điệp hiển thị dựa trên kết quả: thắng hoặc hoà.
    final String message =
        winner != null ? '${winner.name.toUpperCase()} Thắng! 🎉' : 'Hoà! 🤝';

    final Color accentColor = winner == Player.x
        ? const Color(0xFFE53935)
        : winner == Player.o
            ? const Color(0xFF1E88E5)
            : Colors.white70;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white24, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hiển thị thông báo kết quả với màu sắc tương ứng người thắng.
            Text(
              message,
              style: TextStyle(
                color: accentColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // Nút "Chơi lại" để reset game và bắt đầu ván mới.
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F3460),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              onPressed: onRestart,
              child: const Text(
                'Chơi lại',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
