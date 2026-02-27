---
description: Workflow phát triển State cho Cubit
---

# Workflow phát triển State

Tài liệu này hướng dẫn cách tạo class State cho Cubit, đảm bảo tính bất biến (immutability) và tích hợp tốt với luồng dữ liệu của dự án.

## 1. Cấu trúc State chuẩn (lib/modules/[module_name]/state/[module_name]_state.dart)

Mọi State class phải kế thừa từ `BaseState` và triển khai các thành phần sau:

```dart
import 'package:rii_mobimap/base/blocs/base_state.dart';
// Import các model cần thiết

class MyFeatureState extends BaseState {
  // 1. Khai báo các thuộc tính (luôn để final)
  final bool isLoading;
  final List<MyItemModel> items;
  final MyDetailModel? detail;

  // 2. Constructor với named parameters
  MyFeatureState({
    required this.isLoading,
    required this.items,
    this.detail,
  });

  // 3. Factory khởi tạo trạng thái ban đầu
  factory MyFeatureState.initial() {
    return MyFeatureState(
      isLoading: false,
      items: [],
    );
  }

  // 4. Phương thức cloneWith để cập nhật state một cách bất biến
  MyFeatureState cloneWith({
    bool? isLoading,
    List<MyItemModel>? items,
    MyDetailModel? detail,
  }) {
    return MyFeatureState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      detail: detail ?? this.detail,
    );
  }

  // 5. Override props của Equatable để so sánh state
  @override
  List<Object?> get props => [isLoading, items, detail];
}
```

## 2. Các quy tắc quan trọng

### Tính bất biến (Immutability)
- Luôn sử dụng `final` cho các thuộc tính của State.
- Không bao giờ thay đổi trực tiếp thuộc tính của state hiện tại.
- Luôn tạo ra một instance mới thông qua `cloneWith`.

### Trạng thái Loading
- Luôn có thuộc tính `isLoading` để quản lý trạng thái hiển thị loading trên UI.
- Thường mặc định là `false` trong `initial()`.

### Xử lý danh sách
- Khi khai báo danh sách, nên khởi tạo là `[]` thay vì `null` trong `initial()` để tránh lỗi Null Safety khi UI render.

## 3. Quy tắc đặt tên (devflutter.md)
- **Class Name**: Luôn kết thúc bằng `State` (ví dụ: `WorkInstructionState`). Sử dụng `PascalCase`.
- **File Name**: snake_case (ví dụ: `work_instruction_state.dart`).

## 4. Cách sử dụng trong Cubit
Trong Cubit, sử dụng `emit` kết hợp với `state.cloneWith` để cập nhật một hoặc nhiều thuộc tính:

```dart
void updateItems(List<MyItemModel> newItems) {
  emit(state.cloneWith(items: newItems, isLoading: false));
}
```
