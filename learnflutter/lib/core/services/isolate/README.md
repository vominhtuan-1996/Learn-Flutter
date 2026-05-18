# Hướng dẫn sử dụng module Isolate (Multi-threading)

Module này cung cấp giải pháp xử lý đa luồng (Multi-threading) thông qua Isolate, giúp tách các tác vụ tính toán nặng ra khỏi luồng chính (Main UI Thread) để đảm bảo ứng dụng luôn mượt mà.

## Cấu trúc thư mục
- `lib/core/isolate/app_isolate_handler.dart`: Lớp Singleton quản lý việc thực thi các hàm trong Isolate.
- `lib/core/isolate/json_parse.dart`: Tiện ích chuyên dụng để parse dữ liệu JSON lớn dưới dạng Stream.
- `lib/core/isolate/api_service.dart`: Dịch vụ gọi API mẫu có sử dụng xử lý nền.

## Cách sử dụng

### 1. Sử dụng AppIsolateHandler (Khuyên dùng)
Dùng cho các tác vụ tính toán một lần (one-off) như parse object, xử lý logic phức tạp.

```dart
final result = await AppIsolateHandler().compute(() {
  // Thực hiện tính toán nặng ở đây
  return "Kết quả";
});
```

### 2. Xử lý JSON lớn (Streaming)
Dùng khi bạn nhận được một chuỗi JSON cực lớn và muốn xử lý từng phần tử ngay khi nó được parse xong để giảm tải cho RAM.

```dart
parseJson(rawJsonString).listen((item) {
  print('Nhận được phần tử: $item');
});
```

## Tại sao cần module này?
Trong Flutter, nếu bạn thực hiện một vòng lặp 1.000.000 lần hoặc `jsonDecode` một chuỗi 10MB trên Main Thread, màn hình sẽ bị "đứng hình" (Drop frames) vì UI Thread không thể vẽ frame tiếp theo. Isolate cho phép bạn đẩy những việc này sang luồng khác.

## Các quy tắc quan trọng (Maintenance Rules)
1. **Dữ liệu truyền vào:** Dữ liệu truyền qua Isolate phải là dữ liệu nguyên bản (Primitive) hoặc các object có thể serialize. Không truyền được `BuildContext`, `Widget`, hay `Image`.
2. **Hàm thực thi:** Hàm được truyền vào `compute` phải là hàm **Top-level** (viết ngoài class) hoặc hàm **Static** (tĩnh).
3. **Quản lý RAM:** Isolate chiếm bộ nhớ RAM riêng biệt. Tránh việc tạo quá nhiều Isolate cùng lúc mà không giải phóng. Sử dụng Singleton `AppIsolateHandler` để quản lý tập trung.

## Định hướng tương lai
- Tích hợp xử lý hình ảnh (Image processing) vào Isolate.
- Hỗ trợ `TransferableTypedData` cho các mảng dữ liệu cực lớn (Byte array) để tối ưu hiệu năng sao chép.
