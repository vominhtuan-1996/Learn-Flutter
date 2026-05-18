# Hướng dẫn sử dụng module Talker (Logging System)

Module này cung cấp hệ thống ghi log tập trung cho toàn bộ ứng dụng Flutter, sử dụng gói `talker_flutter`. Nó giúp việc debug và giám sát luồng hoạt động của app trở nên dễ dàng và trực quan hơn.

## Cấu trúc thư mục
- `lib/core/service/talker/app_talker.dart`: Lớp Singleton quản lý instance Talker và các cấu hình ghi log.

## Cách sử dụng

### 1. Ghi log cơ bản
Bạn có thể gọi `AppTalker.instance` từ bất kỳ đâu trong ứng dụng:

```dart
// Log thông tin thông thường
AppTalker.instance.info('Ứng dụng đã khởi động');

// Log cảnh báo
AppTalker.instance.warning('Kết nối mạng yếu');

// Log lỗi kèm theo Exception và StackTrace
try {
  // code gây lỗi
} catch (e, st) {
  AppTalker.instance.handle(e, st, 'Lỗi khi tải dữ liệu');
}
```

### 2. Xem log trực tiếp trên ứng dụng
Module này tương thích hoàn toàn với `TalkerScreen`. Bạn có thể mở màn hình danh sách log để xem trực tiếp các sự kiện đã diễn ra:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => TalkerScreen(talker: AppTalker.instance),
  ),
);
```

### 3. Xuất log ra file (Offline Logs)
Ứng dụng hỗ trợ ghi log vào bộ nhớ máy để có thể gửi cho kỹ thuật kiểm tra khi có sự cố:

```dart
await AppTalker.saveHistoryToFile();
```

## Các quy tắc quan trọng (Maintenance Rules)
1. **Bảo mật:** Tuyệt đối không log thông tin nhạy cảm của người dùng (Password, Token, PII).
2. **Hiệu năng:** Luôn giới hạn `maxHistoryItems` (mặc định 1000) để không làm tràn bộ nhớ RAM.
3. **Môi trường:** Đảm bảo tắt `useConsoleLogs` hoặc `enabled` trên môi trường Production nếu không thực sự cần thiết.
4. **Isolate:** Log từ Isolate phụ sẽ không tự động xuất hiện. Cần truyền message về Main Isolate để ghi log.

## Định hướng phát triển
- Tích hợp tự động lọc dữ liệu nhạy cảm (Obfuscation) cho API logs.
- Kết nối `TalkerObserver` với các công cụ giám sát từ xa (Sentry, Crashlytics).
