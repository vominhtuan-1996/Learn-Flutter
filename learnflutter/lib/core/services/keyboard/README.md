# Hướng dẫn sử dụng module GlobalNoKeyboardRebuild

Module này cung cấp giải pháp tối ưu để quản lý việc "vẽ lại" (rebuild) toàn bộ giao diện ứng dụng khi bàn phím xuất hiện hoặc biến mất, giúp tránh tình trạng giật lag (jank) và giữ cho UI luôn mượt mà.

## Cấu trúc thư mục
- `lib/core/keyboard/global_nokeyboard_rebuild.dart`: Widget chính và logic xử lý.
- `lib/core/keyboard/keyboard_service.dart`: Dịch vụ giám sát trạng thái bàn phím toàn cục.

## Vấn đề giải quyết
Thông thường, khi bàn phím hiện lên, Flutter sẽ thay đổi `viewInsets.bottom` của `MediaQuery`, dẫn đến việc **toàn bộ các widget phụ thuộc vào MediaQuery sẽ bị rebuild**. Với các ứng dụng lớn, việc rebuild này gây tốn tài nguyên và lag animation.

`GlobalNoKeyboardRebuild` giải quyết bằng cách:
1. Chặn việc thay đổi `MediaQuery` khi chỉ có bàn phím thay đổi.
2. Sử dụng một Wrapper riêng (`_KeyboardPaddingWrapper`) để chỉ cập nhật đúng phần Padding ở đáy màn hình theo từng pixel của bàn phím native.

## Cách sử dụng

Bọc `GlobalNoKeyboardRebuild` ở cấp cao nhất của ứng dụng (trong hàm `runApp` hoặc ngay dưới `MaterialApp`):

```dart
void main() {
  runApp(
    GlobalNoKeyboardRebuild(
      child: MyApp(),
    ),
  );
}
```

### Các tham số (Parameters)

| Tham số | Kiểu dữ liệu | Mô tả |
|---------|--------------|-------|
| `child` | `Widget` | Widget con (thường là MyApp). |
| `addBottomPadding` | `bool` | Tự động thêm khoảng đệm phía dưới khi bàn phím hiện. Mặc định là `true`. |
| `animationDurationMs`| `int` | Thời gian animation khi tự động cuộn (Auto-scroll). |

## Tính năng tự động cuộn (Auto-Scroll)
Khi bàn phím xuất hiện, module sẽ tự động tìm Widget đang được Focus (ví dụ: `TextField`) và thực hiện `Scrollable.ensureVisible` để đảm bảo trường nhập liệu không bị bàn phím che khuất.

## Các quy tắc bảo trì (Maintenance Rules)
1. **Đa màn hình:** Nếu hỗ trợ Desktop/Tablet multi-window, cần cập nhật cách lấy `viewInsets` từ `View.of(context)`.
2. **Hiệu năng:** Tuyệt đối không thêm logic nặng vào `didChangeMetrics` vì nó chạy 60 lần/giây khi bàn phím đang trượt.
3. **Màu sắc:** Luôn giữ nền Wrapper là `transparent` để không ảnh hưởng đến Dark Mode/Background của ứng dụng.

