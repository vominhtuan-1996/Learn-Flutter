import 'package:flutter/material.dart';

class KeyboardOverlayController {
  /// Singleton
  static final KeyboardOverlayController instance = KeyboardOverlayController._internal();
  KeyboardOverlayController._internal();

  /// Listener cho UI subscribe
  final ValueNotifier<double> keyboardHeight = ValueNotifier(0);
  final ValueNotifier<bool> keyboardVisible = ValueNotifier(false);

  /// Cập nhật trạng thái keyboard (được gọi từ KeyboardService)
  void update(bool visible, double height) {
    keyboardVisible.value = visible;
    keyboardHeight.value = visible ? height : 0;
  }
}
