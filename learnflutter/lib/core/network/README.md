# Core Network

Module mạng tổng hợp dựa trên `Dio`, cung cấp 3 component:

```
lib/core/network/
├── api_client/                          → HTTP client (singleton, interceptors, cache)
│   ├── api_client.dart                  → ApiClient.instance
│   ├── api_exception.dart               → ApiException (lỗi thống nhất)
│   ├── api_cache_store.dart             → ApiCacheStore (in-memory cache + TTL)
│   ├── base_response.dart               → BaseResponse<T> (chuẩn JSON dự án)
│   ├── interceptors/
│   │   ├── auth_interceptor.dart        → Token + auto refresh 401
│   │   ├── retry_interceptor.dart       → Retry network/5xx
│   │   └── error_interceptor.dart       → Wrap về ApiException
│   └── README.md                        → Chi tiết riêng cho api_client
├── graphql/
│   └── graphql_client.dart              → GraphqlClient (wrapper trên ApiClient)
├── queue/
│   ├── network_queue_service.dart       → NetworkQueueService (queue HTTP có retry + concurrency)
│   └── network_queue_task.dart          → QueueTask cụ thể cho HTTP
├── network_demo_screen.dart             → demo trực quan 3 tab
└── README.md (file này)
```

---

## 1. ApiClient — REST/HTTP

Singleton wrapper trên Dio. Khởi tạo 1 lần ở `main.dart`:

```dart
ApiClient.instance.init(
  baseUrl: 'https://api.myapp.com',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 20),
  tokenRefreshHandler: () async {
    // Gọi /auth/refresh và return token mới (hoặc null nếu thất bại)
    final resp = await ApiClient.instance.post('/auth/refresh', data: {...});
    return resp['data']['accessToken'];
  },
);

ApiClient.instance.setAuthToken('xxx'); // hoặc clearAuthToken()
```

Sử dụng:

```dart
final json = await ApiClient.instance.get('/users/1');
final created = await ApiClient.instance.post('/posts', data: {'title': '...'});
await ApiClient.instance.delete('/posts/42');
final raw = await ApiClient.instance.request('/custom', method: 'PATCH', data: ...);

// Cache 1 phút (in-memory, theo key method+path+query+data)
final cached = await ApiClient.instance.get('/config', useCache: true);

// Override baseUrl cho 1 request (gọi service khác)
final ext = await ApiClient.instance.get(
  'https://other.api/v1/things',  // path tuyệt đối luôn override baseUrl
);

// Upload + download
await ApiClient.instance.upload('/files', FormData.fromMap({'file': MultipartFile.fromBytes(bytes)}));
await ApiClient.instance.download('/large.zip', '/tmp/large.zip', onReceiveProgress: (r, t) => ...);
```

### Interceptors (built-in)

| Interceptor | Trách nhiệm |
|---|---|
| `AuthInterceptor` | Gắn `Authorization: Bearer <token>` cho mọi request; khi gặp 401 gọi `tokenRefreshHandler`, thử lại 1 lần với token mới |
| `RetryInterceptor` | Retry network error / 5xx tối đa 2 lần (mặc định) sau 1s delay |
| `ErrorInterceptor` | Convert mọi DioError thành `ApiException(statusCode, message, data)` |
| `TalkerDioLogger` | Log request/response màu sắc qua `AppTalker` |

### `BaseResponse<T>`

Helper parse JSON chuẩn dự án `{status, message, errorData, data}`:

```dart
final json = await ApiClient.instance.get('/users/1');
final resp = BaseResponse<User>.fromJson(json, (raw) => User.fromJson(raw));
if (resp.isSuccess) return resp.data!;
throw ApiException(resp.message, data: resp.errorData);
```

### `ApiException`

Mọi lỗi đều ném `ApiException`:

```dart
try {
  await ApiClient.instance.get('/x');
} on ApiException catch (e) {
  print('${e.statusCode} ${e.message}');
}
```

---

## 2. NetworkQueueService — HTTP qua hàng đợi

Khi cần **giới hạn concurrency**, **retry có exponential backoff**, hoặc **xếp request trước khi network sẵn sàng** — dùng queue thay vì gọi ApiClient trực tiếp. Mọi task dùng chung `ApiClient.instance` bên dưới.

```dart
NetworkQueueService.instance.init(
  config: const QueueConfig(concurrency: 2, exponentialBackoff: true),
);

final result = await NetworkQueueService.instance.get(
  '/heavy-endpoint',
  maxRetries: 3,
  retryDelay: const Duration(seconds: 2),
);

// Hoặc enqueue nhiều cùng lúc — service tự throttle theo concurrency
final futures = [for (var i = 0; i < 10; i++)
  NetworkQueueService.instance.get('/posts/$i')];
final results = await Future.wait(futures);
```

| API | Mục đích |
|---|---|
| `init(config)` | Khởi tạo `InMemoryQueueEngine` (idempotent) |
| `get/post/put/delete` | Tiện ích như `ApiClient` nhưng đi qua queue |
| `request(...)` | Generic — chọn method tuỳ ý |
| `cancel(taskId)` | Huỷ task chưa chạy / đang chờ |

Khi nào dùng:
- API server giới hạn rate-limit nghiêm ngặt → set `concurrency: 1` hoặc `2`.
- Cần retry bền bỉ với exponential backoff (queue engine tự handle).
- Muốn show progress nhiều request song song trong UI.

---

## 3. GraphqlClient

Wrapper mỏng trên `ApiClient.post()` — chỉ gói `{query, variables}` vào body JSON.

```dart
GraphqlClient.instance.defaultPath = '/graphql';

final result = await GraphqlClient.instance.query(
  document: r'''
    query Country($code: ID!) {
      country(code: $code) { name capital currency }
    }
  ''',
  variables: {'code': 'VN'},
);
print(result['data']['country']['name']); // Vietnam

// Mutation tương tự — không cache
await GraphqlClient.instance.mutation(
  document: r'mutation Create($input: PostInput!) { createPost(input: $input) { id } }',
  variables: {'input': {...}},
);

// Override endpoint cho 1 request
await GraphqlClient.instance.query(
  document: r'{ ... }',
  path: 'https://countries.trevorblades.com/',
);
```

Caching và auth dùng chung infrastructure với `ApiClient` (vì gọi qua nó).

---

## 4. Pattern dùng chung

### Cancellation

```dart
final cancelToken = CancelToken();

ApiClient.instance.get('/long-poll', cancelToken: cancelToken);

// Khi user back screen:
cancelToken.cancel('User left');
```

### Repository wrapper

```dart
class UserRepository {
  Future<User> getById(int id) async {
    final json = await ApiClient.instance.get('/users/$id');
    return BaseResponse<User>.fromJson(json, User.fromJson).data!;
  }
}
```

### Multi-env baseUrl

Trong `main.dart`:
```dart
final baseUrl = AppConfig.instance.isProd
    ? 'https://api.prod.com'
    : 'https://api.staging.com';
ApiClient.instance.init(baseUrl: baseUrl);
```

---

## 5. Demo trực quan

Mở `NetworkDemoScreen` ([network_demo_screen.dart](network_demo_screen.dart)) — 3 tab:
- **REST** — GET/POST tới `jsonplaceholder.typicode.com`, hiển thị JSON + status.
- **Queue** — enqueue 8 request song song, counter pending/completed.
- **GraphQL** — query `countries.trevorblades.com` lấy danh sách country theo continent.

Route: `Routes.networkDemo` — card "Network Module Demo" trong [test_screen.dart](../../features/test_screen/test_screen.dart).
