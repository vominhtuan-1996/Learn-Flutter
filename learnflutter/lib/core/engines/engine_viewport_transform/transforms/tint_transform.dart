import 'package:flutter/material.dart';

import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_transform.dart';

/// Phủ một lớp màu (tint) lên item, cường độ alpha tăng theo khoảng cách tới tâm.
class TintTransform extends ViewportTransform {
  TintTransform({this.color = Colors.black, this.maxAlpha = 0.55});

  final Color color;

  /// Alpha tối đa của lớp tint khi item ở biên (0..1).
  final double maxAlpha;

  @override
  void apply(TransformState state, ViewportItem item, ViewportContext context) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final dist = (itemCenter - center).abs();
    final normalized = (dist / (context.viewportSize / 2)).clamp(0.0, 1.0);
    final a = (normalized * maxAlpha * 255).round();
    state.tintARGB = color.withAlpha(a).value;
  }
}
