import 'dart:async';

import 'package:dio/dio.dart';

typedef TokenRefreshHandler = Future<String?> Function();

/// ApiException: wrapper for API errors
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

/// ApiClient - Singleton Dio wrapper for app-wide HTTP calls
///
/// Features:
/// - Singleton instance
/// - BaseOptions + timeout configuration
/// - Authorization header management via `setAuthToken`
/// - Optional `tokenRefreshHandler` to refresh token on 401 and retry once
/// - Helpers: get/post/put/delete/request/upload
/// - Error mapping to ApiException
class ApiClient {
  ApiClient._internal();

  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;
  String? _authToken;
  TokenRefreshHandler? _tokenRefreshHandler;

  /// Initialize the client. Call once during app startup.
  void init({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 20),
    TokenRefreshHandler? tokenRefreshHandler,
    Map<String, dynamic>? extra,
  }) {
    _tokenRefreshHandler = tokenRefreshHandler;

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      extra: extra ?? {},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // attach auth token if present
        if (_authToken != null && _authToken!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (err, handler) async {
        final dioError = err as DioError;

        // If 401 and we have a refresh handler, attempt to refresh token once
        final status = dioError.response?.statusCode;
        final options = dioError.requestOptions;

        if (status == 401 && _tokenRefreshHandler != null && options.extra['retried'] != true) {
          try {
            final newToken = await _tokenRefreshHandler!();
            if (newToken != null && newToken.isNotEmpty) {
              setAuthToken(newToken);
              // mark as retried to avoid loops
              options.extra['retried'] = true;
              final cloneReq = await dio.fetch(options);
              return handler.resolve(cloneReq);
            }
          } catch (_) {
            // ignore refresh errors and fall through to error handling
          }
        }

        // Map DioError to ApiException
        final message = _extractErrorMessage(dioError);
        final apiEx = ApiException(message, statusCode: status, data: dioError.response?.data);
        handler.reject(DioError(requestOptions: options, error: apiEx, type: dioError.type));
      },
    ));
  }

  /// Set Authorization token (Bearer)
  void setAuthToken(String token) {
    _authToken = token;
    // update default headers for future requests
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear auth token
  void clearAuthToken() {
    _authToken = null;
    dio.options.headers.remove('Authorization');
  }

  String _extractErrorMessage(DioError error) {
    try {
      final resp = error.response;
      if (resp?.data is Map && resp?.data['message'] != null) {
        return resp!.data['message'].toString();
      }
      if (resp?.statusMessage != null) return resp!.statusMessage!;
    } catch (_) {}
    if (error.type == DioErrorType.connectionTimeout) return 'Connection timed out';
    if (error.type == DioErrorType.receiveTimeout) return 'Receive timed out';
    if (error.type == DioErrorType.cancel) return 'Request was cancelled';
    return error.message ?? 'An unknown error occurred';
  }

  /// Generic request helper. Returns response.data on success.
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final resp = await dio.request(path,
          data: data,
          queryParameters: queryParameters,
          options: options?.copyWith(method: method) ?? Options(method: method),
          cancelToken: cancelToken);
      return resp.data;
    } on DioError catch (e) {
      // If we wrapped ApiException, rethrow it
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(e.message ?? 'An unknown error occurred', statusCode: e.response?.statusCode, data: e.response?.data);
    }
  }

  Future<dynamic> get(String path,
          {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      request(path,
          method: 'GET',
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);

  Future<dynamic> post(String path,
          {dynamic data,
          Map<String, dynamic>? queryParameters,
          Options? options,
          CancelToken? cancelToken}) =>
      request(path,
          method: 'POST',
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);

  Future<dynamic> put(String path,
          {dynamic data,
          Map<String, dynamic>? queryParameters,
          Options? options,
          CancelToken? cancelToken}) =>
      request(path,
          method: 'PUT',
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);

  Future<dynamic> delete(String path,
          {dynamic data,
          Map<String, dynamic>? queryParameters,
          Options? options,
          CancelToken? cancelToken}) =>
      request(path,
          method: 'DELETE',
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);

  /// Upload file(s) using FormData
  Future<dynamic> upload(String path, FormData formData,
      {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    try {
      final resp = await dio.post(path,
          data: formData,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);
      return resp.data;
    } on DioError catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(e.message ?? 'An unknown error occurred', statusCode: e.response?.statusCode, data: e.response?.data);
    }
  }
}
