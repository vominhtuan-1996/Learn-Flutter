# Queue Engine Module

`QueueEngine` là một thư viện cốt lõi thuộc tầng Core giúp quản lý, lập lịch và thực thi các tác vụ bất đồng bộ (asynchronous jobs) trong hàng đợi một cách có tổ chức, bảo đảm hiệu năng và tính ổn định.

---

## Tính năng nổi bật

1. **Giới hạn số lượng tác vụ chạy song song (Concurrency Control)**: Hỗ trợ cấu hình chạy tuần tự (Sequential - Concurrency = 1) hoặc chạy song song (Concurrent - Concurrency > 1).
2. **Cơ chế tự động thử lại (Retry Policy)**: Tự động chạy lại các tác vụ lỗi theo số lần cấu hình riêng biệt của từng task.
3. **Exponential Backoff**: Nhân đôi thời gian trì hoãn chờ thử lại sau mỗi lần lỗi liên tiếp (ví dụ: 2s -> 4s -> 8s) để hạn chế spam máy chủ khi gặp lỗi mạng hệ thống.
4. **Kiểm soát vòng đời hàng đợi**: Hỗ trợ Tạm dừng (Pause), Tiếp tục (Resume), Huỷ tác vụ đang chờ (Cancel), và Dọn sạch hàng đợi (Clear).
5. **Cập nhật Tiến trình Thời gian thực**: Cung cấp `Stream<List<QueueTask>>` phát dữ liệu bất biến (deep copy) mỗi khi trạng thái hàng đợi thay đổi, tương thích hoàn hảo với BLoC/Cubit và UI.

---

## Cấu trúc thư mục

```text
lib/core/engine_queue/
├── controller/
│   ├── in_memory_queue_engine.dart      # Triển khai in-memory queue
│   └── queue_engine_interface.dart     # Interface trừu tượng cơ sở
├── models/
│   ├── queue_config.dart               # Cấu hình của hàng đợi
│   └── queue_task.dart                 # Định nghĩa task & status
├── README.md                           # Tài liệu hướng dẫn sử dụng (File này)
└── engine_queue.dart                   # Barrel export file
```

---

## Hướng dẫn sử dụng

### 1. Khởi tạo hàng đợi

```dart
import 'package:learnflutter/core/engine_queue/engine_queue.dart';

// Khởi tạo hàng đợi chạy song song tối đa 2 task đồng thời
final queueEngine = InMemoryQueueEngine(
  config: const QueueConfig(
    concurrency: 2,
    exponentialBackoff: true,
    defaultRetryDelay: Duration(seconds: 1),
  ),
);
```

### 2. Định nghĩa một tác vụ (Task)

Có hai cách để định nghĩa và enqueue task:

#### Cách 2.1: Kế thừa lớp trừu tượng `QueueTask` (Khuyên dùng cho các logic phức tạp)

```dart
class ImageUploadTask extends QueueTask {
  final String imagePath;

  ImageUploadTask({
    required super.id,
    required super.name,
    required this.imagePath,
    super.maxRetries = 3,
    super.retryDelay = const Duration(seconds: 2),
  });

  @override
  Future<void> execute() async {
    // Logic tải ảnh lên máy chủ
    await ApiService.uploadImage(imagePath);
  }

  @override
  ImageUploadTask copyWith({
    QueueTaskStatus? status,
    int? retries,
    String? error,
  }) {
    return ImageUploadTask(
      id: id,
      name: name,
      imagePath: imagePath,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      status: status ?? this.status,
      retries: retries ?? this.retries,
      error: error ?? this.error,
    );
  }
}

// Thêm vào hàng đợi
queueEngine.enqueue(ImageUploadTask(
  id: 'upload_001',
  name: 'Tải ảnh avatar',
  imagePath: '/path/to/avatar.jpg',
));
```

#### Cách 2.2: Sử dụng `CallbackQueueTask` (Phù hợp cho các xử lý nhanh, inline)

```dart
queueEngine.enqueue(
  CallbackQueueTask(
    id: 'sync_user_profile',
    name: 'Đồng bộ profile',
    maxRetries: 2,
    retryDelay: const Duration(seconds: 1),
    callback: () async {
      await ApiService.syncProfile();
    },
  ),
);
```

### 3. Lắng nghe và cập nhật tiến trình ra giao diện (UI)

```dart
StreamBuilder<List<QueueTask>>(
  stream: queueEngine.tasksStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const Text('Hàng đợi trống');
    
    final tasks = snapshot.data!;
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.name),
          subtitle: Text('Trạng thái: ${task.status.name} (Thử lại: ${task.retries}/${task.maxRetries})'),
          trailing: task.status == QueueTaskStatus.executing 
              ? const CircularProgressIndicator()
              : null,
        );
      },
    );
  },
);
```

### 4. Quản trị hàng đợi

```dart
// Tạm dừng hàng đợi
queueEngine.pause();

// Tiếp tục chạy hàng đợi
queueEngine.resume();

// Huỷ một task cụ thể (chỉ khả thi nếu task đó đang ở trạng thái pending)
queueEngine.cancel('task_id_123');

// Dọn sạch và huỷ toàn bộ task trong hàng đợi
queueEngine.clear();

// Giải phóng tài nguyên khi không còn sử dụng
queueEngine.dispose();
```
