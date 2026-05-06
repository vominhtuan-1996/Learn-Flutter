import 'package:dio/dio.dart';
import 'package:learnflutter/core/service/talker/app_talker.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
    this.retryInterval = const Duration(seconds: 1),
  });

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    int retryCount = extra['retry_count'] ?? 0;

    // Retry for network issues or 5xx server errors
    if (_shouldRetry(err) && retryCount < maxRetries) {
      retryCount++;
      extra['retry_count'] = retryCount;

      AppTalker.instance.warning('🔄 [API Client] Retrying request (${err.requestOptions.path}) - Attempt $retryCount');

      try {
        await Future.delayed(retryInterval);
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioError) {
          // If the retry also fails, it will loop back here naturally because dio.fetch triggers interceptors
          // Wait, dio.fetch with same interceptor might cause infinite loop if not handled well. 
          // Since retry_count is in extra, it's bounded.
          return super.onError(e, handler);
        }
      }
    }

    return super.onError(err, handler);
  }

  bool _shouldRetry(DioError err) {
    if (err.type == DioErrorType.connectionTimeout || 
        err.type == DioErrorType.receiveTimeout || 
        err.type == DioErrorType.sendTimeout ||
        err.type == DioErrorType.unknown) {
      return true;
    }

    final status = err.response?.statusCode;
    if (status != null && status >= 500 && status <= 599) {
      return true;
    }

    return false;
  }
}
