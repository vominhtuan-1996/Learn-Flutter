# BaseDraggableLoading

Scaffold wrapper kết hợp 2 thứ:
1. **Floating draggable widget** — 1 FAB có thể kéo thả tự do khắp màn hình, optional vùng "xoá" ở mép dưới.
2. **Overlay loading** — full-screen loading dựa trên `BaseLoadingCubit` (BLoC), hiển thị GIF + message khi `state.isLoading == true`.

```
lib/shared/components/base_loading_draggable/
├── base_draggable_loading.dart        -> BaseDraggableLoading widget
├── draggable_example_screen.dart      -> DraggableExampleScreen (demo)
└── README.md
```

---

## 1. Dùng nhanh

```dart
import 'package:learnflutter/shared/components/base_loading_draggable/base_draggable_loading.dart';
import 'package:learnflutter/core/global/func_global.dart'; // showLoading()

BaseDraggableLoading(
  floatSize: const Size(64, 64),
  floatingActionButton: FloatingActionButton(
    onPressed: () => showLoading(context: context, message: 'Đang tải...'),
    child: const Icon(Icons.cloud_download),
  ),
  child: const MyContent(),
)
```

> ⚠️ Bắt buộc bọc app trong `BlocProvider<BaseLoadingCubit>` ở trên cây widget — `BaseDraggableLoading` dùng `BlocBuilder` đọc state. `showLoading()` / `hideLoading()` chính là helper trigger cubit này.

---

## 2. API

| Tham số | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `child` | `Widget` | **bắt buộc** | Body của Scaffold bên trong |
| `floatSize` | `Size` | **bắt buộc** | Kích thước floating widget (để tính vị trí init) |
| `floatingActionButton` | `Widget?` | FAB `+` mặc định | Widget được kéo thả |
| `appBar` | `PreferredSizeWidget?` | `AppBar()` | AppBar của Scaffold trong |
| `drawer` / `bottomNavigationBar` / `floatingActionButtonLocation` | — | `null` | Forward thẳng vào Scaffold |
| `hasDeletedWidget` | `bool` | `true` | Hiện vùng "xoá" ở mép dưới khi đang kéo |
| `onDeleteWidget` | `VoidCallback?` | `null` | Callback khi thả vào vùng xoá |
| `onDragEvent` | `Function(double dx, double dy)?` | `null` | Callback liên tục khi kéo (toạ độ FAB) |
| `onDragging` | `Function(bool)?` | `null` | Callback khi bắt đầu/kết thúc kéo |
| `autoAlign` | `bool` | `true` | Tự snap về mép trái/phải sau khi thả |
| `disableBounceAnimation` | `bool` | `true` | Tắt hiệu ứng bounce |
| `backgroundColor` | `Color` | `Colors.white` | Màu nền Scaffold |
| `isLoading` | `bool` | `false` | *(legacy)* — state thực tế đọc từ `BaseLoadingCubit` |
| `message` | `String?` | `''` | *(legacy)* — message đọc từ `BaseLoadingCubit.state.message` |

> Các field `isLoading` / `message` ở constructor được giữ vì backward-compat nhưng widget không dùng — overlay loading luôn lấy từ `BaseLoadingCubit` thông qua `BlocBuilder`.

---

## 3. Trigger loading

`func_global.dart` cung cấp helper:

```dart
showLoading(context: context, message: 'Đang xử lý...');
hideLoading(context: context);
```

Hai hàm này dispatch action lên `BaseLoadingCubit` — overlay tự hiện/ẩn trên tất cả `BaseDraggableLoading` đang mounted.

---

## 4. Vùng "delete"

- Khi kéo FAB xuống mép dưới và thả → gọi `onDeleteWidget`.
- Decoration: gradient trắng → xám, bo tròn góc trên 50px.
- Icon: `Icons.close` trong vòng tròn viền đen.
- Tắt vùng này bằng `hasDeletedWidget: false`.

---

## 5. Ràng buộc & lưu ý

- **Asset bắt buộc**: `assets/images/loading_mobimap_rii.gif` phải được khai báo trong `pubspec.yaml` — overlay loading hardcode dùng GIF này.
- **Phụ thuộc theo project**: `app_box_decoration.dart`, `utils_helper.dart`, `extension_context.dart`, `device_dimension.dart` — không tách rời được.
- **AppBar mặc định** là `AppBar()` trống — luôn truyền `appBar:` riêng cho production.
- Không nên lồng nhiều `BaseDraggableLoading` — sẽ render nhiều overlay loading chồng nhau khi cubit emit `isLoading = true`.

---

## 6. Demo trực quan

Mở `DraggableExampleScreen` ([draggable_example_screen.dart](draggable_example_screen.dart)) — có:
- 2 SwitchListTile toggle `autoAlign` / `hasDeletedWidget` realtime.
- Card hiển thị toạ độ FAB + trạng thái dragging (qua `onDragEvent` / `onDragging`).
- 3 nút trigger overlay loading với message ngắn / dài / rỗng.
- FAB đổi màu (`indigo` → `orange`) khi đang được kéo.

Route: `Routes.draggableExampleScreen` — card "Floating Draggable Widget" đã có sẵn trong [test_screen.dart:891](../../../features/test_screen/test_screen.dart#L891).
