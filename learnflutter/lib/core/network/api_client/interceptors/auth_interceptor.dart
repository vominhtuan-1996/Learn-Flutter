import 'package:dio/dio.dart';

import '../api_client.dart';

class AuthInterceptor extends Interceptor {
  final ApiClient apiClient;

  AuthInterceptor(this.apiClient);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = apiClient.authToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final options = err.requestOptions;

    if (status == 401 && apiClient.tokenRefreshHandler != null && options.extra['retried'] != true) {
      try {
        final newToken = await apiClient.tokenRefreshHandler!();
        if (newToken != null && newToken.isNotEmpty) {
          apiClient.setAuthToken(newToken);
          options.extra['retried'] = true;
          final cloneReq = await apiClient.dio.fetch(options);
          return handler.resolve(cloneReq);
        }
      } catch (_) {
        // ignore refresh errors and fall through to error handling
      }
    }

    handler.next(err);
  }
}
