import 'package:flutter/foundation.dart';

class SliverAnimationState extends ChangeNotifier {
  final double start;
  final double end;

  double _progress = 0;
  double get progress => _progress;

  SliverAnimationState({
    required this.start,
    required this.end,
  });

  /// Cập nhật tiến trình animation dựa trên offset của thanh cuộn.
  /// Giá trị [progress] sẽ nằm trong khoảng [0.0, 1.0].
  void update(double offset) {
    double newProgress;
    if (end == start) {
      newProgress = offset >= start ? 1.0 : 0.0;
    } else {
      newProgress = ((offset - start) / (end - start)).clamp(0.0, 1.0);
    }

    if (_progress != newProgress) {
      _progress = newProgress;
      notifyListeners();
    }
  }
}
