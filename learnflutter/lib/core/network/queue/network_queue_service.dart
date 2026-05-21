import 'dart:async';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:learnflutter/core/engine_queue/controller/in_memory_queue_engine.dart';
import 'package:learnflutter/core/engine_queue/models/queue_config.dart';
import 'package:learnflutter/core/engine_queue/models/queue_task.dart';
import 'package:learnflutter/core/services/talker/app_talker.dart';
import 'network_queue_task.dart';

/// Dịch vụ quản lý hàng đợi yêu cầu mạng (Network Queue Service).
/// Singleton chịu trách nhiệm điều phối các tác vụ HTTP thông qua [InMemoryQueueEngine].
class NetworkQueueService {
  NetworkQueueService._internal();

  static final NetworkQueueService instance = NetworkQueueService._internal();

  late InMemoryQueueEngine _engine;
  final Map<String, Completer<dynamic>> _completers = {};
  final _uuid = const Uuid();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Khởi tạo Network Queue Service. Gọi một lần khi khởi chạy ứng dụng.
  void init({
    QueueConfig config = const QueueConfig(
      concurrency: 2,
      exponentialBackoff: true,
    ),
  }) {
    if (_isInitialized) return;

    _engine = InMemoryQueueEngine(config: config);
    _engine.tasksStream.listen(_onTasksChanged);
    _isInitialized = true;
    
    AppTalker.instance.info('🌐 [Network Queue] Initialized with concurrency: ${config.concurrency}');
  }

  /// Theo dõi thay đổi trạng thái của các task trong queue để xử lý dọn dẹp hoặc hoàn tất
  void _onTasksChanged(List<QueueTask> tasks) {
    for (final task in tasks) {
      final completer = _completers[task.id];
      if (completer == null || completer.isCompleted) continue;

      if (task.status == QueueTaskStatus.completed) {
        // Tác vụ thành công: Completer đã được hoàn thành bên trong execute().
        // Ta chỉ cần dọn dẹp completer khỏi Map.
        _completers.remove(task.id);
        AppTalker.instance.info('✅ [Network Queue] Task ${task.name} completed.');
      } else if (task.status == QueueTaskStatus.failed) {
        // Tác vụ thất bại hoàn toàn: Completer cũng đã được thông báo lỗi trong execute().
        _completers.remove(task.id);
        AppTalker.instance.error('❌ [Network Queue] Task ${task.name} failed permanently: ${task.error}');
      } else if (task.status == QueueTaskStatus.cancelled) {
        // Tác vụ bị huỷ bỏ: Hoàn thành completer với lỗi huỷ bỏ.
        completer.completeError(DioError(
          requestOptions: RequestOptions(path: task.name),
          message: 'Request was cancelled from the network queue.',
          type: DioErrorType.cancel,
        ));
        _completers.remove(task.id);
        AppTalker.instance.warning('⚠️ [Network Queue] Task ${task.name} cancelled.');
      }
    }
  }

  /// Xếp hàng một yêu cầu HTTP tùy chỉnh và trả về Future chứa kết quả phản hồi.
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? baseUrl,
    bool useCache = false,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) {
    if (!_isInitialized) {
      init();
    }

    final taskId = _uuid.v4();
    final completer = Completer<dynamic>();
    _completers[taskId] = completer;

    final task = NetworkQueueTask(
      id: taskId,
      name: '$method $path',
      path: path,
      completer: completer,
      method: method,
      data: data,
      queryParameters: queryParameters,
      options: options,
      baseUrl: baseUrl,
      useCache: useCache,
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );

    AppTalker.instance.info('📥 [Network Queue] Enqueued: $method $path (ID: $taskId)');
    _engine.enqueue(task);

    return completer.future;
  }

  /// Tiện ích GET request qua Queue
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? baseUrl,
    bool useCache = false,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) =>
      request(
        path,
        method: 'GET',
        queryParameters: queryParameters,
        options: options,
        baseUrl: baseUrl,
        useCache: useCache,
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      );

  /// Tiện ích POST request qua Queue
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? baseUrl,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) =>
      request(
        path,
        method: 'POST',
        data: data,
        queryParameters: queryParameters,
        options: options,
        baseUrl: baseUrl,
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      );

  /// Tiện ích PUT request qua Queue
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? baseUrl,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) =>
      request(
        path,
        method: 'PUT',
        data: data,
        queryParameters: queryParameters,
        options: options,
        baseUrl: baseUrl,
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      );

  /// Tiện ích DELETE request qua Queue
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? baseUrl,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) =>
      request(
        path,
        method: 'DELETE',
        data: data,
        queryParameters: queryParameters,
        options: options,
        baseUrl: baseUrl,
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      );

  // --- Các phương thức chuyển tiếp điều khiển QueueEngine ---

  List<QueueTask> get tasks => _engine.tasks;

  bool get isPaused => _engine.isPaused;

  Stream<List<QueueTask>> get tasksStream => _engine.tasksStream;

  void updateConfig(QueueConfig newConfig) {
    _engine.updateConfig(newConfig);
  }

  void cancel(String taskId) {
    _engine.cancel(taskId);
  }

  void pause() {
    _engine.pause();
    AppTalker.instance.warning('⏸️ [Network Queue] Paused.');
  }

  void resume() {
    _engine.resume();
    AppTalker.instance.info('▶️ [Network Queue] Resumed.');
  }

  void clear() {
    // Hoàn tất các completer đang đợi với lỗi huỷ bỏ trước khi xoá sạch
    final pendingTaskIds = _engine.tasks
        .where((t) => t.status == QueueTaskStatus.pending || t.status == QueueTaskStatus.executing)
        .map((t) => t.id)
        .toList();
        
    for (final id in pendingTaskIds) {
      final completer = _completers[id];
      if (completer != null && !completer.isCompleted) {
        completer.completeError(DioError(
          requestOptions: RequestOptions(path: 'Cleared'),
          message: 'Queue was cleared.',
          type: DioErrorType.cancel,
        ));
      }
      _completers.remove(id);
    }

    _engine.clear();
    AppTalker.instance.warning('🧹 [Network Queue] Cleared.');
  }

  void dispose() {
    clear();
    _engine.dispose();
    _isInitialized = false;
  }
}
