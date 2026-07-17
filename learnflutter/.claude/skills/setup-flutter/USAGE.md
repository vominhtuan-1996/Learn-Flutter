# setup-flutter — Hướng dẫn sử dụng

Skill khởi tạo một **project Flutter mới** đã dựng sẵn kiến trúc, **self-contained** — không cần repo nguồn nào, không cần đổi tên package, chạy được trên mọi máy.

---

## 1. Skill này làm gì?

Tạo một app Flutter mới với backbone sẵn sàng dùng:

| Layer | Nội dung |
|---|---|
| `app/` | Root widget (`MaterialApp`), theme sáng/tối + `ThemeController`, localization (vi/en) |
| `core/` | `ApiClient` singleton (Dio + interceptors auth/retry/error/talker), `BaseCubit`, `BaseState`, `EnvironmentVariables`, `ApiException`, `BaseResponse` |
| `shared/` | `models/` (`BaseModel`, `UserModel`) + chỗ trống cho `components/widgets/utils` |
| `features/auth/` | Feature mẫu đầy đủ: `cubit / state / repos / screens` (màn login gọi API) |

Kèm: `analysis_options.yaml`, smoke test, `.gitignore` chặn secrets, cấu hình Android/iOS qua `--org`, và bước OTA **Shorebird** / CI **Fastlane** (tuỳ chọn).

**Triết lý:** feature-first + **Cubit/State (Equatable)** + **singleton repository**. KHÔNG dùng Clean Architecture nặng (injectable / dartz / usecase).

---

## 2. Cách gọi

```
/setup-flutter <app_name> [bundle_id]
```

| Tham số | Bắt buộc | Mô tả |
|---|---|---|
| `app_name` | ✅ | Tên project, **snake_case** (vd `my_app`) |
| `bundle_id` | ❌ | Reverse-DNS (vd `com.company.my_app`). Bỏ trống → mặc định `com.example.<app_name>` |

**Ví dụ:**
```
/setup-flutter shopfast com.acme.shopfast
/setup-flutter todo_app
```

Hoặc gọi bằng ngôn ngữ tự nhiên: *"tạo cho tôi project flutter tên shopfast tại ~/projects"*.

---

## 3. Kết quả sau khi chạy

- Project mới build được ngay: `flutter analyze` sạch, `flutter test` pass.
- `applicationId` (Android) & `PRODUCT_BUNDLE_IDENTIFIER` (iOS) đã set theo `bundle_id`.
- Toàn bộ file trong `lib/` dùng **import tương đối** → không phụ thuộc tên project.

Chạy thử:
```bash
flutter run --dart-define=appServerUrl=https://api.example.com --dart-define=appTitle=<app_name>
```

---

## 4. Việc cần làm tay (tuỳ chọn)

Skill cố ý KHÔNG tự làm các bước cần secret/tài khoản riêng:

- **Android signing:** tạo keystore + `android/key.properties`, thêm `signingConfigs.release`.
- **iOS signing:** set Team/Signing trong Xcode.
- **OTA:** `shorebird init` → `shorebird release|patch android|ios` (cần Shorebird CLI + đăng nhập).
- **CI/CD:** `fastlane init` rồi tự định nghĩa lane gọi `flutter build` + `shorebird`.

---

## 5. Thêm feature mới (sau khi scaffold)

Tạo `lib/features/<name>/` với 5 thư mục, dùng import tương đối:

```
features/<name>/
├── cubit/     <name>_cubit.dart      → extends BaseCubit<<Name>State>
├── state/     <name>_state.dart      → extends BaseState (Equatable)
├── model/     <name>_model.dart
├── repos/     <name>_repository.dart → singleton .instance, gọi ApiClient.instance
└── screens/   <name>_page.dart       → BlocProvider + BlocBuilder/BlocConsumer
```

Tham khảo `features/auth/` làm khuôn mẫu.

---

## 6. Tuỳ biến nhanh

| Muốn đổi | Sửa file |
|---|---|
| Màu / theme | `lib/app/theme/app_colors.dart`, `app_theme.dart` |
| Font chữ | `lib/app/theme/app_text_style.dart` (đang dùng Google Fonts Inter) |
| Chuỗi dịch / ngôn ngữ | `lib/app/localization/app_local_translate.dart` |
| Base URL / biến môi trường | `lib/core/config/environment_variables.dart` + cờ `--dart-define` |
| Header/timeout/interceptor API | `lib/core/network/api_client/` |

---

## 7. Lưu ý kỹ thuật

- **Versions:** danh sách dependency trong skill là mốc đã test với **Flutter 3.29.x / Dart 3.7**. SDK mới hơn báo conflict thì nâng package lên bản tương thích.
- **iOS bundle id:** không cho phép dấu `_`; Flutter tự camelCase phần `app_name` (vd `com.x.my_app` → iOS `com.x.myApp`).
- **fvm:** nếu máy dùng fvm, mọi lệnh `flutter` chạy qua `fvm flutter`. Skill tự phát hiện.
- **Import:** file trong `lib/` dùng `../..` (tương đối); chỉ file trong `test/` mới dùng `package:<app_name>/...`.

---

## 8. Cấu trúc skill

```
.claude/skills/setup-flutter/
├── SKILL.md    ← quy trình + toàn bộ nội dung file (Claude thực thi)
└── USAGE.md    ← tài liệu này
```
