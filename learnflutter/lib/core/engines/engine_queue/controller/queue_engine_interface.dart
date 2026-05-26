import '../models/queue_config.dart';
import '../models/queue_task.dart';

/// Giao diện trừu tượng cơ sở của bộ điều phối hàng đợi (Queue Engine).
abstract class BaseQueueEngine {
  /// Cấu hình hiện tại của hàng đợi.
  QueueConfig get config;

  /// Cập nhật cấu hình động của hàng đợi (ví dụ: đổi số concurrency lúc runtime).
  void updateConfig(QueueConfig newConfig);

  /// Danh sách tất cả các tác vụ hiện có trong hàng đợi (bao gồm mọi trạng thái).
  List<QueueTask> get tasks;

  /// Kiểm tra xem hàng đợi có đang ở trạng thái tạm dừng hay không.
  bool get isPaused;

  /// Stream phát đi danh sách tác vụ cập nhật mỗi khi có thay đổi trạng thái trong hàng đợi.
  Stream<List<QueueTask>> get tasksStream;

  /// Thêm một tác vụ mới vào cuối hàng đợi và kích hoạt xử lý.
  void enqueue(QueueTask task);

  /// Thêm hàng loạt tác vụ vào cuối hàng đợi.
  void enqueueAll(List<QueueTask> tasks);

  /// Huỷ một tác vụ (chỉ khả thi khi tác vụ đang ở trạng thái `pending`).
  void cancel(String taskId);

  /// Tạm dừng hàng đợi. Các tác vụ đang chạy vẫn chạy tiếp, các tác vụ pending sẽ chờ.
  void pause();

  /// Tiếp tục hàng đợi và kích hoạt chạy các tác vụ pending.
  void resume();

  /// Xoá sạch hàng đợi (xoá toàn bộ task, bao gồm huỷ các task đang pending).
  void clear();

  /// Giải phóng tài nguyên của hàng đợi (đóng stream, dừng timers...).
  void dispose();
}
