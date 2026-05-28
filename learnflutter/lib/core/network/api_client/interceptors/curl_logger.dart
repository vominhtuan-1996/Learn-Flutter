import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class CurlLogger extends Interceptor {
  CurlLogger({
    this.printOnSuccess = true,
    this.printOnError = true,
    this.convertFormData = true,
  });

  final bool printOnSuccess;
  final bool printOnError;
  final bool convertFormData;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['__curl__'] = _buildCurl(options);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (printOnSuccess) {
      _log(response.requestOptions, status: response.statusCode);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (printOnError) {
      _log(err.requestOptions, status: err.response?.statusCode, error: err.message);
    }
    handler.next(err);
  }

  void _log(RequestOptions options, {int? status, String? error}) {
    final curl = options.extra['__curl__'] as String? ?? _buildCurl(options);
    final tag = error != null ? 'CURL ✗ ${status ?? '-'}' : 'CURL ✓ ${status ?? '-'}';
    developer.log('\n$curl', name: tag);
    if (error != null) {
      developer.log(error, name: tag);
    }
  }

  String _buildCurl(RequestOptions options) {
    final parts = <String>['curl -i'];

    parts.add('-X ${options.method.toUpperCase()}');

    options.headers.forEach((key, value) {
      if (value == null) return;
      parts.add("-H ${_shellQuote('$key: $value')}");
    });

    final contentType = (options.headers[Headers.contentTypeHeader] ?? options.contentType)?.toString().toLowerCase() ?? '';
    final body = options.data;

    if (body != null) {
      if (body is FormData) {
        if (convertFormData) {
          for (final field in body.fields) {
            parts.add('-F ${_shellQuote('${field.key}=${field.value}')}');
          }
          for (final file in body.files) {
            final filename = file.value.filename ?? 'file';
            parts.add('-F ${_shellQuote('${file.key}=@$filename')}');
          }
        }
      } else if (body is String) {
        parts.add('--data-raw ${_shellQuote(body)}');
      } else if (body is Map || body is List) {
        parts.add('--data-raw ${_shellQuote(jsonEncode(body))}');
      } else if (contentType.contains('x-www-form-urlencoded') && body is Map) {
        final encoded = (body).entries.map((e) => '${e.key}=${e.value}').join('&');
        parts.add('--data-urlencode ${_shellQuote(encoded)}');
      } else {
        parts.add('--data-raw ${_shellQuote(body.toString())}');
      }
    }

    parts.add(_shellQuote(_fullUrl(options)));
    return parts.join(' \\\n  ');
  }

  String _fullUrl(RequestOptions options) {
    final uri = options.uri;
    if (options.queryParameters.isEmpty) return uri.toString();
    return uri.toString();
  }

  String _shellQuote(String input) {
    final escaped = input.replaceAll(r"'", r"'\''");
    return "'$escaped'";
  }
}
