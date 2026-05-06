# Hướng dẫn sử dụng module Animation

Module này cung cấp các Widget và Helper hỗ trợ tạo hiệu ứng chuyển động (Animation) đẹp mắt và mượt mà cho ứng dụng.

## Cấu trúc thư mục
- `lib/core/animation/animation_helper.dart`: Lớp Helper cung cấp các ví dụ mẫu và hàm khởi tạo nhanh các animation.
- `lib/core/animation/animation_screen.dart`: Màn hình demo tổng hợp các loại transition.
- `lib/core/animation/widget/`: Thư mục chứa các Widget animation riêng biệt (Icon, ListView, Ripple, v.v.)

## Các Widget Animation tiêu biểu

### 1. IconAnimationWidget
Hỗ trợ tạo hiệu ứng xoay (Rotate) hoặc nhịp tim (Heartbeat) cho bất kỳ IconData nào.
```dart
const IconAnimationWidget(
  isRotate: true,
  icon: Icons.notifications_active,
)
```

### 2. RippleAnimationWidget
Hiệu ứng vòng tròn lan tỏa thường dùng cho các nút bấm quan trọng hoặc trạng thái chờ.

### 3. ListViewAnimated
Hỗ trợ hiển thị danh sách với hiệu ứng trượt vào từng phần tử (Slide-in) cực kỳ chuyên nghiệp.

## Các quy tắc quan trọng (Maintenance Rules)

1. **Quản lý Vòng đời (Lifecycle):** 
   - Luôn gọi `_animationController.dispose()` trong hàm `dispose()` của StatefulWidget để tránh rò rỉ Ticker.
2. **Tối ưu hiệu năng:** 
   - Sử dụng `RepaintBoundary` cho các animation chạy liên tục để giảm tải cho việc vẽ lại giao diện.
3. **Implicit vs Explicit:** 
   - Ưu tiên dùng `AnimatedContainer` cho thay đổi đơn giản. Chỉ dùng `AnimationController` khi cần điều khiển phức tạp (lặp lại, đảo ngược).
4. **Motion Consistency:** 
   - Luôn sử dụng hằng số Curve và Duration từ theme chung để đảm bảo cảm giác chuyển động nhất quán.

## Định hướng phát triển
- Xây dựng thư viện các Page Transition mẫu (Slide, Fade, Scale).
- Hỗ trợ "Reduce Motion" để tự động tắt animation trên các thiết bị bật chế độ tiết kiệm hoặc hỗ trợ người khuyết tật.
