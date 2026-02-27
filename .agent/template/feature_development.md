---
description: Template chuẩn để tạo một Feature/Module mới theo kiến trúc Cubit (Clean Architecture simplified)
---

# Feature Development Template

Tài liệu này hướng dẫn quy trình tiêu chuẩn để tạo một Feature mới trong dự án, đảm bảo tính đồng nhất về cấu trúc và logic.

## 1. Cấu trúc thư mục (lib/modules/[feature_name]/)

Mọi feature mới phải được tổ chức theo cấu trúc sau:

```text
lib/modules/[feature_name]/
├── cubit/          # Logic điều khiển layer và xử lý sự kiện
├── state/          # Định nghĩa các trạng thái của UI
├── model/          # Data models, DTOs, JSON parsing
├── repos/          # Data source, API calls, Repository pattern
└── screens/        # UI layer (Widgets, Pages)
```

## 2. Quy trình triển khai (Step-by-Step)

### Bước 1: Tạo Data Model
Xác định cấu trúc dữ liệu trả về từ API hoặc dữ liệu hiển thị.
- Link: [.agent/template/model_development.md](file:///Users/tuanios_su12/learn_flutter/.agent/template/model_development.md)

### Bước 2: Tạo State
Định nghĩa các trạng thái (loading, success, error, data).
- Link: [.agent/template/state_development.md](file:///Users/tuanios_su12/learn_flutter/.agent/template/state_development.md)

### Bước 3: Tạo Repository
Triển khai các phương thức gọi API.
```dart
class MyFeatureRepository {
  Future<List<MyModel>> getData() async {
    // API calling logic
    return [];
  }
}
```
> [!IMPORTANT]
> Nhớ đăng ký Repository vào `injector.dart` thông qua `sl`.

### Bước 4: Tạo Cubit
Kết nối logic giữa Repository và UI thông qua State.
- Link: [.agent/template/cubit_development.md](file:///Users/tuanios_su12/learn_flutter/.agent/template/cubit_development.md)

### Bước 5: Xây dựng giao diện (Screens/Widgets)
Sử dụng `BlocBuilder` hoặc `BlocConsumer` để lắng nghe state từ Cubit.

## 3. Quy tắc Coding chuẩn (devflutter.md)

- **Immutability**: Luôn sử dụng `final` và `cloneWith` cho State.
- **Service Locator**: Sử dụng `sl<T>()` để lấy instance của Repo/Cubit.
- **Naming**: 
  - Class: `MyFeatureCubit`, `MyFeatureState`, `MyFeatureScreen`.
  - File: `my_feature_cubit.dart`, `my_feature_state.dart`.
- **Localization**: Không dùng hardcoded strings, hãy dùng `UtilsHelper.language`.

## 4. Ví dụ Boilerplate

### lib/modules/[feature_name]/screens/[feature_name]_page.dart
```dart
class MyFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyFeatureCubit>()..init(),
      child: Scaffold(
        body: BlocBuilder<MyFeatureCubit, MyFeatureState>(
          builder: (context, state) {
            if (state.isLoading) return CircularProgressIndicator();
            return ListView(...);
          },
        ),
      ),
    );
  }
}
```
