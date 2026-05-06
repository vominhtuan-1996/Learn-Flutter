import 'dart:collection';

import 'package:flutter/scheduler.dart';

/// Singleton Ticker toàn cục - 1 ticker duy nhất cho toàn app.
/// Mọi animation đều lắng nghe thông qua listener này.
class CoreTicker {
  static final CoreTicker _instance = CoreTicker._();
  factory CoreTicker() => _instance;
  CoreTicker._();

  final _listeners = LinkedHashMap<Object, void Function(double dt)>();
  Duration _last = Duration.zero;
  bool _started = false;

  /// Đăng ký listener với một key định danh (để có thể remove sau này).
  void add(Object key, void Function(double dt) listener) {
    _listeners[key] = listener;
  }

  /// Gỡ listener theo key - gọi trong dispose() để tránh memory leak.
  void remove(Object key) {
    _listeners.remove(key);
  }

  /// Khởi động ticker - chỉ gọi 1 lần duy nhất trong app lifecycle.
  void start(TickerProvider vsync) {
    if (_started) return;
    _started = true;

    vsync.createTicker((elapsed) {
      final dt = (_last == Duration.zero)
          ? 0.0
          : (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;

      // Tạo bản sao để tránh concurrent modification
      for (final listener in List.of(_listeners.values)) {
        listener(dt);
      }
    }).start();
  }
}
