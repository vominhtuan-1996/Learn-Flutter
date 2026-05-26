# Hướng dẫn sử dụng module GlobalNoKeyboardRebuild

Module này cung cấp giải pháp tối ưu để quản lý việc "vẽ lại" (rebuild) toàn bộ giao diện ứng dụng khi bàn phím xuất hiện hoặc biến mất, giúp tránh tình trạng giật lag (jank) và giữ cho UI luôn mượt mà.

## Cấu trúc thư mục
- `lib/core/services/keyboard/global_nokeyboard_rebuild.dart`: Widget chính và logic xử lý.
- `lib/core/services/keyboard/keyboard_service.dart`: Dịch vụ giám sát trạng thái bàn phím toàn cục.

## Vấn đề giải quyết
Thông thường, khi bàn phím hiện lên, Flutter sẽ thay đổi `viewInsets.bottom` của `MediaQuery`, dẫn đến việc **toàn bộ các widget phụ thuộc vào MediaQuery sẽ bị rebuild**. Với các ứng dụng lớn, việc rebuild này gây tốn tài nguyên và lag animation.

`GlobalNoKeyboardRebuild` giải quyết bằng cách:
1. Chặn việc thay đổi `MediaQuery` khi chỉ có bàn phím thay đổi.
2. Sử dụng `_KeyboardPaddingWrapper` để cập nhật đúng phần Padding ở đáy theo từng pixel của bàn phím native.
3. Đặt một overlay gradient **NẰM TRÊN** scaffold qua `Stack` cho vùng keyboard → màu vùng keyboard không bị `scaffoldBackgroundColor` chi phối.

## Cách sử dụng

Bọc `GlobalNoKeyboardRebuild` ở cấp cao nhất (trong `runApp`):

```dart
void main() {
  runApp(
    GlobalNoKeyboardRebuild(
      // Default gradient: white → gray (top → bottom)
      child: MyApp(),
    ),
  );
}
```

Custom gradient:

```dart
GlobalNoKeyboardRebuild(
  bottomFillGradient: const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE5E7EB), Color(0xFF6B7280)],
  ),
  child: MyApp(),
)
```

Tắt overlay (để scaffoldBg lộ tự nhiên):

```dart
GlobalNoKeyboardRebuild(
  bottomFillGradient: null,
  child: MyApp(),
)
```

### Các tham số (Parameters)

| Tham số | Kiểu dữ liệu | Mô tả |
|---------|--------------|-------|
| `child` | `Widget` | Widget con (thường là `MyApp`). |
| `addBottomPadding` | `bool` | Tự động thêm khoảng đệm phía dưới khi bàn phím hiện. Mặc định `true`. |
| `animationDurationMs`| `int` | Dùng cho 2 việc: (1) `Scrollable.ensureVisible` khi auto-scroll, (2) thời gian decay của overlay fill khi dismiss. Mặc định `200`. |
| `animationCurve` | `Curve` | Đường cong animation cho auto-scroll. Mặc định `Curves.decelerate`. |
| `bottomFillGradient` | `Gradient?` | Gradient phủ vùng keyboard, đặt **trên** scaffold qua `Stack`. Mặc định `LinearGradient(white → gray)`. `null` = không phủ. |

## Tính năng tự động cuộn (Auto-Scroll)
Khi bàn phím xuất hiện, module sẽ tự động tìm Widget đang được Focus (ví dụ `TextField`) và gọi `Scrollable.ensureVisible` để đảm bảo trường nhập liệu không bị bàn phím che khuất.

## Hành vi show / dismiss

Module track hai giá trị độc lập:

- **`_keyboardHeight`** — mirror chính xác `viewInsets.bottom` theo từng frame, drive cho `Padding` để content (scaffold) tránh keyboard.
- **`_fillHeight`** — drive cho overlay gradient, hoạt động riêng:
  - **Show / resize:** bám sát `_keyboardHeight` instant.
  - **Dismiss:** decay từ giá trị cũ về `0` qua `AnimationController` trong `animationDurationMs`. Cần thiết vì trên iOS, `viewInsets.bottom` thường nhảy về `0` ngay khi keyboard bắt đầu trượt xuống — nếu overlay biến mất theo, vùng keyboard sẽ lộ scaffoldBg trong ~200ms keyboard slide. Decay riêng giữ overlay phủ kín suốt animation.

### ⚠️ Vùng "đen" lộ ra khi dismiss
Trước khi có overlay gradient, vùng tối lộ ra khi keyboard slide xuống là do **scaffoldBackgroundColor** (theme tối) — không phải window native. Module hiện tại dùng overlay gradient phủ trên scaffold để giải quyết triệt để vấn đề này.

Nếu vẫn cần "trong suốt" cho phép scaffoldBg lộ → set `bottomFillGradient: null`.

## Các quy tắc bảo trì (Maintenance Rules)
1. **Đa màn hình:** Nếu hỗ trợ Desktop/Tablet multi-window, cập nhật cách lấy `viewInsets` từ `View.of(context)` thay vì `views.first`.
2. **Hiệu năng:** Tuyệt đối không thêm logic nặng vào `didChangeMetrics` — chạy mỗi frame khi keyboard trượt.
3. **Directionality:** `Stack` cho overlay cần `Directionality`. Wrapper đã tự cung cấp `TextDirection.ltr` vì nằm trên `MaterialApp` (chưa có `Localizations`). KHÔNG xoá `Directionality` wrap quanh `Stack`.
4. **Decay tách rời:** giữ nguyên `AnimationController` cho `_fillHeight` trong nhánh dismiss — nếu để `_fillHeight` đi theo `viewInsets` thì overlay sẽ biến mất tức thì trên iOS, mất tác dụng che scaffoldBg.
5. **Default gradient:** mặc định `white → gray` là lựa chọn trung tính cho cả Light/Dark theme. Khi app có theme đặc thù, override `bottomFillGradient` cho đồng bộ thị giác.
