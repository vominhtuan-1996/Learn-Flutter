# 🚀 Sliver Animation System

Hệ thống animation chuyên biệt cho `CustomScrollView` và `Slivers`, được tối ưu hóa cho hiệu năng cao (60fps) và khả năng tái sử dụng linh hoạt.

## 🏗 Cấu trúc Module

```text
sliver_animation/
 ├── core/                  # Trái tim của hệ thống
 │    ├── viewport_engine.dart       # Quản lý config và logic tính toán tiến trình
 │    └── render_viewport_aware.dart # RenderObject xử lý paint animation (60fps)
 ├── effects/               # Thư viện các hiệu ứng đơn lẻ
 │    ├── fade.dart         # Hiệu ứng mờ dần
 │    ├── scale.dart        # Hiệu ứng phóng to/thu nhỏ
 │    ├── parallax.dart     # Hiệu ứng di chuyển lệch tầng
 │    └── blur.dart         # Hiệu ứng làm mờ
 ├── widgets/               # Các Widget tiện ích đã đóng gói
 │    └── tiktok_viewport_list.dart  # Danh sách cuộn kiểu TikTok
 └── sliver_animation.dart  # Barrel export (Sử dụng file này để import)
```

---

## 💡 Hai phương pháp tiếp cận

### 1. Zero-rebuild (Ưu tiên)
Sử dụng `Custom RenderObject` để tính toán và vẽ animation trực tiếp trên Layer.
- **Ưu điểm**: Không gọi `setState`, cực kỳ mượt mà cho danh sách hàng ngàn items.
- **Sử dụng**: `TikTokViewportList` hoặc `ViewportAwareItem`.

### 2. State-based (Legacy/Linh hoạt)
Sử dụng `SliverAnimationCoordinator` để lắng nghe scroll offset và thông báo qua `ChangeNotifier`.
- **Ưu điểm**: Dễ tùy biến logic phức tạp bên ngoài render tree.
- **Sử dụng**: Xem các file root `sliver_animation_coordinator.dart`.

---

## 📖 Hướng dẫn sử dụng

### TikTok-style List (Tự động)
Cách nhanh nhất để tạo danh sách có hiệu ứng scale/fade dựa trên tâm màn hình:

```dart
TikTokViewportList(
  itemCount: 100,
  config: ViewportAnimationConfig(
    minScale: 0.9,
    minOpacity: 0.3,
  ),
  itemBuilder: (context, index) => MyCard(index: index),
)
```

### Custom Effects (Thủ công)
Nếu bạn muốn sử dụng các hiệu ứng đơn lẻ:

```dart
ViewportAwareItem(
  child: FadeEffect(
    progress: progress, // lấy từ state hoặc engine
    child: MyWidget(),
  ),
)
```

---

## 🔧 Định hướng Bảo trì & Mở rộng (Maintenance Rules)

### 1. Thêm hiệu ứng mới
- Luôn tạo file mới trong `effects/`.
- Format tên: `[Name]Effect`.
- Input luôn nhận `double progress` (0.0 đến 1.0).

### 2. Tối ưu hóa hiệu năng
- Mọi biến đổi hình học nên thực hiện trong `RenderViewportAware` để tránh rebuild widget tree.
- Sử dụng `RepaintBoundary` cho các item có nội dung phức tạp.
- Sử dụng `progressThreshold` trong `ViewportAnimationConfig` để tránh vẽ lại khi thay đổi quá nhỏ.

### 3. Quy tắc "60fps Guaranteed"
- KHÔNG gọi `setState` trong lúc cuộn.
- Hạn chế sử dụng `Opacity` widget truyền thống, hãy dùng `context.pushOpacity` trong `RenderObject`.

---

## ⚠️ Lưu ý về các file Legacy
Các file nằm trực tiếp tại thư mục root của `sliver_animation/` (như `sliver_animation_state.dart`, `sliver_effects.dart`) là phiên bản cũ dựa trên Coordinator. Chúng vẫn hoạt động nhưng khuyến khích chuyển sang hệ thống trong `core/` cho các tính năng mới đòi hỏi hiệu năng cao.
