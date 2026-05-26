import 'dart:async';
import '../models/queue_config.dart';
import '../models/queue_task.dart';
import 'queue_engine_interface.dart';

/// Triển khai bộ điều phối hàng đợi chạy trực tiếp trên bộ nhớ RAM (In-Memory).
class InMemoryQueueEngine implements BaseQueueEngine {
  QueueConfig _config;
  final List<QueueTask> _tasks = [];
  bool _isPaused = false;

  /// StreamController dùng để phát dữ liệu cập nhật trạng thái danh sách tác vụ.
  /// Sử dụng Broadcast để nhiều Cubit/Widget có thể lắng nghe cùng lúc.
  final StreamController<List<QueueTask>> _tasksStreamController =
      StreamController<List<QueueTask>>.broadcast();

  /// Quản lý các bộ đếm thời gian (Timer) cho các tác vụ đang chờ thử lại (retry delay).
  final Map<String, Timer> _retryTimers = {};

  InMemoryQueueEngine({
    QueueConfig config = const QueueConfig(),
  }) : _config = config;

  @override
  QueueConfig get config => _config;

  @override
  void updateConfig(QueueConfig newConfig) {
    _config = newConfig;
    // Kích hoạt xử lý lại hàng đợi phòng trường hợp số concurrency được tăng lên.
    _processQueue();
  }

  @override
  List<QueueTask> get tasks => List.unmodifiable(_tasks);

  @override
  bool get isPaused => _isPaused;

  @override
  Stream<List<QueueTask>> get tasksStream => _tasksStreamController.stream;

  @override
  void enqueue(QueueTask task) {
    // Không cho phép thêm trùng ID task đang hoạt động
    if (_tasks.any((t) => t.id == task.id && 
        (t.status == QueueTaskStatus.pending || t.status == QueueTaskStatus.executing))) {
      return;
    }
    
    _tasks.add(task);
    _emitTasks();
    _processQueue();
  }

  @override
  void enqueueAll(List<QueueTask> tasks) {
    for (final task in tasks) {
      if (!_tasks.any((t) => t.id == task.id && 
          (t.status == QueueTaskStatus.pending || t.status == QueueTaskStatus.executing))) {
        _tasks.add(task);
      }
    }
    _emitTasks();
    _processQueue();
  }

  @override
  void cancel(String taskId) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      // Chỉ cho phép huỷ các tác vụ chưa được thực thi (đang chờ hoặc đang đợi retry)
      if (task.status == QueueTaskStatus.pending) {
        _retryTimers[task.id]?.cancel();
        _retryTimers.remove(task.id);

        task.status = QueueTaskStatus.cancelled;
        _emitTasks();
        _processQueue();
      }
    }
  }

  @override
  void pause() {
    if (_isPaused) return;
    _isPaused = true;
    _emitTasks();
  }

  @override
  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    _emitTasks();
    _processQueue();
  }

  @override
  void clear() {
    // Huỷ bỏ các timer thử lại
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();

    // Đổi trạng thái các task đang chờ sang cancelled
    for (final task in _tasks) {
      if (task.status == QueueTaskStatus.pending) {
        task.status = QueueTaskStatus.cancelled;
      }
    }
    _tasks.clear();
    _emitTasks();
  }

  @override
  void dispose() {
    clear();
    _tasksStreamController.close();
  }

  /// Bộ lập lịch và điều phối tác vụ (Scheduler).
  /// Quản lý giới hạn concurrency và chọn các task pending đủ điều kiện để chạy.
  void _processQueue() {
    if (_isPaused) return;

    // Đếm số lượng task đang thực thi thực tế
    final executingCount =
        _tasks.where((t) => t.status == QueueTaskStatus.executing).length;

    if (executingCount >= _config.concurrency) return;

    final availableSlots = _config.concurrency - executingCount;

    // Tìm các task đang pending và KHÔNG nằm trong danh sách đợi Timer retry
    final pendingTasks = _tasks.where((t) {
      return t.status == QueueTaskStatus.pending && !_retryTimers.containsKey(t.id);
    }).toList();

    if (pendingTasks.isEmpty) return;

    // Chạy đồng thời các tác vụ trong giới hạn slots trống
    final tasksToRun = pendingTasks.take(availableSlots);
    for (final task in tasksToRun) {
      _runTask(task);
    }
  }

  /// Thực thi một tác vụ riêng biệt
  Future<void> _runTask(QueueTask task) async {
    task.status = QueueTaskStatus.executing;
    _emitTasks();

    try {
      await task.execute();
      
      // Kiểm tra xem tác vụ có bị xoá khỏi queue (clear) trong lúc đang chạy không
      if (!_tasks.any((t) => t.id == task.id)) return;

      task.status = QueueTaskStatus.completed;
      task.error = null;
    } catch (e) {
      if (!_tasks.any((t) => t.id == task.id)) return;

      final hasNextRetry = task.retries < task.maxRetries;
      if (hasNextRetry) {
        task.retries++;
        task.error = e.toString();
        _scheduleRetry(task);
      } else {
        task.status = QueueTaskStatus.failed;
        task.error = e.toString();
      }
    } finally {
      if (_tasks.any((t) => t.id == task.id)) {
        _emitTasks();
        _processQueue();
      }
    }
  }

  /// Lập lịch thử lại tác vụ sau khoảng thời gian trì hoãn (Backoff Delay)
  void _scheduleRetry(QueueTask task) {
    task.status = QueueTaskStatus.pending;

    // Tính toán thời gian chờ: nếu exponentialBackoff = true, delay = baseDelay * 2^(retries - 1)
    var delay = task.retryDelay;
    if (_config.exponentialBackoff && task.retries > 0) {
      final factor = 1 << (task.retries - 1);
      delay = Duration(milliseconds: task.retryDelay.inMilliseconds * factor);
    }

    _retryTimers[task.id] = Timer(delay, () {
      _retryTimers.remove(task.id);
      _processQueue();
    });
  }

  /// Phát tín hiệu cập nhật danh sách tác vụ bất biến (Deep copy danh sách) ra Stream
  void _emitTasks() {
    if (_tasksStreamController.isClosed) return;
    
    // Tạo bản sao của từng task để bảo đảm tính đóng gói dữ liệu
    final tasksCopy = _tasks.map((t) => t.copyWith()).toList();
    _tasksStreamController.add(tasksCopy);
  }
}
