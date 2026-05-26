# Engine Pagination Suite (Core Engine)

Bộ thành phần **Pagination / Stepper (Wizard)** cao cấp đặt tại tầng Core, được nâng cấp vượt trội từ module `shared/widgets/pagination` cũ.

---

## ✨ Điểm Cải tiến Premium

1.  **Vẽ Vector Động 100% (No Image Assets Dependency):**
    *   Các vòng tròn chỉ báo bước và đường nối nét đứt (Dotted Line) được vẽ trực tiếp bằng Flutter Vector Icons & `CustomPainter` động.
    *   **Không** còn phụ thuộc vào các file ảnh PNG tĩnh như trước đây.
    *   Độ phân giải sắc nét hoàn hảo trên mọi kích thước màn hình.
2.  **Hỗ trợ Dark Mode Động:**
    *   Màu sắc tự động chuyển đổi mượt mà giữa theme tối và sáng.
    *   Nút bấm sử dụng Token màu HSL Slate và Neon Blue rực rỡ, chuyên nghiệp.
3.  **Tương thích Ngược Hoàn hảo:**
    *   Các tham số, API callback (`onNextStep`, `onPreviousStep`, `onCompleteStep`, v.v.) và kiểu dữ liệu được giữ nguyên đồng bộ, giúp nâng cấp an toàn tuyệt đối.

---

## 🚀 Hướng dẫn Sử dụng nhanh

### 1. Import Barrel File duy nhất:
```dart
import 'package:learnflutter/core/engine_pagination/engine_pagination.dart';
```

### 2. Khai báo Widget Stepper:
```dart
AppPaginationWidget(
  numbStep: 3,
  tabType: "0", // "0": Chế độ bình thường, "1": Chế độ xem trước bảo trì
  hasCompleteStep: true,
  content: Expanded(
    child: Center(child: Text("Nội dung của từng bước hiển thị ở đây")),
  ),
  onNextStep: (current, next) async {
    debugPrint("👉 Sang bước kế tiếp từ $current sang $next");
    return true; // Trả về true để cho phép chuyển bước
  },
  onPreviousStep: (prevStep) async {
    debugPrint("👈 Quay lại bước $prevStep");
    return true;
  },
  onCompleteStep: (finalStep) async {
    debugPrint("🎉 Hoàn tất biểu mẫu tại step $finalStep");
    return true;
  },
)
```

---

## 🛠️ Cấu trúc Module

*   `models/pagination_model.dart`: Khai báo trạng thái của Step (`AppStepState`, `AppPaginationModel`).
*   `controller/`: Chứa BLoC Cubit & State điều phối tiến trình cuộn mượt mà.
*   `widgets/`:
    *   `pagination_base_widget.dart`: Layout chính của Wizard Stepper.
    *   `pagination_item_widget.dart`: Vòng tròn hiển thị trạng thái của từng Step.
    *   `pagination_bottom_bar_widget.dart`: Thanh điều hướng Next/Back/Complete dưới đáy.
