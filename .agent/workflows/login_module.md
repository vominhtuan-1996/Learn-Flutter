---
description: Quy trình tiêu chuẩn để phát triển module Login theo kiến trúc dự án
---

# Login Module Workflow

Tài liệu này hướng dẫn các bước chi tiết để xây dựng tính năng Login, từ định nghĩa dữ liệu đến giao diện người dùng, tuân thủ kiến trúc chuẩn của dự án.

## 1. Chuẩn bị cấu trúc thư mục

Tạo thư mục cho module login tại `lib/modules/login/`:
```text
lib/modules/login/
├── cubit/
├── state/
├── model/
├── repos/
└── screens/
```

## 2. Các bước triển khai

### Bước 1: Định nghĩa Model (`lib/modules/login/model/`)
Tạo `login_request_model.dart` và `login_response_model.dart`.
- Sử dụng `Equatable` hoặc kế thừa `SimpleItemModel`.
- Tham khảo: [.agent/template/model_development.md](file:///Users/tuanios_su12/learn_flutter/.agent/template/model_development.md)

### Bước 2: Định nghĩa State (`lib/modules/login/state/login_state.dart`)
Định nghĩa các trạng thái: `initial`, `loading`, `success`, `failure`.
- Luôn bao gồm thuộc tính `isLoading` và `errorMessage`.
- Tham khảo: [.agent/template/state_development.md](file:///Users/tuanios_su12/learn_flutter/.agent/template/state_development.md)

### Bước 3: Triển khai Repository (`lib/modules/login/repos/login_repository.dart`)
Tạo class xử lý gọi API login qua `ApiClient`.
```dart
class LoginRepository {
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final response = await ApiClient.instance.post('/auth/login', data: request.toJson());
    return LoginResponseModel.fromJson(response);
  }
}
```
> [!IMPORTANT]
> Đăng ký `LoginRepository` trong `lib/injector/injector.dart`.

### Bước 4: Triển khai Cubit (`lib/modules/login/cubit/login_cubit.dart`)
Điều khiển luồng logic login.
- Gọi `repository.login()` và cập nhật state tương ứng.
- Tham khảo: [.agent/template/cubit_development.md](file:///Users/tuanios_su12/learn_flutter/.agent/template/cubit_development.md)

### Bước 5: Đăng ký Router (`lib/component/routes/route.dart`)
- Thêm `static const String login = "/login";` vào class `Routes`.
- Cấu hình trong `generateRoute` để trả về `LoginPage`.

### Bước 6: Xây dựng giao diện (`lib/modules/login/screens/login_page.dart`)
Sử dụng `BlocProvider` để khởi tạo `LoginCubit` và `BlocConsumer` để xử lý navigate khi login thành công hoặc hiển thị thông báo lỗi.

## 3. Lưu ý quan trọng
- **Validation**: Thực hiện validate form tại Cubit hoặc Model trước khi gọi API.
- **Secure Storage**: Lưu trữ Token sau khi login thành công vào `SecureStorage` hoặc thông qua module service global.
- **Localization**: Mọi thông báo lỗi hoặc nhãn (Label) phải dùng `UtilsHelper.language`.
