import 'package:dio/dio.dart';

import '../api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // Nếu lỗi đã được bọc thành ApiException (VD từ AuthInterceptor)
    if (err.error is ApiException) {
      return handler.next(err);
    }

    final message = _extractErrorMessage(err);
    final status = err.response?.statusCode;
    
    final apiEx = ApiException(message, statusCode: status, data: err.response?.data);
    
    // Gói lại lỗi của Dio thành ApiException
    handler.next(DioError(
      requestOptions: err.requestOptions,
      error: apiEx,
      type: err.type,
      response: err.response,
    ));
  }

  String _extractErrorMessage(DioError error) {
    try {
      final resp = error.response;
      if (resp?.data is Map && resp?.data['message'] != null) {
        return resp!.data['message'].toString();
      }
      if (resp?.statusMessage != null && resp!.statusMessage!.isNotEmpty) {
        return resp.statusMessage!;
      }
    } catch (_) {}
    
    if (error.type == DioErrorType.connectionTimeout) return 'Connection timed out';
    if (error.type == DioErrorType.receiveTimeout) return 'Receive timed out';
    if (error.type == DioErrorType.cancel) return 'Request was cancelled';
    
    // Bắt lỗi không có mạng (SocketException) từ Dio
    if (error.type.toString() == 'DioErrorType.connectionError' || 
        error.error.toString().contains('SocketException')) {
      return 'No Internet Connection';
    }

    return error.message ?? 'An unknown error occurred';
  }
}
