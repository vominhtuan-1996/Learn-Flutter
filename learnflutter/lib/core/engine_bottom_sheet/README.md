# 📥 Bottom Sheet Engine Suite — Hướng dẫn sử dụng chi tiết

**Bottom Sheet Engine Suite** là cấu phần kiến trúc độc lập nằm ở tầng `core` phục vụ việc hiển thị tất cả các hộp thoại trượt lên từ dưới đáy màn hình (Bottom Sheets) trong toàn bộ ứng dụng. 

Thiết kế này hoàn toàn đồng bộ với **Engine Dialog Suite**, áp dụng cơ chế **cấu hình động (config-driven)**, hỗ trợ **Dark Mode** và tối ưu giao diện hiển thị trên **Tablet / iPad / Màn hình Landscape**.

---

## 📂 Cấu trúc Module

Module được đóng gói bên trong thư mục `lib/core/engine_bottom_sheet/` và xuất khẩu (barrel export) qua đầu mối duy nhất:

```dart
import 'package:learnflutter/core/engine_bottom_sheet/engine_bottom_sheet.dart';
```

Sơ đồ thư mục:
```text
lib/core/engine_bottom_sheet/
├── README.md                           # Tài liệu hướng dẫn sử dụng này
├── engine_bottom_sheet.dart            # Đầu mối Barrel Export duy nhất
├── app_bottom_sheet_engine.dart        # Controller static điều phối hiển thị
├── models/
│   └── bottom_sheet_config.dart        # Cấu hình items, buttons & options
└── widgets/
    ├── bottom_sheet_base_widget.dart   # Khung chứa chuẩn (Drag handle, Title, Footer)
    └── bottom_sheet_action_list.dart   # Component render danh sách tùy chọn dòng
```

---

## 🚀 Các kịch bản sử dụng & Ví dụ code mẫu

### 1. 🗂 Confirmation Bottom Sheets (Xác nhận hành động)
Sử dụng các helper nhanh để trượt lên các hộp thoại xác nhận quan trọng (Info, Success, Error, Warning). Nút Xác nhận sẽ có màu sắc tương ứng theo type và nút Hủy nằm bên dưới.

```dart
// 1. Cảnh báo hành động nguy hiểm (Warning) - Ví dụ: Đăng xuất tài khoản
AppBottomSheetEngine.showWarning(
  context,
  title: 'Xác nhận Đăng xuất',
  subtitle: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản hiện tại? Mọi phiên làm việc trên các thiết bị khác vẫn được giữ nguyên.',
  confirmText: 'Đăng xuất ngay',
  cancelText: 'Hủy bỏ',
  onConfirm: () => debugPrint('🚪 Đăng xuất thành công!'),
);

// 2. Thông báo thành công (Success)
AppBottomSheetEngine.showSuccess(
  context,
  title: 'Thanh toán thành công',
  subtitle: 'Giao dịch của bạn đã được hệ thống phê duyệt. Hoá đơn VAT sẽ được gửi vào Email trong vòng 5 phút.',
  confirmText: 'Xem lịch sử',
  cancelText: 'Đóng lại',
  onConfirm: () => openHistoryPage(),
);
```

---

### 2. 👥 Action / Option Menu Sheets (Danh sách lựa chọn)
Dùng khi bạn muốn hiển thị một menu tuỳ chọn nhanh. Mỗi option được biểu diễn bởi `AppBottomSheetActionItem` (chứa icon, text, callback và cờ `isDestructive` cho hành động nguy hiểm).

```dart
AppBottomSheetEngine.showActionSheet(
  context,
  title: 'Quản lý Tài liệu',
  subtitle: 'Chọn một hành động bên dưới để áp dụng cho tệp "BaoCao_2026.pdf":',
  actions: [
    AppBottomSheetActionItem(
      label: 'Chia sẻ tài liệu',
      icon: Icons.share_rounded,
      onTap: () => debugPrint('🔗 Share document'),
    ),
    AppBottomSheetActionItem(
      label: 'Đổi tên tệp tin',
      icon: Icons.edit_rounded,
      onTap: () => debugPrint('📝 Rename document'),
    ),
    AppBottomSheetActionItem(
      label: 'Tải xuống máy',
      icon: Icons.download_rounded,
      onTap: () => debugPrint('📥 Download document'),
    ),
    AppBottomSheetActionItem(
      label: 'Xoá vĩnh viễn',
      icon: Icons.delete_forever_rounded,
      isDestructive: true, // Hiển thị màu đỏ cảnh báo phá huỷ
      onTap: () => debugPrint('🚨 Delete document permanently'),
    ),
  ],
);
```

---

### 3. ⏳ Custom Content Bottom Sheets (Widget tùy biến phức tạp)
Dùng khi bạn muốn hiển thị một giao diện nhập liệu hoặc danh sách chọn lọc phức tạp. Truyền Widget của bạn qua thuộc tính `contentWidget`.

```dart
AppBottomSheetEngine.showCustom(
  context,
  title: 'Bộ lọc sản phẩm',
  confirmText: 'Áp dụng bộ lọc',
  cancelText: 'Đặt lại',
  onConfirm: () => applyFilters(),
  contentWidget: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Khoảng giá:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      RangeSlider(
        values: const RangeValues(100, 500),
        min: 0,
        max: 1000,
        onChanged: (values) => updatePriceRange(values),
      ),
      const SizedBox(height: 12),
      const Text('Danh mục:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          FilterChip(label: const Text('Điện tử'), onSelected: (_) {}),
          FilterChip(label: const Text('Thời trang'), onSelected: (_) {}),
          FilterChip(label: const Text('Gia dụng'), onSelected: (_) {}),
        ],
      ),
    ],
  ),
);
```

---

## 💎 Các tính năng Premium mặc định của Suite

*   **Responsive Tablet & Landscape:** 
    Khi chạy trên iPad hoặc màn hình xoay ngang, Bottom Sheet sẽ tự động thu gọn chiều rộng tối đa (`maxWidth: 480`) và nằm cân đối ở chính giữa đáy màn hình, mang đến cảm giác gọn gàng thay vì kéo giãn toàn màn hình.
*   **Hỗ trợ Dark Mode:** 
    Giao diện tự động phân tích `Theme.of(context).brightness` để chuyển đổi nền màu Slate tối (`0xFF1E293B`) kết hợp text trắng tinh khiết, mang lại trải nghiệm tối tuyệt đẹp.
*   **Tránh bị bàn phím che (Keyboard Avoidance):**
    Bộ engine tự động cộng dồn `MediaQuery.of(context).viewInsets.bottom` vào padding đáy, đẩy Bottom Sheet lên trên một cách thông minh khi bàn phím ảo xuất hiện.
