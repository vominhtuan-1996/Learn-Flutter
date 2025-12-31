import 'dart:async';
import 'package:flutter/material.dart';

class KeyboardService {
  /// Singleton
  static final KeyboardService instance = KeyboardService._internal();
  KeyboardService._internal();

  /// ValueNotifier để UI lắng nghe
  final ValueNotifier<double> keyboardHeight = ValueNotifier(0);
  final ValueNotifier<bool> keyboardVisible = ValueNotifier(false);

  /// Private
  double _lastHeight = 0;
  Timer? _debounce;

  /// Hàm khởi động listener (gắn vào addPostFrame)
  void start() {
    WidgetsBinding.instance.addObserver(_KeyboardObserver());
  }

  /// Nhận giá trị từ observer
  void _updateFromInsets(double inset) {
    _debounce?.cancel();

    // Đợi animation kết thúc (debounce)
    _debounce = Timer(const Duration(milliseconds: 40), () {
      final visible = inset > 0;

      if (visible != keyboardVisible.value) {
        keyboardVisible.value = visible;
      }

      if ((_lastHeight - inset).abs() > 5) {
        _lastHeight = inset;
        keyboardHeight.value = inset;
        // debugPrint("🔥 Keyboard height stable = $inset");
      }
    });
  }
}

class _KeyboardObserver with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    final inset = view.viewInsets.bottom;

    KeyboardService.instance._updateFromInsets(inset);
  }
}
