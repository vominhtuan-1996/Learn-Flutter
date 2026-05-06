# 🌀 Core Animation System (Spring Physics)

Hệ thống animation dựa trên vật lý lò xo, siêu nhẹ và được tối ưu hóa cho các tương tác UI (micro-interactions).

## 🏗 Kiến trúc hệ thống

Hệ thống hoạt động dựa trên 3 trụ cột chính:
1. **`CoreTicker` (Global)**: Một ticker duy nhất điều phối toàn bộ frame của app.
2. **`CoreAnimController` (Physics)**: Điều khiển giá trị animation dựa trên lực lò xo (Spring Force) thay vì thời gian (Duration).
3. **`AnimatedRepaint` (Widget)**: Tự động đăng ký/hủy listener và tối ưu hóa vẽ lại bằng `RepaintBoundary`.

---

## 📂 Cấu trúc Module

```text
core_anim/
 ├── core_anim.dart           # Barrel export
 └── src/
      ├── ticker/             # Global Ticker management
      ├── controller/         # Spring physics engine
      ├── widget/             # AnimatedRepaint core widget
      ├── effect/             # Composable effect system (Scale, Fade, Translate)
      └── painter/            # Custom painters (Ripple, v.v.)
```

---

## 📖 Hướng dẫn sử dụng

### 1. Spring Scale Effect (Cơ bản)
Tạo hiệu ứng nhấn nút co giãn tự nhiên:

```dart
final ctrl = CoreAnimController(value: 1.0);

GestureDetector(
  onTapDown: (_) => ctrl.press(),   // Co lại
  onTapUp: (_) => ctrl.release(), // Bung ra
  child: AnimatedRepaint(
    controller: ctrl,
    child: MyButton(),
    builder: (t, child) => ScaleEffect(min: 0.9).build(t, child),
  ),
)
```

### 2. Composite Effect (Nâng cao)
Kết hợp nhiều hiệu ứng cùng lúc:

```dart
builder: (t, child) => CompositeEffect([
  ScaleEffect(min: 0.92),
  TranslateEffect(Offset(0, 5), Offset.zero),
  OpacityEffect(min: 0.7),
]).build(t, child)
```

---

## 🔧 Định hướng Bảo trì & Mở rộng (Maintenance Rules)

### 1. Mở rộng Hiệu ứng
- Kế thừa lớp `AnimEffect`.
- Implement hàm `build(double t, Widget child)`.
- Sử dụng `t` (giá trị từ 0.0 đến 1.0) để `lerp` các thuộc tính cần animation.

### 2. Quản lý Ticker
- **BẮT BUỘC**: Luôn sử dụng `AnimatedRepaint` để bọc animation. Widget này đã xử lý việc `remove()` listener trong `dispose()` để tránh rò rỉ bộ nhớ.
- Chỉ gọi `CoreTicker().start(vsync)` một lần duy nhất tại root widget hoặc màn hình chính.

### 3. Tối ưu hóa hiệu năng
- Luôn đặt `RepaintBoundary` (đã có sẵn trong `AnimatedRepaint`) ở vị trí chiến lược để tách lớp vẽ.
- Sử dụng thuộc tính `isSettled` trong controller để dừng gọi `setState` khi animation đã ổn định.

### 4. Custom Painters
- Khi tạo `CustomPainter` mới (như `RipplePainter`), hãy kế thừa và sử dụng thuộc tính `progress` truyền từ `AnimatedRepaint` để vẽ theo frame.
