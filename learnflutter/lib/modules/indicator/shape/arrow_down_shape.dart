import 'dart:ui';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learnflutter/modules/indicator/paint/arrow_down_painter.dart';

class ArrowDownShape extends StatefulWidget {
  final double progress;
  final IndicatorState state;
  final Color color;
  final Size size; // 👈 thêm size tuỳ chỉnh
  final double bounce;
  const ArrowDownShape({
    super.key,
    required this.progress,
    required this.state,
    required this.color,
    this.size = const Size(24, 24), // 👈 default
    this.bounce = 0.0, // 👈 thêm bounce nếu cần
  });
  @override
  State<ArrowDownShape> createState() => _ArrowDownShapeState();
}

class _ArrowDownShapeState extends State<ArrowDownShape> {
  bool hasTriggeredHaptic = false;

  @override
  void didUpdateWidget(covariant ArrowDownShape oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state == IndicatorState.armed && !hasTriggeredHaptic) {
      hasTriggeredHaptic = true;
      HapticFeedback.mediumImpact(); // ✅ Rung nhẹ
    }

    // Reset khi quay về trạng thái ban đầu
    if (widget.state == IndicatorState.idle && hasTriggeredHaptic) {
      hasTriggeredHaptic = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 Ẩn hoàn toàn nếu chưa kéo (progress == 0) và chưa active
    if ((widget.state == IndicatorState.idle || widget.state == IndicatorState.settling) &&
        widget.progress == 0.0) {
      return const SizedBox.shrink();
    }

    // Phần còn lại giữ nguyên
    double scale = lerpDouble(0.2, 1.0, widget.progress)!;
    double opacity = 1.0;
    double rotation = 0.0;

    if (widget.state == IndicatorState.dragging || widget.state == IndicatorState.settling) {
      scale = lerpDouble(0.2, 1.0, widget.progress)!;
      opacity = widget.progress;
    } else if (widget.state == IndicatorState.armed) {
      scale = 1.0;
      opacity = 1.0;
    } else if (widget.state == IndicatorState.complete) {
      scale = lerpDouble(1.0, 1.4, widget.progress)!;
      opacity = lerpDouble(1.0, 0.0, widget.progress)!;
    }

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: (scale * widget.bounce).clamp(0.0, 1.4),
          child: CustomPaint(
            size: widget.size,
            painter: ArrowDownPainter(widget.color, widget.progress),
          ),
        ),
      ),
    );
  }
}
