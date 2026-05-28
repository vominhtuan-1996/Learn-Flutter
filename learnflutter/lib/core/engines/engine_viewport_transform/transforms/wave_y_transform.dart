import 'dart:math' as math;

import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Đẩy item theo trục Y theo hàm sin của (scrollOffset + index*phase) —
/// tạo hiệu ứng "sóng" lan dọc theo list khi cuộn.
class WaveYTransform extends ViewportTransform {
  WaveYTransform({
    this.amplitude = 20,
    this.frequency = 0.012,
    this.indexPhase = 0.6,
  });

  /// Biên độ sóng (px).
  final double amplitude;

  /// Tần số sóng theo scrollOffset (radian/px).
  final double frequency;

  /// Lệch pha giữa các item liên tiếp (radian).
  final double indexPhase;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final phase = context.scrollOffset * frequency + item.index * indexPhase;
    state.translateY += math.sin(phase) * amplitude;
  }
}
