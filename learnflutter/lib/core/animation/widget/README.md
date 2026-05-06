# Thư viện Widget Animation

Thư mục này chứa các Widget chuyên biệt để tạo hiệu ứng chuyển động trong dự án. Các widget này được thiết kế để có thể nhúng trực tiếp vào UI với cấu hình tối thiểu.

## Danh sách các Widget

| Tên Widget | File | Mô tả |
|------------|------|-------|
| `IconAnimationWidget` | `icon_animation_widget.dart` | Hiệu ứng xoay/tim đập cho Icon. |
| `ListViewAnimated` | `list_view_animation.dart` | Danh sách với hiệu ứng trượt vào từng item. |
| `PositionedTransitionWidget` | `position_animation.dart` | Di chuyển Widget trong Stack. |
| `ReloadButtonWidget` | `reload_button_widget.dart` | Nút bấm có trạng thái Loading xoay tròn. |
| `RippleAnimationWidget` | `ripple_animation_widget.dart` | Hiệu ứng vòng tròn lan tỏa. |
| `ScaleTranslateBuilder` | `scale_translate.dart` | Animation theo tỉ lệ cuộn của PageView. |

## Quy tắc xây dựng Widget Animation mới

1. **Sử dụng Mixin:** Luôn dùng `SingleTickerProviderStateMixin` (cho 1 Controller) hoặc `TickerProviderStateMixin` (cho nhiều Controller).
2. **Dispose:** Tuyệt đối không quên gọi `.dispose()` cho mọi `AnimationController`.
3. **Hiệu năng:** Sử dụng `AnimatedBuilder` hoặc `Listener` thay vì gọi `setState` trực tiếp ở cấp cao nếu không cần thiết.
4. **Cấu hình:** Để người dùng có thể tùy chỉnh `duration`, `curve`, `color` qua constructor.
5. **Naming:** Đặt tên file theo kiểu `snake_case` và class theo kiểu `PascalCase`. Kết thúc bằng hậu tố `Widget` (ví dụ: `MyCoolAnimationWidget`).

## Bảo trì & Nâng cấp
- Định kỳ kiểm tra việc rò rỉ bộ nhớ (Memory leaks) bằng Flutter DevTools.
- Nâng cấp các widget sử dụng `AnimationController` thủ công sang `TweenAnimationBuilder` (Implicit) nếu logic cho phép để đơn giản hóa code.
