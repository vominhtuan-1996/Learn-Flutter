# 📦 Engine Dialog Suite — Hướng dẫn sử dụng chi tiết

**Engine Dialog Suite** là bộ thư viện giao diện chuẩn hóa và premium dùng để điều phối tất cả các loại thông báo, hộp thoại (Dialogs), thanh trạng thái (Snackbars), quy trình xử lý đa bước (Process Steppers) và truyền tải dữ liệu nhiều tệp (Multi-file Transfers) trong toàn dự án.

Mọi thành phần trong Suite này đều được thiết kế theo hướng **độc lập (core-level)**, **cấu hình động (config-driven)**, và **không phụ thuộc** vào bất kỳ Bloc/Cubit cụ thể nào của các feature bên ngoài.

---

## 📂 Cấu trúc Module

Tất cả các thành phần được đóng gói bên trong thư mục `lib/core/engine_dialog/` và xuất khẩu (barrel export) qua một đầu mối duy nhất:

```dart
import 'package:learnflutter/core/engine_dialog/engine_dialog.dart';
```

Sơ đồ thư mục:
```text
lib/core/engine_dialog/
├── README.md                       # Tài liệu hướng dẫn sử dụng này
├── engine_dialog.dart              # Đầu mối Barrel Export duy nhất
├── app_dialog_engine.dart          # Điều phối Dialogs (Scale + Fade)
├── app_snackbar_engine.dart        # Điều phối Snackbars (Top & Bottom)
├── models/
│   └── dialog_config.dart          # Enums, Configs và Color Tokens
└── widgets/
    ├── dialog_base_widget.dart     # Giao diện nền tảng cho Dialogs
    ├── snackbar_base_widget.dart   # Giao diện nền tảng cho Snackbars
    ├── process_stepper_widget.dart # Quy trình xử lý nhiều bước động
    └── multi_transfer_dialog.dart  # Tiến trình tải/upload nhiều file
```

---

## 🚀 Hướng dẫn chi tiết API & Code mẫu

### 1. 🗂 Dialogs tiêu chuẩn (Scale + Fade Animation)
Sử dụng `AppDialogEngine` để hiển thị các hộp thoại thông thường. Hiệu ứng hiển thị mặc định là phóng to nhẹ kết hợp mờ dần (`ScaleTransition` + `FadeTransition` với `Curves.easeOutBack`) cực kỳ mượt mà.

#### 🔹 Dialog Thông thường (Info, Error, Success, Warning)
```dart
// 1. Dialog thông báo nhanh
AppDialogEngine.showInfo(
  context,
  title: 'Cập nhật hệ thống',
  message: 'Phiên bản mới sẽ tự động áp dụng sau khi bạn khởi động lại ứng dụng.',
);

// 2. Dialog lỗi (Màu đỏ chủ đạo)
AppDialogEngine.showError(
  context,
  title: 'Kết nối thất bại',
  message: 'Máy chủ không phản hồi. Vui lòng kiểm tra lại kết nối mạng của bạn.',
);

// 3. Dialog thành công (Màu xanh lá chủ đạo + nút custom)
AppDialogEngine.showSuccess(
  context,
  title: 'Thanh toán thành công!',
  message: 'Đơn hàng của bạn đã được xác nhận.',
  confirmText: 'Xem lịch sử',
  onConfirm: () => Navigator.pushNamed(context, '/history'),
);

// 4. Dialog cảnh báo (Màu cam chủ đạo + 2 nút xác nhận/hủy)
AppDialogEngine.showWarning(
  context,
  title: 'Xóa vĩnh viễn',
  message: 'Bạn có chắc chắn muốn xóa thư mục này? Hành động này không thể hoàn tác.',
  confirmText: 'Xóa ngay',
  cancelText: 'Hủy bỏ',
  showCancelButton: true,
  onConfirm: () => executeDelete(),
  onCancel: () => print('Đã hủy xóa'),
);
```

#### 🔹 Dialog Tùy chỉnh hoàn toàn (Custom Content)
Bạn có thể nhét bất kỳ Widget nào vào làm nội dung của Dialog thông qua thuộc tính `contentWidget`:
```dart
AppDialogEngine.show(
  context,
  config: AppDialogConfig(
    title: 'Xác nhận mã PIN',
    message: '',
    type: AppDialogType.info,
    confirmText: 'Xác thực',
    contentWidget: PinCodeTextField(
      length: 6,
      onChanged: (pin) => updatePin(pin),
    ),
  ),
);
```

---

### 2. 🍞 Snackbars & Advanced Actions (Bottom & Top-Overlay hỗ trợ cử chỉ & tương tác nâng cao)
Hệ thống hỗ trợ 2 vị trí hiển thị Snackbar:
*   `AppSnackbarPosition.bottom` (Mặc định): Sử dụng `ScaffoldMessenger` gốc của Flutter.
*   `AppSnackbarPosition.top`: Tải thông báo dạng trượt từ trên đầu màn hình sử dụng `TopOverlayBanner`.

#### 💥 Các cử chỉ & Action nâng cao (Production-ready UX):
1.  **Swipe up to Dismiss (Top Overlay):** Người dùng có thể vuốt ngược lên để tắt nhanh banner thay vì đợi hết giờ hoặc bấm nút X.
2.  **Hold to Pause, Release to Resume (Touch & Hold):** Khi người dùng nhấn giữ (Touch/Hold) vào Snackbar, hệ thống tự động tạm ngắt bộ đếm giờ tự tắt. Khi nhấc tay ra, bộ đếm giờ tiếp tục chạy thêm 2 giây để đảm bảo người dùng có đủ thời gian đọc thông tin quan trọng.
3.  **Multi-Action Buttons:** Cho phép truyền danh sách nhiều nút bấm hành động (`additionalActions`) bên cạnh nút chính.
4.  **Custom Interactive Content (`contentWidget`):** Cho phép ghi đè hoàn toàn nội dung text mặc định để hiển thị các widget tương tác phức tạp (như Linear Progress running ngầm, avatar người gửi tin nhắn, v.v.)
5.  **Custom Leading / Trailing:** Cho phép tuỳ biến hoàn toàn phần Icon đầu dòng và bộ action cuối dòng.

#### 📝 Ví dụ code mẫu:

##### 🔹 Multi-Action (Nhiều nút tương tác như Kết bạn: Đồng ý / Bỏ qua)
```dart
AppSnackbarEngine.showInfo(
  context,
  message: 'Nguyễn Văn A gửi yêu cầu kết bạn.',
  position: AppSnackbarPosition.bottom,
  duration: const Duration(seconds: 8),
  actionLabel: 'Đồng ý',
  onAction: () => acceptFriendRequest(),
  additionalActions: [
    GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ignoreFriendRequest();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: const Text(
          'Bỏ qua',
          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  ],
);
```

##### 🔹 Custom Content Widget (Tiến trình tải lên chạy ngầm kèm CircularProgress Indicator)
```dart
AppSnackbarEngine.showSuccess(
  context,
  message: '', // Để rỗng vì dùng contentWidget
  position: AppSnackbarPosition.bottom,
  duration: const Duration(seconds: 5),
  leading: const SizedBox(
    width: 28,
    height: 28,
    child: CircularProgressIndicator(
      strokeWidth: 2.5,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ),
  ),
  contentWidget: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text(
        'Đang tải lên báo cáo doanh thu...',
        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: const LinearProgressIndicator(
          value: 0.65,
          minHeight: 4,
          backgroundColor: Colors.white24,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    ],
  ),
);
```

> [!TIP]
> **Dọn dẹp hàng đợi (Queue):** Khi chuyển trang hoặc rời khỏi các màn hình nghiệp vụ quan trọng, bạn nên gọi `AppSnackbarEngine.clearTopQueue()` để giải phóng toàn bộ Snackbars đang chờ trong hàng đợi Overlay ở phía trên.

---

### 3. ⚙️ Process Stepper (Tiến trình xử lý đa bước dạng Config)
Dùng khi bạn có một quy trình nghiệp vụ gồm nhiều bước bất tuần tự hoặc tuần tự cần gọi API (ví dụ: Tạo phiếu PMS -> Tạo phiếu thi công Inside -> Hoàn tất). 

Toàn bộ logic được định nghĩa qua danh sách cấu hình `AppProcessStepConfig`.

```dart
AppDialogEngine.showStepper(
  context,
  title: 'Khởi tạo dịch vụ Cloud',
  steps: [
    AppProcessStepConfig(
      title: 'Khởi tạo máy chủ Kubernetes',
      processingSubtitle: 'Đang yêu cầu cấp phát tài nguyên server...',
      action: () async {
        // Thực thi tác vụ bất đồng bộ (Gọi API thật)
        return await api.createCluster();
      },
      subtitleBuilder: (result) => 'Cụm máy chủ ID: ${result['clusterId']}',
    ),
    AppProcessStepConfig(
      title: 'Đồng bộ cơ sở dữ liệu Postgres',
      processingSubtitle: 'Đang di chuyển schema & dữ liệu...',
      action: () async {
        return await api.syncDatabase();
      },
      subtitleBuilder: (result) => 'Đã đồng bộ ${result['records']} bản ghi',
    ),
  ],
  summaryTitleBuilder: (results) => '🚀 Hệ thống đã sẵn sàng hoạt động!',
  summaryNotesBuilder: (results) {
    final k8s = results[0];
    final db = results[1];
    return [
      if (k8s != null) 'Mã cụm: ${k8s['clusterId']}',
      if (db != null) 'Bản ghi DB: ${db['records']}',
    ];
  },
);
```

*   **Tính năng tự động khôi phục (Resume):** Bạn có thể truyền `initialStatus: AppProcessStepStatus.completed` và `initialResult` cho một bước cụ thể để bỏ qua bước đó nếu dữ liệu đã tồn tại từ trước (tải lại trang).
*   **Hỗ trợ Retry tự động:** Khi một bước trong stepper bị lỗi, hệ thống sẽ dừng lại hiển thị thông báo đỏ và cung cấp nút bấm **Thử lại (Retry)** để người dùng thực thi lại riêng bước bị lỗi đó mà không phải chạy lại từ đầu quy trình.

---

### 4. 📥/📤 Multi-file Transfer (Tải xuống / Tải lên nhiều tệp)
Dialog chuyên dụng phục vụ việc truyền tải đồng thời nhiều file cùng lúc. Hỗ trợ hiển thị thanh tiến trình tổng quan và thanh tiến trình chi tiết của từng tệp tin kèm dung lượng theo MB.

```dart
AppDialogEngine.showMultiDownload(
  context,
  title: 'Tải xuống gói tài nguyên cập nhật',
  files: [
    AppTransferFileConfig(
      name: 'Hình ảnh assets & icons hệ thống.zip',
      sizeInMB: 12.4,
      transferAction: (onProgress) async {
        // Truyền luồng tiến trình từ API thật (từ 0.0 -> 1.0)
        double current = 0.0;
        while (current < 1.0) {
          await Future.delayed(const Duration(milliseconds: 100));
          current += 0.1;
          onProgress(current); // Cập nhật thanh progress của file này
        }
      },
    ),
    AppTransferFileConfig(
      name: 'Tài liệu hướng dẫn sử dụng PDF.pdf',
      sizeInMB: 28.1,
      transferAction: (onProgress) async {
        // Thực thi tác vụ download thật
      },
    ),
  ],
  onCompleted: () => print('Đã tải xuống toàn bộ tệp tin thành công!'),
  onCanceled: () => print('Người dùng đã hủy quá trình tải!'),
);
```

*   Đối với tải lên, chỉ cần thay bằng phương thức gọi: `AppDialogEngine.showMultiUpload(context, files: [...])`.
*   Dialog tự động đổi màu sắc nhận diện: **Xanh dương (Blue)** cho Download và **Tím (Violet)** cho Upload để đảm bảo tính đồng nhất hệ thống thông tin.
*   Tự động khóa tương tác nền để tránh gián đoạn, chỉ hiển thị nút **Hoàn tất** phóng to mượt mà sau khi tất cả các tệp truyền dữ liệu thành công.

---

## 🎨 Token màu sắc chuẩn hóa (DialogColorToken)

| Trạng thái | Nền (Background) | Viền & Icon (Border/Icon) | Nút bấm (Button) |
|---|---|---|---|
| **Info** | `#EFF6FF` (Xanh dương nhẹ) | `#3B82F6` (Xanh dương) | `#2563EB` |
| **Error** | `#FFF1F2` (Hồng/Đỏ nhẹ) | `#EF4444` (Đỏ) | `#DC2626` |
| **Success** | `#F0FDF4` (Xanh lá nhẹ) | `#22C55E` (Xanh lá) | `#16A34A` |
| **Warning** | `#FFFBEB` (Vàng/Cam nhẹ) | `#F59E0B` (Cam) | `#D97706` |

---

## 🛠 Hướng dẫn mở rộng hệ thống

Nếu bạn muốn tạo thêm một dạng Dialog mới tích hợp vào suite này:
1. Tạo widget giao diện của Dialog đó đặt trong thư mục `lib/core/engine_dialog/widgets/`.
2. Khai báo shortcut method trong class `AppDialogEngine` tại file [app_dialog_engine.dart](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/core/engine_dialog/app_dialog_engine.dart).
3. Đăng ký export widget mới trong barrel file [engine_dialog.dart](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/core/engine_dialog/engine_dialog.dart).
4. *(Tùy chọn)* Thêm các kịch bản test và nút bấm tương ứng trong file demo [engine_dialog_demo_screen.dart](file:///Users/tuanios_su12/learn_flutter/learnflutter/lib/features/test_screen/engine_dialog_demo_screen.dart) để kiểm thử trực quan.
