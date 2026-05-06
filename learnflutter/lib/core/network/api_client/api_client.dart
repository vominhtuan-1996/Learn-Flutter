import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:learnflutter/core/service/talker/app_talker.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_dio_logger/talker_dio_logger_settings.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'api_exception.dart';
import 'api_cache_store.dart';

export 'api_exception.dart';
export 'api_cache_store.dart';
export 'base_response.dart';

typedef TokenRefreshHandler = Future<String?> Function();

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

  String? get authToken => _authToken;
  TokenRefreshHandler? get tokenRefreshHandler => _tokenRefreshHandler;

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

    dio.interceptors.addAll([
      AuthInterceptor(this),
      RetryInterceptor(dio: dio, maxRetries: 2),
      ErrorInterceptor(),
      TalkerDioLogger(
        talker: AppTalker.instance,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printResponseMessage: true,
        ),
      ),
    ]);
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

  /// Download file
  Future<dynamic> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      final response = await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
      return response.data;
    } on DioError catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(e.message ?? 'An unknown error occurred', statusCode: e.response?.statusCode, data: e.response?.data);
    }
  }

  /// Generic request helper. Returns response.data on success.
  /// If `baseUrl` is provided, it will override the default base URL for this specific request.
  /// If `useCache` is true, it will return the cached response if available for the same parameters.
  Future<dynamic> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    String? baseUrl,
    bool useCache = false,
  }) async {
    // Generate cache key and check cache if enabled
    final String cacheKey = ApiCacheStore.instance.generateKey(method, path, queryParameters, data);
    if (useCache) {
      final cachedResponse = ApiCacheStore.instance.get(cacheKey);
      if (cachedResponse != null) {
        AppTalker.instance.info('📦 [API Client] Return from Cache: $path');
        log('📦 [API Client] Return from Cache: $path');
        return cachedResponse;
      }
    }

    try {
      // Use the provided baseUrl if present, otherwise use the dio instance default
      final requestOptions = options?.copyWith(method: method) ?? Options(method: method);
      if (baseUrl != null) {
        requestOptions.extra ??= {};
        requestOptions.extra!['baseUrl'] = baseUrl;
      }

      final resp = await dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );
      
      // Save response to cache if enabled
      if (useCache && resp.data != null) {
        ApiCacheStore.instance.set(cacheKey, resp.data);
      }
      
      return resp.data;
    } on DioError catch (e) {
      // If we wrapped ApiException, rethrow it
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(e.message ?? 'An unknown error occurred', statusCode: e.response?.statusCode, data: e.response?.data);
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? baseUrl,
    bool useCache = false,
  }) =>
      request(
        path,
        method: 'GET',
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        baseUrl: baseUrl,
        useCache: useCache,
      );

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? baseUrl,
    bool useCache = false,
  }) =>
      request(
        path,
        method: 'POST',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        baseUrl: baseUrl,
        useCache: useCache,
      );

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? baseUrl,
    bool useCache = false,
  }) =>
      request(
        path,
        method: 'PUT',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        baseUrl: baseUrl,
        useCache: useCache,
      );

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? baseUrl,
    bool useCache = false,
  }) =>
      request(
        path,
        method: 'DELETE',
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        baseUrl: baseUrl,
        useCache: useCache,
      );

  /// Upload file(s) using FormData
  Future<dynamic> upload(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? baseUrl,
  }) async {
    try {
      final requestOptions = options ?? Options();
      if (baseUrl != null) {
        requestOptions.extra ??= {};
        requestOptions.extra!['baseUrl'] = baseUrl;
      }

      final resp = await dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );
      return resp.data;
    } on DioError catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException(e.message ?? 'An unknown error occurred', statusCode: e.response?.statusCode, data: e.response?.data);
    }
  }
}
