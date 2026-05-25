# QR Code Service

Service chứa các widget overlay dùng cho màn hình quét QR/CCCD và tiện ích capture/render QR.

```
lib/core/services/qr_code/
├── overlay/
│   ├── qr_scan_border.dart              -> QRBorderOverlay
│   ├── qr_scan_laser_overlay.dart       -> QRScanLaserOverlay
│   ├── qr_scan_blinking_border_overlay.dart -> BlinkingBorderOverlay
│   ├── qr_scan_rotating_border_overlay.dart -> RotatingBorderOverlay
│   ├── qr_scan_zigzag_overlay.dart      -> ZigZagLaserOverlay
│   └── cccd_scan_overlay.dart           -> CccdScanOverlay
├── widget/
│   └── qr_capture_widget.dart           -> QrCaptureWidget
├── qr_code_screen.dart                  -> QRViewExample (màn hình quét QR thực tế)
└── qr_overlays_demo_screen.dart         -> QrOverlaysDemoScreen (preview các overlay)
```

Tất cả overlay đều là widget thuần — chỉ vẽ trên `CustomPaint`, không phụ thuộc camera. Bạn có thể stack lên trên bất kỳ `QRView`, `CameraPreview`, hay `Container` nào.

---

## 1. `QRBorderOverlay`

Khung quét QR với 4 góc hình "L" — phong cách quét QR truyền thống.

```dart
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_border.dart';

QRBorderOverlay(
  scanAreaSize: 250,         // cạnh vùng quét (vuông)
  borderLength: 30,          // độ dài của mỗi đoạn góc L
  strokeWidth: 6,            // bề rộng nét
  borderColor: Colors.green, // màu khung
)
```

| Tham số | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `scanAreaSize` | `double` | `250` | Cạnh vùng quét (hình vuông), đo bằng px |
| `borderLength` | `double` | `30` | Độ dài mỗi đoạn của góc chữ L |
| `strokeWidth` | `double` | `6` | Bề rộng nét vẽ |
| `borderColor` | `Color` | `Colors.greenAccent` | Màu của góc |

Widget tự lấy `MediaQuery.size` qua extension nên cứ `Positioned.fill` là đủ.

---

## 2. `QRScanLaserOverlay`

Tia laser ngang chạy từ trên xuống dưới (loop), kèm shadow gradient phía trên — gợi cảm giác đang scan.

```dart
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_laser_overlay.dart';

final laserKey = GlobalKey<QRScanLaserOverlayState>();

QRScanLaserOverlay(
  key: laserKey,
  size: Size(280, 280),
)

// Điều khiển:
laserKey.currentState?.stop();   // dừng laser (khi scan thành công)
laserKey.currentState?.resume(); // chạy lại
```

| Tham số | Kiểu | Bắt buộc | Ý nghĩa |
|---|---|---|---|
| `size` | `Size` | ✅ | Vùng vẽ của tia laser |

Tốc độ mặc định: 3s/lượt. Màu hiện đang hardcode `Colors.blue` — sửa trực tiếp trong `_LaserPainter` nếu cần.

---

## 3. `BlinkingBorderOverlay`

Khung viền nhấp nháy (fade opacity 0.2 ↔ 1.0, chu kỳ 1s).

```dart
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_blinking_border_overlay.dart';

BlinkingBorderOverlay(
  width: 280,
  height: 280,
)
```

| Tham số | Kiểu | Bắt buộc | Ý nghĩa |
|---|---|---|---|
| `width` | `double` | ✅ | Bề rộng khung |
| `height` | `double` | ✅ | Chiều cao khung |

Dùng khi muốn báo hiệu "chưa nhận diện được" hoặc "đang chờ".

---

## 4. `RotatingBorderOverlay`

Viền xoay liên tục quanh vùng quét (4s/vòng). Tạo cảm giác đang xử lý.

```dart
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_rotating_border_overlay.dart';

RotatingBorderOverlay(
  width: 280,
  height: 280,
)
```

| Tham số | Kiểu | Bắt buộc | Ý nghĩa |
|---|---|---|---|
| `width` | `double` | ✅ | Bề rộng vùng vẽ |
| `height` | `double` | ✅ | Chiều cao vùng vẽ |

---

## 5. `ZigZagLaserOverlay`

Đường laser zigzag chạy dọc — phong cách "đang phân tích nâng cao".

```dart
import 'package:learnflutter/core/services/qr_code/overlay/qr_scan_zigzag_overlay.dart';

ZigZagLaserOverlay(
  width: 280,
  height: 280,
)
```

| Tham số | Kiểu | Bắt buộc | Ý nghĩa |
|---|---|---|---|
| `width` | `double` | ✅ | Bề rộng vùng vẽ |
| `height` | `double` | ✅ | Chiều cao vùng vẽ |

Tốc độ mặc định: 2s/lượt.

---

## 6. `CccdScanOverlay`

Khung trắng bo tròn tỉ lệ thẻ CCCD/CMND (85.6mm × 54mm ≈ 1.58:1).

```dart
import 'package:learnflutter/core/services/qr_code/overlay/cccd_scan_overlay.dart';

const CccdScanOverlay()
```

Không nhận tham số — tự fit theo kích thước `Stack`/`Positioned.fill` bao ngoài. Dùng cho luồng chụp CCCD.

---

## 7. `QrCaptureWidget` (widget tiện ích)

Render QR (thư viện `pretty_qr_code`) trong một `RepaintBoundary`, hỗ trợ capture thành PNG và lưu vào thư viện ảnh.

```dart
import 'package:learnflutter/core/services/qr_code/widget/qr_capture_widget.dart';

QrCaptureWidget(
  qrData: 'https://example.com',
  onDone: () => print('Đã lưu QR vào gallery'),
)
```

| Tham số | Kiểu | Bắt buộc | Ý nghĩa |
|---|---|---|---|
| `qrData` | `String` | ✅ | Nội dung mã QR |
| `onDone` | `Function?` | ❌ | Callback gọi sau khi capture/lưu xong |

Cần quyền `permission_handler` cho gallery (đã xử lý trong widget).

---

## Pattern dùng chung trên màn hình quét

```dart
Stack(
  children: [
    QRView(key: qrKey, onQRViewCreated: _onCreated, overlay: null),

    // Khung góc L
    const Positioned.fill(child: QRBorderOverlay(scanAreaSize: 280)),

    // Tia laser ở giữa
    Center(
      child: QRScanLaserOverlay(
        key: laserKey,
        size: const Size(280, 280),
      ),
    ),
  ],
);
```

Có thể combo nhiều overlay (border + laser, hoặc rotating + blinking…) — chúng độc lập, không xung đột.

---

## Preview tất cả overlay

Mở `QrOverlaysDemoScreen` (`lib/core/services/qr_code/qr_overlays_demo_screen.dart`) — màn hình demo hiển thị từng overlay trên nền tối giả lập camera, không cần quyền camera.
