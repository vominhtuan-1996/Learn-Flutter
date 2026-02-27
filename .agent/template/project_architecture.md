---
description: Template cấu trúc tổng thể của dự án (Core, Network, Helper, Asset)
---

# Project Architecture Template

Tài liệu này định nghĩa cấu trúc cấp cao của dự án, quy định nơi đặt các thành phần dùng chung và cách quản lý tài nguyên.

## 1. Cấu trúc thư mục gốc (lib/)

```text
lib/
├── app/            # Cấu hình app, định tuyến (router), theme gốc
├── core/           # Chứa các thành phần cốt lõi dùng chung toàn bộ dự án
│   ├── network/    # API Client (Dio/Http), interceptors, base response models
│   ├── theme/      # Design system, tokens, colors, typography
│   ├── service/    # Global services (AuthService, LocalStorage, Firebase)
│   └── constants/  # API endpoints, keys, configurations
├── utils_helper/   # Các hàm tiện ích (Date, String, Dialog, Format)
├── component/      # Các thành phần UI dùng chung, bao gồm Router
│   └── routes/     # Quản lý định tuyến tập trung
├── extensions/     # Các Dart extensions (UI, String, Number...)
├── modules/        # Chia theo feature (Xem feature_development.md)
└── l10n/           # Quản lý đa ngôn ngữ (Localization)
```

## 2. Các thành phần chính

### Core Layer (lib/core/)
- **Network**: Sử dụng `ApiClient` làm trung tâm để quản lý header, timeout và logging.
- **Service**: Các class xử lý logic global không thuộc feature cụ thể nào.
- **Theme**: Định nghĩa các giá trị HSL, Dark Mode và Light Mode.

### Router Management (lib/component/routes/)
Hệ thống định tuyến được quản lý tập trung:
- `route.dart`: Chứa class `Routes` định nghĩa tất cả `static const String` cho route name.
- `generateRoute`: Hàm xử lý logic chuyển hướng, truyền argument và animation (ví dụ: `SlideRightRoute`).

### Extension System (lib/extensions/)
Sử dụng Dart Extensions để mở rộng chức năng cho các class có sẵn:
- **UI Extensions**: Giúp viết code UI gọn hơn (ví dụ: `context.theme`, `widget.padding`).
- **Logic Extensions**: Các hàm xử lý String, DateTime hoặc List dùng chung.

### Helper Layer (lib/utils_helper/)
Nơi chứa các logic "pure logic" hoặc UI Helper dùng chung:
- `utils_helper.dart`: Class chính chứa các static methods hỗ trợ xử lý nhanh.
- `datetime_utils.dart`: Định dạng ngày tháng.
- `dialog_utils.dart`: Các mẫu dialog/bottom sheet chuẩn của dự án.

### Assets Management (assets/)
Tổ chức tài nguyên một cách có hệ thống:
```text
assets/
├── icons/          # Các icons dạng SVG hoặc PNG nhỏ
├── images/         # Hình ảnh minh họa (background, logo)
├── lottie/         # Các file hiệu ứng chuyển động
└── fonts/          # Custom typography
```
> [!TIP]
> Luôn khai báo đường dẫn assets trong `pubspec.yaml` theo folder để dễ quản lý.

## 3. Quy tắc tích hợp

- **Dependency Injection**: Mọi class trong `core/` hoặc `repos/` phải được đăng ký trong `lib/injector/injector.dart` để có thể sử dụng qua `sl<T>()`.
- **Global Constants**: Không định nghĩa endpoint API trực tiếp trong feature, hãy đặt tại `lib/core/constants/api_endpoints.dart`.
- **Base Components**: Sử dụng các widget tại `lib/component/` hoặc `lib/custom_widget/` để đảm bảo tính nhất quán về UI.

## 4. Quản lý tài nguyên (Asset Helper)
Khi sử dụng asset, nên tạo một class helper để tránh sai sót chính tả đường dẫn:
```dart
class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String icHome = 'assets/icons/ic_home.svg';
}
```
