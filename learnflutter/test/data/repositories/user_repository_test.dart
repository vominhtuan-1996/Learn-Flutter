import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnflutter/core/network/api_client.dart';
import 'package:learnflutter/data/repositories/user_repository.dart';
import 'package:learnflutter/db/models/user_model.dart';

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
  group('UserRepository', () {
    setUpAll(() {
      ApiClient.instance.init(baseUrl: 'https://api.example.com');
    });

    test('login sets auth token and returns UserModel', () async {
      final dio = ApiClient.instance.dio;
      final now = DateTime.now().toIso8601String();

      dio.httpClientAdapter = _FakeAdapter((options) async {
        final body = jsonEncode({
          'user': {'id': 1, 'email': 'test@example.com', 'password': 'secret', 'createdAt': now, 'isActive': 1},
          'token': 'token-abc'
        });
        return ResponseBody.fromString(body, 200, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
      });

      final user = await UserRepository.instance.login(email: 'test@example.com', password: 'secret');
      expect(user, isA<UserModel>());
      expect(user.email, 'test@example.com');
      // Authorization header should be set in dio options
      expect(dio.options.headers['Authorization'], contains('token-abc'));
    });
  });
}
