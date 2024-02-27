import 'dart:async';
import 'package:flutter/foundation.dart';

/// Just a Debounce
class Debounce {
  static Debounce? _singleton;

  Debounce._();

  factory Debounce() {
    _singleton ??= Debounce._();
    return _singleton!;
  }

  static Debounce get instance => Debounce();

  /// The callback you want to call in debounce
  VoidCallback? action;

  /// This is the counter
  Timer? _timer;

  /// Is there any functions are calling
  bool isBusy = false;

  /// Time for 1 debounce (ms)
  final delay = 300;

  /// After [delay] time this gonna call the [action]
  /// If any action being call in [delay] time, the previous call will be canceled and start this new one
  /// In short, it will take the last call and cancel all the previous calls
  runAfter({required VoidCallback action, int? rate}) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: rate ?? delay), action);
  }

  /// This call the [action] first, and this gonna be in a "Cold down" time [delay]
  /// In "Cold down" time, any of action will be cancel
  /// In short, it will take the first call and cancel all the next calls
  runBefore({required VoidCallback action, int? rate}) {
    try {
      if (!isBusy) {
        isBusy = true;
        Timer(Duration(milliseconds: rate ?? delay), () => isBusy = false);
        action();
      }
    } catch (e) {}
  }

  removeTimer() {
    _timer?.cancel();
  }
}

class SingleDebounce {
  /// The callback you want to call in debounce
  VoidCallback? action;

  /// This is the counter
  Timer? _timer;

  /// Is there any functions are calling
  bool isBusy = false;

  /// Time for 1 debounce (ms)
  final delay = 300;

  /// After [delay] time this gonna call the [action]
  /// If any action being call in [delay] time, the previous call will be canceled and start this new one
  /// In short, it will take the last call and cancel all the previous calls
  runAfter({required VoidCallback action, int? rate}) {
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: rate ?? delay), action);
  }

  /// This call the [action] first, and this gonna be in a "Cold down" time [delay]
  /// In "Cold down" time, any of action will be cancel
  /// In short, it will take the first call and cancel all the next calls
  runBefore({required VoidCallback action, int? rate}) {
    try {
      if (!isBusy) {
        isBusy = true;
        Timer(Duration(milliseconds: rate ?? delay), () => isBusy = false);
        action();
      }
    } catch (e) {}
  }

  removeTimer() {
    _timer?.cancel();
  }
}
