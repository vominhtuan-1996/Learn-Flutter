# Hướng dẫn sử dụng Camera Module

Module Camera trong dự án được thiết kế để cung cấp khả năng chụp ảnh và quay video linh hoạt, có thể tái sử dụng ở bất kỳ đâu trong ứng dụng.

## Cấu trúc thư mục
- `lib/core/camera/camera_screen.dart`: Widget chính hiển thị giao diện camera.
- `lib/core/camera/model/camera_mode.dart`: Enum định nghĩa các chế độ (`photo`, `video`).

## Cách sử dụng

### 1. Khởi tạo cơ bản
Để mở màn hình camera, bạn chỉ cần gọi `CameraScreen` thông qua `Navigator`:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CameraScreen(
      initialMode: CameraMode.photo, // Chế độ mặc định khi mở
      onPhotoCaptured: (XFile photo) {
        print('Đã chụp ảnh: ${photo.path}');
        // Xử lý file ảnh ở đây
      },
      onVideoRecorded: (XFile video) {
        print('Đã quay video: ${video.path}');
        // Xử lý file video ở đây
      },
    ),
  ),
);
```

### 2. Các tham số (Parameters)
| Tham số | Kiểu dữ liệu | Mô tả |
|---------|--------------|-------|
| `initialMode` | `CameraMode` | Chế độ mặc định khi khởi động (`photo` hoặc `video`). Mặc định là `photo`. |
| `onPhotoCaptured` | `Function(XFile)?` | Callback được gọi ngay sau khi chụp ảnh thành công. |
| `onVideoRecorded` | `Function(XFile)?` | Callback được gọi ngay sau khi dừng quay video thành công. |

## Các tính năng chính
- **Chụp ảnh:** Hỗ trợ xem lại ảnh vừa chụp ở góc dưới màn hình.
- **Quay Video:** Hỗ trợ Pause/Resume khi đang quay, hiển thị đồng hồ thời gian thực.
- **Zoom:** Hỗ trợ pinch-to-zoom (2 ngón tay) hoặc sử dụng thanh slider.
- **Flash:** Chế độ xoay vòng: Auto -> On -> Off.
- **Flip:** Chuyển đổi linh hoạt giữa camera trước và sau.
- **Tối ưu vòng đời:** Tự động giải phóng camera khi ứng dụng vào nền (background) để bảo vệ phần cứng.

## Lưu ý quan trọng
- **Quyền truy cập:** Đảm bảo ứng dụng đã xin quyền `Camera` và `Microphone` (đối với video) trước khi gọi màn hình này.
- **Dark Mode:** Giao diện camera luôn sử dụng nền đen (`Colors.black`) để đảm bảo trải nghiệm người dùng tối ưu khi chụp ảnh/quay phim.
- **Tài nguyên:** Widget tự động quản lý vòng đời camera, không cần xử lý thêm ở màn hình gọi.
