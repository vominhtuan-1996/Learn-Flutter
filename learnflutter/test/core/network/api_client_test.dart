import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnflutter/core/network/api_client.dart';

class _FakeAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  _FakeAdapter(this.handler);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future? cancelFuture) {
    return handler(options);
  }
}

void main() {
  group('ApiClient', () {
    setUpAll(() {
      // initialize client once for the group with a dummy baseUrl and a refresh handler
      ApiClient.instance.init(
          baseUrl: 'https://api.example.com',
          tokenRefreshHandler: () async {
            return 'refreshed-token';
          });
    });

    test('get returns parsed JSON on 200', () async {
      final dio = ApiClient.instance.dio;
      dio.httpClientAdapter = _FakeAdapter((options) async {
        final body = jsonEncode({'hello': 'world'});
        return ResponseBody.fromString(body, 200, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
      });

      final res = await ApiClient.instance.get('/ok');
      expect(res, isA<Map>());
      expect(res['hello'], 'world');
    });

    test('401 triggers token refresh and retries once', () async {
      final dio = ApiClient.instance.dio;

      dio.httpClientAdapter = _FakeAdapter((options) async {
        // when not retried yet, return 401; when retried=true return 200
        final retried = options.extra['retried'] == true;
        if (!retried) {
          return ResponseBody.fromString(jsonEncode({'message': 'Unauthorized'}), 401, headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          });
        }
        return ResponseBody.fromString(jsonEncode({'ok': true}), 200, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
      });

      final res = await ApiClient.instance.get('/protected');
      expect(res, isA<Map>());
      expect(res['ok'], true);
    });

    test('non-200 throws ApiException', () async {
      final dio = ApiClient.instance.dio;
      dio.httpClientAdapter = _FakeAdapter((options) async {
        return ResponseBody.fromString(jsonEncode({'message': 'Bad Request'}), 400, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
      });

      expect(() async => await ApiClient.instance.get('/bad'), throwsA(isA<ApiException>()));
    });
  });
}
