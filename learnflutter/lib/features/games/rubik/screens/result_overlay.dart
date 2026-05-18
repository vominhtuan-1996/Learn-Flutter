import 'package:flutter/material.dart';
import '../rubik_game.dart';
import '../logic/rubik_logic.dart';

/// Overlay hiển thị màn thông báo chúc mừng khi giải xong khối Rubik.
///
/// Widget này xuất hiện dưới dạng một lớp phủ trên màn hình game khi [RubikLogic.checkWin] trả về true.
/// Nó hiển thị thông tin về người thắng dựa trên ai là người thực hiện nước đi cuối cùng dẫn đến kết quả.
class RubikResultOverlay extends StatelessWidget {
  /// Instance của game để truy cập logic và các lệnh điều khiển.
  final RubikGame game;

  const RubikResultOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Lưu ý: Player chuyển ĐÚNG sau nước xoay, nên người thắng là Player vừa ĐỔI sang.
    // Thực tế có thể cần lưu winner cụ thể trong logic, tạm thời hiển thị chúc mừng chung.
    final winner = game.logic.currentPlayer == RubikPlayer.playerA
        ? "Người chơi B"
        : "Người chơi A";

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey[900]?.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
            const SizedBox(height: 16),
            const Text(
              'CHIẾN THẮNG!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$winner đã giải xong Rubik!',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                game.reset();
              },
              child: const Text('Chơi ván mới',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
