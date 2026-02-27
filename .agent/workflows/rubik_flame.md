---
description: Quy trình xây dựng game Rubik (giả lập 3D/2D) 2 người chơi luân phiên với Flame engine, bao gồm xử lý xoay mặt và logic thắng cuộc.
---

# Rubik Game (Flame) Workflow

Tài liệu này hướng dẫn xây dựng game **Rubik** phiên bản cạnh tranh 2 người chơi sử dụng **Flame**. Mỗi người chơi sẽ thực hiện luân phiên các lượt xoay (xoay hàng/cột) để giải khối Rubik hoặc đạt được mẫu mục tiêu.

---

## 1. Cấu trúc thư mục

Tạo thư mục tại `lib/games/rubik/`:

```text
lib/games/rubik/
├── rubik_game.dart             # FlameGame chính
├── components/
│   ├── cube_component.dart      # Component quản lý toàn bộ khối
│   ├── face_component.dart      # Component hiển thị các mặt
│   └── tile_component.dart      # Từng ô màu trên mặt Rubik
├── logic/
│   └── rubik_logic.dart         # Logic xoay mặt (Shift row/col) và check thắng
└── screens/
    ├── rubik_screen.dart        # Widget Flutter bọc game
    └── result_overlay.dart      # Overlay kết quả
```

---

## 2. Các bước triển khai

### Bước 1 — `logic/rubik_logic.dart` (Core Logic)

Quản lý trạng thái khối Rubik (thường là mảng 3D hoặc mảng Face 3x3).
- `void rotateLayer(int layer, Direction dir)`: Xử lý dịch chuyển các ô màu trên một hàng/cột/mặt.
- `bool isSolved()`: So sánh trạng thái hiện tại với trạng thái ban đầu (mỗi mặt một màu đồng nhất).
- `Player currentPlayer`: Quản lý lượt chơi (người chơi A xoay, sau đó đến B).
- `int movesCount`: Giới hạn lượt hoặc đếm lượt để xác định thắng thua khi giải xong.

---

### Bước 2 — `components/tile_component.dart`

Hiển thị từng ô màu của khối Rubik.
- Kế thừa `RectangleComponent`.
- Nhận màu sắc (`Color`) và tọa độ vị trí trong khối.
- Hỗ trợ hiệu ứng đổi màu hoặc di chuyển khi có lệnh xoay từ Logic.

---

### Bước 3 — `components/cube_component.dart`

Component tổ chức 6 mặt (nếu 3D) hoặc 1 mặt chính (nếu 2D Match).
- Lắng nghe sự kiện kéo/vuốt (`PanDetector` hoặc `DragCallbacks`).
- Xác định hướng vuốt của người chơi để gọi `logic.rotateLayer`.
- Cập nhật lại vị trí các `TileComponent` tương ứng sau khi xoay.

---

### Bước 4 — `rubik_game.dart` (Flame Engine)

- Khởi tạo khối Rubik ở trạng thái bị xáo trộn (Scramble).
- Điều phối sự kiện: Tap/Drag -> Logic xoay -> Re-render components.
- Kiểm tra `logic.isSolved()` sau mỗi lượt xoay.
- Nếu giải xong, gọi `overlays.add('result')`.

---

### Bước 5 — `screens/rubik_screen.dart`

- Chứa `GameWidget` và các UI điều khiển (nút xoay nhanh, đồng hồ đếm giờ).
- Hiển thị lượt của Player 1 hay Player 2 ở Header.
- Cung cấp overlay thông báo người thắng (người thực hiện nước đi cuối cùng để giải xong hoặc người tốn ít lượt hơn).

---

## 3. Logic Win & Lượt chơi

1. **Lượt chơi**:
   - Player 1 thực hiện 1 hoặc n thao tác xoay.
   - Player 2 thực hiện lượt tiếp theo.
2. **Win Condition**:
   - Người chơi nào thực hiện nước đi cuối cùng đưa Rubik về trạng thái đồng nhất màu các mặt sẽ thắng.
   - Hoặc: Cạnh tranh xem ai đưa được mẫu trung tâm (3x3 trên mặt chính) khớp với "Key" nhanh nhất (theo luật Rubik's Race).

---

## 4. Lưu ý quan trọng

> [!IMPORTANT]
> - Với Rubik 3D, hãy sử dụng `flame_three` hoặc tự định nghĩa ma trận xoay (Projection Matrix).
> - Với bản 2D (như Rubik's Race), sử dụng `PositionComponent` và hiệu ứng `MoveEffect` để tạo cảm giác trượt các ô.

> [!TIP]
> - Nên thêm hiệu ứng âm thanh "click/slide" khi các ô chuyển động để tăng tính chân thực.
> - Sử dụng `GestureDetector` của Flutter bọc ngoài nếu muốn xử lý đa điểm chạm phức tạp hơn Flame mặc định.
