import 'package:flutter/widgets.dart';
import 'timeline_logic.dart';
import 'timeline_effect.dart';

/// Bộ preset animation sẵn dùng - chỉ cần gọi 1 dòng.
class AnimPresets {
  /// Nhấn xuống → co lại → bung ra (bounce).
  static TimelineEffect pressBounce() => TimelineEffect(
        steps: [
          TimelineStep(start: 0, end: 0.25, from: 1, to: 0.88, curve: tlEaseOut),
          TimelineStep(start: 0.25, end: 1, from: 0.88, to: 1, curve: tlEaseInOut),
        ],
        builder: (v, child) => Transform.scale(scale: v, child: child),
      );

  /// Fade in kết hợp trượt từ dưới lên.
  static TimelineEffect fadeInSlide({double offsetY = 24}) => TimelineEffect(
        steps: [
          TimelineStep(start: 0, end: 1, from: 0, to: 1, curve: tlEaseOut),
        ],
        builder: (v, child) => Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * offsetY),
            child: child,
          ),
        ),
      );

  /// Scale in từ nhỏ lên.
  static TimelineEffect scaleIn({double minScale = 0.6}) => TimelineEffect(
        steps: [
          TimelineStep(start: 0, end: 1, from: minScale, to: 1, curve: tlEaseInOut),
        ],
        builder: (v, child) => Transform.scale(scale: v, child: child),
      );

  /// Multi-track: Scale + Opacity cùng lúc.
  static MultiTrackEffect scaleOpacity({
    double minScale = 0.8,
    double minOpacity = 0.0,
  }) {
    final scaleTrack = TimelineTrack([
      TimelineStep(start: 0, end: 1, from: minScale, to: 1, curve: tlEaseOut),
    ]);
    final opacityTrack = TimelineTrack([
      TimelineStep(start: 0, end: 0.6, from: minOpacity, to: 1, curve: tlEaseOut),
    ]);

    return MultiTrackEffect(
      builder: (t, child) => Opacity(
        opacity: opacityTrack.value(t).clamp(0.0, 1.0),
        child: Transform.scale(scale: scaleTrack.value(t), child: child),
      ),
    );
  }
}
