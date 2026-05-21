import 'dart:async';

/// Các trạng thái có thể có của một tác vụ trong hàng đợi.
enum QueueTaskStatus {
  /// Đang chờ đến lượt thực thi
  pending,

  /// Đang trong quá trình chạy
  executing,

  /// Thực thi thành công
  completed,

  /// Thực thi thất bại sau khi đã thử lại tối đa số lần cấu hình
  failed,

  /// Tạm dừng (hàng đợi bị pause khi task đang pending)
  paused,

  /// Đã bị huỷ bỏ khỏi hàng đợi
  cancelled,
}

/// Lớp trừu tượng cơ sở đại diện cho một tác vụ trong hàng đợi.
abstract class QueueTask {
  /// Định danh duy nhất cho tác vụ
  final String id;

  /// Tên mô tả trực quan của tác vụ
  final String name;

  /// Số lần thử lại tối đa khi thực thi gặp lỗi
  final int maxRetries;

  /// Thời gian chờ mặc định trước khi thử lại
  final Duration retryDelay;

  /// Trạng thái hiện tại của tác vụ
  QueueTaskStatus status;

  /// Số lần đã thử lại hiện tại
  int retries;

  /// Thông tin lỗi chi tiết nếu thực thi thất bại
  String? error;

  /// Thời điểm tác vụ được tạo
  final DateTime createdAt;

  QueueTask({
    required this.id,
    required this.name,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.status = QueueTaskStatus.pending,
    this.retries = 0,
    this.error,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Phương thức trừu tượng thực thi logic nghiệp vụ của tác vụ.
  /// Cần được override bởi các lớp con cụ thể.
  Future<void> execute();

  /// Tạo bản sao của tác vụ với trạng thái mới để cập nhật UI bất biến (immutable state).
  QueueTask copyWith({
    QueueTaskStatus? status,
    int? retries,
    String? error,
  });
}

/// Triển khai cụ thể của [QueueTask] cho phép sử dụng callback bất đồng bộ nhanh chóng.
class CallbackQueueTask extends QueueTask {
  /// Callback chứa logic nghiệp vụ bất đồng bộ cần chạy
  final Future<void> Function() callback;

  CallbackQueueTask({
    required super.id,
    required super.name,
    required this.callback,
    super.maxRetries,
    super.retryDelay,
    super.status,
    super.retries,
    super.error,
    super.createdAt,
  });

  @override
  Future<void> execute() async {
    await callback();
  }

  @override
  CallbackQueueTask copyWith({
    QueueTaskStatus? status,
    int? retries,
    String? error,
  }) {
    return CallbackQueueTask(
      id: id,
      name: name,
      callback: callback,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
      status: status ?? this.status,
      retries: retries ?? this.retries,
      error: error ?? this.error,
      createdAt: createdAt,
    );
  }
}
