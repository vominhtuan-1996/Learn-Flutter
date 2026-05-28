import 'dart:math' as math;

import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Scale phóng đại tại tâm: ở tâm > 1.0 (overshoot), giảm về 1.0 ở khoảng giữa,
/// rồi tiếp tục giảm về `minScale` ở biên — tạo cảm giác "đàn hồi" khi item đi qua tâm.
class ElasticOvershootTransform extends ViewportTransform {
  ElasticOvershootTransform({
    this.peakScale = 1.12,
    this.minScale = 0.85,
    this.curvePower = 2,
  });

  /// Scale đỉnh ở tâm viewport (> 1 = overshoot).
  final double peakScale;

  /// Scale tối thiểu ở biên.
  final double minScale;

  /// Độ cong — số càng lớn, peak càng "nhọn" quanh tâm.
  final double curvePower;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final norm = ((itemCenter - center).abs() / (context.viewportSize / 2)).clamp(0.0, 1.0);
    // Bell curve: peak at norm=0, → minScale at norm=1
    final bell = math.pow(1 - norm, curvePower).toDouble();
    state.scale = minScale + (peakScale - minScale) * bell;
  }
}
