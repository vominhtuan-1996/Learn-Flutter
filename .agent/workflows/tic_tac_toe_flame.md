---
description: Quy trình xây dựng game Tic Tac Toe 2 người chơi luân phiên với Flame engine, bao gồm màn hình game, logic thắng/thua và reset game
---

# Tic Tac Toe (Flame) Workflow

Hướng dẫn xây dựng game **Tic Tac Toe** 2 người chơi dùng **Flame** (Flutter game engine).

---

## 1. Cài đặt

Thêm vào `pubspec.yaml`:
```yaml
dependencies:
  flame: ^1.18.0
```

---

## 2. Cấu trúc thư mục

```text
lib/games/tic_tac_toe/
├── tic_tac_toe_game.dart        # FlameGame chính
├── components/
│   ├── board_component.dart     # Vẽ lưới 3x3
│   ├── cell_component.dart      # Ô tap được
│   └── mark_component.dart      # Vẽ X / O
├── logic/
│   └── game_logic.dart          # Logic lượt chơi & điều kiện thắng
└── screens/
    ├── game_screen.dart         # Widget Flutter bọc FlameGame
    └── result_overlay.dart      # Overlay kết quả
```

---

## 3. Các bước triển khai

### Bước 1 — `logic/game_logic.dart` (Pure Dart)

- Dùng `enum Player { x, o }`.
- `List<List<Player?>> board` — ma trận 3x3, null = ô trống.
- `Player currentPlayer` — X đi trước, tự đổi sau mỗi nước hợp lệ.
- `bool makeMove(int row, int col)` — trả `false` nếu ô đã có người đánh hoặc game kết thúc.
- `Player? get winner` — kiểm tra 3 hàng, 3 cột, 2 đường chéo.
- `bool get isDraw` — tất cả ô đầy mà không có người thắng.
- `void reset()` — xoá board, đặt lại lượt.

> [!NOTE]
> `GameLogic` không phụ thuộc Flame → dễ unit test độc lập.

---

### Bước 2 — `components/cell_component.dart`

- Kế thừa `RectangleComponent` + mixin `TapCallbacks`.
- Lưu `int row, col`.
- `onTapDown` → gọi `(findGame() as TicTacToeGame).onCellTapped(row, col)`.
- `paint` nền trong suốt (opacity thấp) để không che lưới.

---

### Bước 3 — `components/mark_component.dart`

- Kế thừa `CustomPainterComponent`.
- Nhận `Player player`.
- **X**: vẽ 2 đường chéo màu đỏ (`Color(0xFFE53935)`).
- **O**: vẽ hình tròn màu xanh (`Color(0xFF1E88E5)`).
- Dùng `padding = size * 0.2` để dấu không sát viền ô.

---

### Bước 4 — `components/board_component.dart`

- Kế thừa `Component` + `HasGameRef`.
- Override `render(Canvas canvas)`.
- Vẽ 2 đường **dọc** + 2 đường **ngang**, tạo lưới 3x3.
- `strokeWidth = 4`, `strokeCap = round`, màu `Colors.white70`.

---

### Bước 5 — `tic_tac_toe_game.dart`

- Kế thừa `FlameGame`.
- `onLoad()`:
  - Tính `_boardSize = size.x * 0.85`, `_boardOrigin` căn giữa màn hình.
  - Add `BoardComponent`.
  - Add 9 `CellComponent` tại đúng vị trí grid.
- `onCellTapped(int row, int col)`:
  1. Gọi `logic.makeMove(row, col)` — nếu false thì return.
  2. Add `MarkComponent` tại ô vừa đánh.
  3. Kiểm tra `logic.winner` hoặc `logic.isDraw` → gọi `overlays.add('result')`.
- `resetGame()`:
  - `overlays.remove('result')`.
  - `logic.reset()`.
  - `removeWhere((c) => c is MarkComponent)`.

---

### Bước 6 — `screens/game_screen.dart`

- `StatefulWidget`, khởi tạo `TicTacToeGame` trong `initState`.
- Layout: `Column` gồm **header lượt chơi** + `Expanded(GameWidget(...))`.
- `GameWidget` khai báo `overlayBuilderMap: {'result': (ctx, game) => ResultOverlay(...)}`.
- Header dùng `Stream.periodic(100ms)` + `StreamBuilder` để cập nhật `currentPlayer`.

```dart
GameWidget(
  game: _game,
  overlayBuilderMap: {
    'result': (context, game) => ResultOverlay(
          game: game as TicTacToeGame,
          onRestart: () => setState(() => _game.resetGame()),
        ),
  },
)
```

---

### Bước 7 — `screens/result_overlay.dart`

- Widget hiển thị tên người thắng hoặc "Hoà 🤝".
- Nút **"Chơi lại"** gọi `onRestart()` callback.
- UI: `Container` bo góc, nền tối semi-transparent, căn giữa màn hình.

---

### Bước 8 — Đăng ký route

Trong `route.dart`:
```dart
static const String ticTacToe = '/tic-tac-toe';
```
Trong `generateRoute`:
```dart
case Routes.ticTacToe:
  return MaterialPageRoute(builder: (_) => const GameScreen());
```

---

## 4. Luồng logic thắng thua

```
Tap ô → makeMove()
  ├─ Ô bận / game kết thúc → bỏ qua
  └─ Hợp lệ → ghi board → render MarkComponent
                  ├─ winner? → overlays.add('result')
                  ├─ isDraw? → overlays.add('result')
                  └─ Còn chỗ → đổi currentPlayer
Nút "Chơi lại" → resetGame() → xoá marks, reset logic
```

---

## 5. Lưu ý

> [!IMPORTANT]
> - Dùng `TapCallbacks` mixin (Flame 1.x), **không** dùng `Tappable` cũ.
> - Gọi `WidgetsFlutterBinding.ensureInitialized()` trong `main()` trước khi khởi tạo game.

> [!TIP]
> - Thay `CustomPainterComponent` bằng `SpriteComponent` nếu muốn dùng ảnh PNG cho X/O.
> - Thêm âm thanh tap/thắng bằng package `flame_audio`.
