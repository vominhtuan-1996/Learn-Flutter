/// Cấu hình hoạt động của [QueueEngine].
class QueueConfig {
  /// Số lượng tác vụ tối đa được phép thực thi song song.
  /// Mặc định là 1 (chạy tuần tự - Sequential).
  final int concurrency;

  /// Kích hoạt cơ chế Exponential Backoff khi thử lại (nhân đôi thời gian chờ sau mỗi lần lỗi).
  /// Mặc định là true.
  final bool exponentialBackoff;

  /// Thời gian chờ mặc định giữa các lần retry (nếu task không định nghĩa).
  final Duration defaultRetryDelay;

  const QueueConfig({
    this.concurrency = 1,
    this.exponentialBackoff = true,
    this.defaultRetryDelay = const Duration(seconds: 2),
  }) : assert(concurrency >= 1, 'Concurrency phải lớn hơn hoặc bằng 1');

  /// Tạo bản sao cấu hình với các thông số thay đổi.
  QueueConfig copyWith({
    int? concurrency,
    bool? exponentialBackoff,
    Duration? defaultRetryDelay,
  }) {
    return QueueConfig(
      concurrency: concurrency ?? this.concurrency,
      exponentialBackoff: exponentialBackoff ?? this.exponentialBackoff,
      defaultRetryDelay: defaultRetryDelay ?? this.defaultRetryDelay,
    );
  }
}
