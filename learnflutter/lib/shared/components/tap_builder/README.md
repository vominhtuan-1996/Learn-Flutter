# Tap Builder Components

Hai wrapper trên `TapBuilder` / `AnimatedTapBuilder` (vendored trong `widgets/lib/tap_builder/`) — cung cấp 2 dạng nút tương tác có hiệu ứng vật lý sẵn sàng dùng.

```
lib/shared/components/tap_builder/
├── tap_animated_button_builder.dart     -> AnimatedTapButtonBuilder
├── tap_delayed_pressed_button_builder.dart -> TapDelayedPressedButton
├── tap_builder_test_screen.dart         -> TapBuilderTestScreen
└── README.md
```

---

## 1. `AnimatedTapButtonBuilder`

Nút có hiệu ứng nghiêng 3D theo vị trí con trỏ + scale khi pressed + glow shadow + haptic feedback (`mediumImpact`). Dùng cho **CTA chính** muốn cảm giác "premium".

```dart
import 'package:learnflutter/shared/components/tap_builder/tap_animated_button_builder.dart';

AnimatedTapButtonBuilder(
  onTap: () => print('tapped'),
  onLongPress: () => print('long press'),
  background: Colors.indigo,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  child: const Text('Mua ngay', style: TextStyle(color: Colors.white)),
)
```

| Tham số | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `child` | `Widget?` | `null` | Nội dung bên trong |
| `onTap` | `VoidCallback?` | `null` | Callback tap (kèm haptic) |
| `onLongPress` | `VoidCallback?` | `null` | Callback long-press |
| `padding` | `EdgeInsetsGeometry?` | `DeviceDimension.padding / 2` | Padding nội dung |
| `background` | `Color?` | `colorScheme.primaryContainer` | Màu nền |
| `isEnabled` | `bool` | `true` | `false` → chặn input (AbsorbPointer) |

### Hành vi
- **Hover/drag**: nghiêng theo trục cursor (rotateX/Y ±0.2 rad).
- **Pressed**: scale `0.94`, opacity `0.6`, đảo hướng nghiêng (như đang ấn xuống).
- **Glow**: blur shadow tại điểm tiếp xúc khi pressed.

---

## 2. `TapDelayedPressedButton`

Nút giữ trạng thái `pressed` ít nhất `minPressedDuration` (mặc định 500ms) trước khi nhả — tránh nhấp nháy với tap quá nhanh, hiển thị clearly đã nhận touch. Dùng cho **confirm action** (xoá, gửi…).

```dart
import 'package:learnflutter/shared/components/tap_builder/tap_delayed_pressed_button_builder.dart';

TapDelayedPressedButton(
  onPressed: () => sendOtp(),
  minPressedDuration: const Duration(milliseconds: 800),
  pressedColor: Colors.green,
  inactiveColor: Colors.grey.shade400,
  child: const Text('Gửi OTP', style: TextStyle(color: Colors.white)),
)
```

| Tham số | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `child` | `Widget?` | `null` | Nội dung |
| `onPressed` | `VoidCallback?` | `null` | Callback khi pressed kết thúc |
| `minPressedDuration` | `Duration` | `500ms` | Thời gian tối thiểu giữ pressed |
| `padding` | `EdgeInsetsGeometry?` | `14h × 28v` | Padding |
| `pressedColor` | `Color` | `#0AAF97` | Màu khi pressed |
| `inactiveColor` | `Color` | `Colors.grey` | Màu mặc định |
| `isEnabled` | `bool` | `true` | `false` → chặn input |

### Bảng màu theo `TapState`
| State | Màu |
|---|---|
| `disabled` | `Colors.grey` (hardcode) |
| `hover` | `#0AAF97` (hardcode) |
| `inactive` | `inactiveColor` |
| `pressed` | `pressedColor` |

---

## 3. So sánh nhanh

| | `AnimatedTapButtonBuilder` | `TapDelayedPressedButton` |
|---|---|---|
| Cảm giác | 3D, glow, haptic | Phẳng, có "delay xác nhận" |
| Phù hợp | CTA, card tương tác | Confirm, gửi form, OTP |
| Cost | Cao hơn (3D matrix + shadow) | Nhẹ |
| Customization | Background + padding | Color theo state + duration |

---

## 4. Demo trực quan

Mở `TapBuilderTestScreen` ([tap_builder_test_screen.dart](tap_builder_test_screen.dart)) — màn hình so sánh side-by-side: bộ ví dụ về `AnimatedTapButtonBuilder` (default, custom color, long press, disabled) và `TapDelayedPressedButton` (duration ngắn/dài, custom color, disabled). Mọi click đều show snackbar để xác nhận callback chạy.
