import 'dart:collection';

/// Wrapper cho dữ liệu cache kèm theo thời gian hết hạn
class _CacheItem {
  final dynamic data;
  final DateTime? expiryTime;

  _CacheItem({required this.data, this.expiryTime});

  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }
}

/// Simple in-memory cache store for API responses.
class ApiCacheStore {
  ApiCacheStore._internal();
  static final ApiCacheStore instance = ApiCacheStore._internal();

  final Map<String, _CacheItem> _cache = {};

  /// Generate a unique cache key based on the request parameters.
  String generateKey(String method, String path, Map<String, dynamic>? queryParameters, dynamic data) {
    final queryStr = queryParameters != null && queryParameters.isNotEmpty 
        ? queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&') 
        : '';
    final dataStr = data?.toString() ?? '';
    return '$method:$path?$queryStr|$dataStr';
  }

  /// Store a response in the cache with an optional TTL.
  void set(String key, dynamic value, {Duration? duration}) {
    DateTime? expiryTime;
    if (duration != null) {
      expiryTime = DateTime.now().add(duration);
    }
    _cache[key] = _CacheItem(data: value, expiryTime: expiryTime);
  }

  /// Retrieve a response from the cache if it exists and is not expired.
  dynamic get(String key) {
    final item = _cache[key];
    if (item == null) return null;

    if (item.isExpired) {
      _cache.remove(key); // Auto-remove expired cache
      return null;
    }
    
    return item.data;
  }

  /// Clear all cached responses.
  void clear() {
    _cache.clear();
  }

  /// Remove a specific cached response.
  void remove(String key) {
    _cache.remove(key);
  }
}
