# Hướng dẫn sử dụng Camera Module

Module Camera trong dự án được thiết kế để cung cấp khả năng chụp ảnh và quay video linh hoạt, có thể tái sử dụng ở bất kỳ đâu trong ứng dụng.

## Cấu trúc thư mục
- [camera_screen.dart](camera_screen.dart): Widget Shell chính quản lý luồng phần cứng, trạng thái chụp, auto-orientation từ accelerometer và xử lý callback.
- [model/camera_mode.dart](model/camera_mode.dart): Enum chế độ hoạt động (`photo`, `video`).
- [widgets/](widgets/): Thư mục chứa các thành phần giao diện tách biệt:
  - `circle_icon_button.dart`: Nút icon tròn mờ đa dụng.
  - `camera_top_bar.dart`: Thanh công cụ trên cùng (Đóng, Flash, Flip, Thời lượng video).
  - `camera_zoom_slider.dart`: Slider zoom phần cứng.
  - `camera_mode_selector.dart`: Lựa chọn chế độ Ảnh/Video (tự ẩn nếu chỉ cấu hình 1 mode).
  - `camera_bottom_controls.dart`: Bộ điều khiển dưới (thumbnail kèm bộ đếm ảnh, nút capture, nút hoàn thành).
  - `camera_gallery_preview.dart`: Overlay xem lại ảnh PageView, hỗ trợ chụp lại đúng index.

## Dependencies bắt buộc
```yaml
camera: ^0.11.0+1
video_player: ^2.7.2
sensors_plus: ^6.0.1   # auto-orientation theo cảm biến
```

Sau khi thêm, chạy:
```bash
flutter pub get
cd ios && pod install
```

## Cách sử dụng

### 1. Khởi tạo cơ bản
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CameraScreen(
      initialMode: CameraMode.photo,
      onPhotoCaptured: (XFile photo) {
        print('Đã chụp ảnh: ${photo.path}');
      },
      onVideoRecorded: (XFile video) {
        print('Đã quay video: ${video.path}');
      },
    ),
  ),
);
```

### 2. Tham số (Parameters)
| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| `initialMode` | `CameraMode` | Chế độ mặc định (`photo`/`video`). Mặc định: `photo`. |
| `onPhotoCaptured` | `Function(XFile)?` | Callback ngay sau khi chụp ảnh thành công. |
| `onVideoRecorded` | `Function(XFile)?` | Callback ngay sau khi dừng quay video thành công. |
| `minZoom` | `double?` | Cận dưới zoom (clamp theo phần cứng). |
| `maxZoom` | `double?` | Cận trên zoom (clamp theo phần cứng). |
| `maxLength` | `int?` | Giới hạn số ảnh chụp; đạt ngưỡng sẽ tự `pop` danh sách `List<XFile>`. |
| `modes` | `List<CameraMode>?` | Các mode được phép. Nếu chỉ 1 phần tử thì ẩn selector. |

## Các tính năng chính
- **Chụp ảnh:** Multi-capture với bộ đếm + thumbnail; có chế độ "chụp lại đúng vị trí" (retake by index).
- **Quay Video:** Pause/Resume, đồng hồ thời gian thực; tự phát lại preview sau khi dừng.
- **Zoom:** Pinch (2 ngón) hoặc slider; tôn trọng `minZoom`/`maxZoom`.
- **Flash:** Xoay vòng Auto → On → Off.
- **Flip:** Đổi camera trước/sau.
- **Tự khôi phục theo vòng đời:** Tự giải phóng khi vào background, init lại khi resume.
- **Auto-orientation từ cảm biến (mới):** Dùng `sensors_plus` đọc accelerometer (`x`, `y`) để suy ra `DeviceOrientation` thực tế và gọi `CameraController.lockCaptureOrientation(...)`. Nhờ vậy ảnh/video luôn ghi đúng chiều cầm máy **kể cả khi UI bị khóa portrait**.

### Cách auto-orientation hoạt động
| Trạng thái máy | Suy ra |
|---|---|
| `y > 0`, `|y| > |x|` | `portraitUp` |
| `y < 0`, `|y| > |x|` | `portraitDown` |
| `x > 0`, `|x| > |y|` | `landscapeLeft` |
| `x < 0`, `|x| > |y|` | `landscapeRight` |
| `|x| < 1.5 && |y| < 1.5` | Giữ orientation cũ (máy đang nằm ngửa/úp) |

Stream được hủy trong `dispose()` để tránh leak.

## Lưu ý quan trọng

### Permissions
- **iOS** ([Info.plist](../../../../ios/Runner/Info.plist)):
  - `NSCameraUsageDescription`
  - `NSMicrophoneUsageDescription` *(vì `enableAudio: true`)*
  - `NSMotionUsageDescription` *(sensors_plus trên iOS 17+)*
  - `NSPhotoLibraryAddUsageDescription` *(nếu lưu Photos)*
- **Android** ([AndroidManifest.xml](../../../../android/app/src/main/AndroidManifest.xml)):
  - `android.permission.CAMERA`
  - `android.permission.RECORD_AUDIO`
  - `<uses-feature android:name="android.hardware.camera"/>`

App cần xin quyền **trước** khi mở `CameraScreen` (dùng `permission_handler`).

### Khác
- **Dark UI:** Nền `Colors.black` cố định cho UX chuẩn camera.
- **Tài nguyên:** Widget tự quản lý vòng đời camera + accelerometer subscription, màn hình gọi không cần xử lý thêm.
- **Web:** Dùng `ResolutionPreset.max`; native dùng `ResolutionPreset.high`.
- **Deprecation:** Tránh dùng `qr_code_scanner` chung màn — không tương thích AGP 8+. Module này không phụ thuộc QR.
