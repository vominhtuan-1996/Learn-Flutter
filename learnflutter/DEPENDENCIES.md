# LearnFlutter — Dependencies & Warnings

> Cập nhật: 2026-05-21. File này tổng hợp toàn bộ dependency thực tế trong [pubspec.yaml](pubspec.yaml) và các cảnh báo cần lưu ý khi build / chạy.

---

## 🎯 Environment

```yaml
sdk: ">=3.0.0 <4.0.0"
platforms: ios, android
```

---

## 📦 Dependencies (theo nhóm)

### State Management
```yaml
flutter_bloc: ^8.0.1          # override -> ^9.1.1
bloc (override): ^9.0.0
hooks_riverpod: ^2.5.1
flutter_riverpod: ^2.6.1
flutter_hooks: ^0.21.2
provider: any
rxdart: any
equatable: ^2.0.7
freezed_annotation: ^3.0.0
```

### Networking & Logging
```yaml
dio: ^5.1.1
http: ^1.6.0
curl_logger_dio_interceptor: ^1.0.0
flutter_curl: ^0.5.1
talker_flutter: ^5.1.14
talker_dio_logger: ^5.1.14
ntp: ^2.0.0
```

### Storage / Local DB
```yaml
sqflite: ^2.2.8+4
hive: ^2.2.3
hive_flutter: ^1.1.0
shared_preferences: ^2.1.0
path: ^1.8.3
path_provider: ^2.1.5
flutter_dotenv: ^5.1.0
archive: ^3.6.1
xml: ^6.5.0
```

### Camera / Media / Sensors
```yaml
camera: ^0.11.0+1
camerawesome: ^2.5.0
sensors_plus: ^6.0.1          # dùng cho auto-orientation trong CameraScreen
video_player: ^2.7.2
image_picker: ^1.1.0
image_gallery_saver: ^2.0.3
mobile_scanner: ^6.0.0
qr_code_scanner: ^1.0.1
qr_code_tools: ^0.2.0
pretty_qr_code: ^3.4.0
file_picker: ^10.0.0
open_file_plus: ^3.4.1
pdf_render: ^1.4.12
mime: any
cross_file: ^0.3.3+6
share_plus: ^12.0.1
permission_handler: ^12.0.0
```

### Maps / Location
```yaml
google_maps_flutter: ^2.12.3
google_maps_cluster_manager_2: ^3.0.0+1
flutter_map: ^8.1.1
flutter_map_mbtiles: ^1.0.4
mbtiles: ^0.4.2
vector_map_tiles: ^9.0.0-beta.8
vector_tile_renderer: ^6.0.0
latlong2: ^0.9.0
geolocator: ^13.0.4
visibility_detector: ^0.4.0
```

### Auth / Social
```yaml
sign_in_with_apple: ^6.1.1
flutter_facebook_auth: ^7.1.1
google_sign_in: ^6.2.2
pinput: ^5.0.0
```

### UI / UX / Animation
```yaml
google_fonts: ^4.0.4
flutter_localizations: sdk
flutter_localization: ^0.3.2
flutter_svg: ^2.0.10+1
flutter_screenutil: any
flutter_animate: ^4.5.2
lottie: ^3.0.0
flutter_spinkit: ^5.2.1
loading_animation_widget: ^1.3.0
skeletonizer: ^1.4.3
animated_segmented_tab_control: any
animated_tree_view: ^2.3.0
animated_bottom_navigation_bar: ^1.3.3
another_transformer_page_view: ^2.0.1
another_flutter_splash_screen: ^1.2.1
pie_menu: ^3.2.7
popover: ^0.3.1
draggable_fab: ^0.1.4
custom_refresh_indicator: ^4.0.1
input_history_text_field: ^0.4.0
two_dimensional_scrollables: ^0.3.3
flutter_staggered_grid_view: ^0.7.0
scrollable_positioned_list: ^0.3.8
carousel_slider: any
calendar_date_picker2: ^2.0.0
flutter_progress_hud: ^2.0.2
flutter_svprogresshud: ^1.0.0
bmprogresshud: ^1.0.1
awesome_snackbar_content: any
cupertino_icons: ^1.0.2
path_drawing: ^1.0.0
```

### Charts / 3D / Game
```yaml
syncfusion_flutter_charts: ^29.1.38
flame: ^1.15.0
flutter_3d_controller: ^2.2.0
```

### WebView / URL
```yaml
webview_flutter: ^4.7.0
url_launcher: ^6.1.14
```

### Chat
```yaml
flutter_chat_ui: ^1.6.15
flutter_chat_types: ^3.6.2
uuid: ^4.5.1
```

### Background / Notifications
```yaml
workmanager: ^0.5.1
flutter_local_notifications: ^17.2.2
notification_center: ^0.0.3
flutter_isolate: ^2.0.4
flutter_downloader: ^1.10.5
```

### Excel / Expressions / Utils
```yaml
excel: ^4.0.2
expressions: ^0.2.5
diacritic: ^0.1.6
vector_math: any
shorebird_code_push: ^2.0.4
```

### Local module (path dependency)
```yaml
mobimap_module:
  path: /Users/tuanios_su12/mobimap_module
```

### Dev Dependencies
```yaml
flutter_test: sdk
flutter_lints: ^5.0.0
build_runner: ^2.4.6
freezed: ^3.0.0-0.0.dev
hive_generator: ^2.0.1
```

### Dependency Overrides
```yaml
flutter_bloc: ^9.1.1
bloc: ^9.0.0
```

---

## ⚠️ Warnings & Lưu ý

### 1. Dependency overrides
- `flutter_bloc` được khai báo `^8.0.1` nhưng override sang `^9.1.1` → API có breaking change giữa 8.x và 9.x (vd. `BlocProvider.value`, removed `mapEventToState`). Khi đọc tài liệu phải theo bản 9.x.
- Block `dependencies_overrides` đúng chính tả phải là `dependency_overrides`. **Kiểm tra lại pubspec** — nếu sai chính tả thì pub sẽ bỏ qua override im lặng.

### 2. Local path dependency
- `mobimap_module` trỏ tới đường dẫn tuyệt đối `/Users/tuanios_su12/mobimap_module` → **không build được trên máy khác / CI**. Cần đổi sang git dependency hoặc đường dẫn tương đối trước khi share.

### 3. Camera + Sensors (auto-orientation)
- iOS [Info.plist](ios/Runner/Info.plist) cần:
  - `NSCameraUsageDescription`
  - `NSMicrophoneUsageDescription` (vì `enableAudio: true` khi quay video)
  - `NSPhotoLibraryAddUsageDescription` (nếu lưu vào Photos)
  - `NSMotionUsageDescription` (sensors_plus accelerometer trên iOS 17+)
- Android [AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) cần:
  - `<uses-permission android:name="android.permission.CAMERA"/>`
  - `<uses-permission android:name="android.permission.RECORD_AUDIO"/>`
  - `<uses-feature android:name="android.hardware.camera"/>`
- `CameraScreen` dùng `sensors_plus` → khi xoay máy, ảnh/video sẽ ghi metadata đúng chiều thực tế (xem [camera_screen.dart](lib/core/services/camera/camera_screen.dart)).

### 4. Package đã/đang deprecated hoặc out-of-date
- `qr_code_scanner` (^1.0.1) → **không còn maintain**, AGP 8 trở lên build lỗi. Nên migrate sang `mobile_scanner` (đã có sẵn).
- `qr_code_tools` (^0.2.0) → ít cập nhật, kiểm tra tương thích AndroidX.
- `pdf_render` → tác giả khuyến nghị chuyển sang `pdfrx`.
- `image_gallery_saver` (^2.0.3) → bản gốc archived; cân nhắc `image_gallery_saver_plus` / `gal`.
- `flutter_svprogresshud`, `bmprogresshud`, `flutter_progress_hud` → cùng mục đích, đang dùng cả 3. Nên gộp.
- `google_fonts: ^4.0.4` → cũ (đã có bản 6.x). Nâng cấp giúp giảm cảnh báo SDK constraint.
- `freezed_annotation: ^3.0.0` + `freezed: ^3.0.0-0.0.dev` (pre-release) → API generator có thể khác bản stable, cẩn thận khi nâng Dart SDK.
- `another_flutter_splash_screen`, `notification_center`, `draggable_fab`, `bmprogresshud` → publisher cá nhân, ít update; theo dõi tương thích Flutter mới.

### 5. Trùng lặp chức năng
| Chức năng | Packages đang cùng tồn tại |
|---|---|
| State management | `flutter_bloc`, `provider`, `flutter_riverpod`, `hooks_riverpod`, `flutter_hooks` |
| Progress HUD | `flutter_svprogresshud`, `bmprogresshud`, `flutter_progress_hud`, `flutter_spinkit`, `loading_animation_widget`, `skeletonizer` |
| QR | `qr_code_scanner`, `mobile_scanner`, `qr_code_tools`, `pretty_qr_code` |
| Camera | `camera`, `camerawesome`, `image_picker` |
| Maps | `google_maps_flutter`, `flutter_map` (+ vector tiles, mbtiles) |
| HTTP | `dio`, `http`, `flutter_curl` |
> Cân nhắc loại bỏ bớt để giảm kích thước APK/IPA và tránh xung đột Gradle/CocoaPods.

### 6. Phiên bản `any`
Các package đang dùng `any`: `carousel_slider`, `awesome_snackbar_content`, `mime`, `flutter_screenutil`, `animated_segmented_tab_control`, `rxdart`, `provider`, `vector_math`. → Pub sẽ tự lấy bản cao nhất, dễ vỡ build khi major bump. Nên pin version cụ thể.

### 7. iOS build
- Sau khi thêm `sensors_plus`, cần `cd ios && pod install`.
- `permission_handler ^12` yêu cầu iOS deployment target ≥ 12.0 — kiểm tra [Podfile](ios/Podfile).

### 8. Android build
- `compileSdk` cần ≥ 34 cho `camera`, `mobile_scanner`, `permission_handler 12`.
- `minSdk` khuyến nghị ≥ 23.

### 9. Generated / Build runner
Khi thay đổi class Freezed/Hive:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 10. Shorebird
- `shorebird_code_push: ^2.0.4` cần file `shorebird.yaml` (đã khai báo trong assets). Bảo đảm `app_id` đúng cho từng môi trường.

---

## 🛠 Lệnh thường dùng

```bash
flutter pub get
flutter pub outdated
flutter pub upgrade --major-versions
cd ios && pod install --repo-update
flutter clean && flutter pub get
```

---

## 📚 Reference Files
- [pubspec.yaml](pubspec.yaml)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [CLEANUP_SUMMARY.md](CLEANUP_SUMMARY.md)
- [lib/core/services/camera/camera_screen.dart](lib/core/services/camera/camera_screen.dart)
