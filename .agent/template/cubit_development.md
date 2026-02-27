---
description: Workflow phát triển Cubit và State theo mẫu chuẩn của dự án
---

# Workflow phát triển Cubit và State

Tài liệu này hướng dẫn cách tạo một module Cubit và State tuân thủ cấu trúc của dự án, đảm bảo tính nhất quán và dễ bảo trì.

## 1. Cấu trúc thư mục
Mỗi module nên có cấu trúc như sau:
- `lib/modules/[module_name]/cubit/` : Chứa file Cubit.
- `lib/modules/[module_name]/state/` : Chứa file State.
- `lib/modules/[module_name]/repos/` : Chứa Repository liên quan.
- `lib/modules/[module_name]/model/` : Chứa các model dữ liệu.

## 2. Tạo State (lib/modules/[module_name]/state/[module_name]_state.dart)
State phải kế thừa từ `BaseState` và triển khai các phương thức hỗ trợ `initial` và `cloneWith`.

```dart
import 'package:rii_mobimap/base/blocs/base_state.dart';
// Import các model cần thiết

class MyModuleState extends BaseState {
  final bool isLoading;
  final List<MyModel> dataList;
  // Thêm các thuộc tính khác ở đây

  MyModuleState({
    required this.isLoading,
    required this.dataList,
  });

  // Factory cho trạng thái khởi tạo
  factory MyModuleState.initial() {
    return MyModuleState(
      isLoading: false,
      dataList: [],
    );
  }

  // Phương thức cloneWith để cập nhật một phần state
  MyModuleState cloneWith({
    bool? isLoading,
    List<MyModel>? dataList,
  }) {
    return MyModuleState(
      isLoading: isLoading ?? this.isLoading,
      dataList: dataList ?? this.dataList,
    );
  }

  @override
  List<Object?> get props => [isLoading, dataList];
}
```

## 3. Tạo Cubit (lib/modules/[module_name]/cubit/[module_name]_cubit.dart)
Cubit kế thừa từ `BaseCubit` và sử dụng State đã tạo. Sử dụng `sl` để inject dependencies.

```dart
import 'package:rii_mobimap/base/blocs/base_cubit.dart';
import 'package:rii_mobimap/injector/injector.dart';
// Import State và Repos

class MyModuleCubit extends BaseCubit<MyModuleState> {
  MyModuleCubit() : super(MyModuleState.initial());

  // Khai báo repositories dùng Service Locator (sl)
  final repository = sl<MyModuleRepository>();

  // Phương thức xử lý logic
  void fetchData() async {
    try {
      // 1. Cập nhật trạng thái Loading
      emit(state.cloneWith(isLoading: true));

      // 2. Gọi repository
      final result = await repository.getData();

      // 3. Cập nhật dữ liệu vào state và tắt loading
      emit(state.cloneWith(dataList: result, isLoading: false));
    } catch (e) {
      // 4. Xử lý lỗi và tắt loading
      emit(state.cloneWith(isLoading: false));
    }
  }
}
```

## 4. Quy tắc đặt tên (BẮT BUỘC)
Theo quy định tại `devflutter.md`:
- **Class**: PascalCase (ví dụ: `MyModuleCubit`, `MyModuleState`).
- **File**: snake_case (ví dụ: `my_module_cubit.dart`, `my_module_state.dart`).
- **Biến/Phương thức**: camelCase (ví dụ: `fetchData`, `isLoading`).

## 5. Lưu ý quan trọng
- Luôn sử dụng `emit(state.cloneWith(...))` để cập nhật UI, không sử dụng `setState` tại widget.
- Các logic phức tạp phải được đưa vào Cubit.
- Luôn đảm bảo có Unit Test cho Cubit tại thư mục `test/modules/[module_name]/cubit/`.
