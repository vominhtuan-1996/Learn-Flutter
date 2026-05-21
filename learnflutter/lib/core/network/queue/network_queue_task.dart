import 'dart:async';
import 'package:dio/dio.dart';
import 'package:learnflutter/core/engine_queue/models/queue_task.dart';
import 'package:learnflutter/core/network/api_client/api_client.dart';

/// Một tác vụ xếp hàng mạng chuyên dụng kế thừa từ [QueueTask].
/// Bao bọc các tham số để thực thi HTTP request qua [ApiClient].
class NetworkQueueTask extends QueueTask {
  final String path;
  final String method;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final Options? options;
  final String? baseUrl;
  final bool useCache;
  
  /// Completer để thông báo kết quả trả về cho caller đang đợi (await).
  final Completer<dynamic> completer;

  NetworkQueueTask({
    required super.id,
    required super.name,
    required this.path,
    required this.completer,
    this.method = 'GET',
    this.data,
    this.queryParameters,
    this.options,
    this.baseUrl,
    this.useCache = false,
    super.maxRetries = 3,
    super.retryDelay = const Duration(seconds: 2),
    super.status,
    super.retries,
    super.error,
    super.createdAt,
  });

  @override
  Future<void> execute() async {
    try {
      final result = await ApiClient.instance.request(
        path,
        method: method,
        data: data,
        queryParameters: queryParameters,
        options: options,
        baseUrl: baseUrl,
        useCache: useCache,
      );
      
      // Hoàn thành completer với kết quả nhận được
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    } catch (e) {
      // Nếu đã đạt tới số lần thử lại tối đa (retries >= maxRetries), 
      // hoàn thành completer với lỗi để caller nhận biết.
      if (retries >= maxRetries) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
      // Rethrow để QueueEngine ghi nhận lỗi và thực hiện chạy lại/đánh dấu Failed
      rethrow;
    }
  }

  @override
  NetworkQueueTask copyWith({
    QueueTaskStatus? status,
    int? retries,
    String? error,
  }) {
    return NetworkQueueTask(
      id: id,
      name: name,
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
      status: status ?? this.status,
      retries: retries ?? this.retries,
      error: error ?? this.error,
      createdAt: createdAt,
    );
  }
}
