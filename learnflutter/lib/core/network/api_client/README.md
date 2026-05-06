# Hướng dẫn sử dụng module ApiClient (Network Layer)

Module Network của dự án được xây dựng dựa trên gói `Dio`, hỗ trợ đầy đủ các tính năng cần thiết cho một ứng dụng Production thực tế.

## Các tính năng nổi bật
- **Singleton Pattern:** Đảm bảo chỉ có một instance duy nhất quản lý toàn bộ kết nối.
- **Interceptors tách biệt:**
  - `AuthInterceptor`: Tự động gắn Token và xử lý Refresh Token (401).
  - `RetryInterceptor`: Tự động thử lại request khi gặp lỗi mạng/timeout (mặc định 2 lần).
  - `ErrorInterceptor`: Chuyển đổi mọi lỗi về lớp `ApiException` thống nhất.
  - `TalkerDioLogger`: Log thông tin request/response chuyên nghiệp màu sắc trên console.
- **Caching:** Hỗ trợ In-memory cache với thời gian sống (TTL).
- **Multi-domain:** Dễ dàng thay đổi `baseUrl` cho từng request cụ thể.
- **Download:** Hỗ trợ tải file với tiến độ (progress callback).

## Cách sử dụng

### 1. Khởi tạo (Initialization)
Nên gọi hàm này một lần duy nhất tại `main.dart` hoặc nơi khởi chạy app:

```dart
ApiClient.instance.init(
  baseUrl: 'https://api.example.com/',
  connectTimeout: const Duration(seconds: 10),
  tokenRefreshHandler: () async {
    // Logic lấy token mới khi gặp lỗi 401
    return 'new_token';
  },
);
```

### 2. Thực hiện Request (HTTP Methods)

#### GET Request (có sử dụng Cache)
```dart
final data = await ApiClient.instance.get(
  'users/profile',
  useCache: true, // Bật cache
  cacheDuration: Duration(minutes: 10), // Cache trong 10 phút
);
```

#### POST Request
```dart
final response = await ApiClient.instance.post(
  'users/update',
  data: {'name': 'Antigravity'},
);
```

#### Tải File (Download)
```dart
await ApiClient.instance.download(
  'https://file.com/image.png',
  'local/path/image.png',
  onReceiveProgress: (count, total) {
    print('Tiến độ: ${(count / total * 100).toStringAsFixed(0)}%');
  },
);
```

### 3. Xử lý lỗi (Error Handling)
Toàn bộ lỗi được bọc trong `ApiException`, bạn nên sử dụng `try-catch`:

```dart
try {
  await ApiClient.instance.get('invalid-path');
} on ApiException catch (e) {
  print('Mã lỗi: ${e.statusCode}');
  print('Thông báo: ${e.message}');
  print('Dữ liệu từ server: ${e.data}');
}
```

## Các quy tắc bảo trì (Maintenance Rules)
1. **Interceptors:** Khi cần thêm logic chung cho mọi request (ví dụ: gắn thêm header đặc thù), hãy tạo file mới trong thư mục `interceptors/` thay vì viết trực tiếp vào `api_client.dart`.
2. **Cache Key:** Cơ chế tạo key của `ApiCacheStore` dựa trên Path + Params + Body. Nếu API trả về dữ liệu cá nhân hóa (Personalized), hãy đảm bảo Token được bao gồm trong request để tránh việc user A nhận được cache của user B.
3. **Log:** Sử dụng `TalkerDioLogger` để debug. Không nên dùng `print` thủ công trong Interceptors.
