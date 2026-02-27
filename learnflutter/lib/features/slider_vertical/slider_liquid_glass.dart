import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSoftSlider extends StatefulWidget {
  double value;
  final double min;
  final double max;
  final bool showLabel;
  final bool enableHaptic;
  final bool useGradientTrack;
  final ValueChanged<double> onChanged;

  CustomSoftSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.showLabel = true,
    this.enableHaptic = true,
    this.useGradientTrack = false,
  });

  @override
  State<CustomSoftSlider> createState() => _CustomSoftSliderState();
}

class _CustomSoftSliderState extends State<CustomSoftSlider> {
  double? lastHapticTrigger;

  void _handleChanged(double newValue) {
    setState(() {
      if (widget.enableHaptic) {
        if (newValue == widget.min || newValue == widget.max) {
          if (lastHapticTrigger == null || (newValue - lastHapticTrigger!).abs() >= 1) {
            HapticFeedback.lightImpact();
            lastHapticTrigger = newValue;
          }
        }
      }
      widget.value = newValue;
      widget.onChanged(newValue); // Gọi callback sau khi setState nếu cần
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        thumbShape: const _ShadowRectThumbShape(
          borderColor: Colors.transparent,
          size: Size(36, 24),
          borderRadius: 12,
          shadowBlur: 1,
          shadowYOffset: 4,
        ),
        overlayColor: Colors.transparent,
        trackShape: CenteredThumbTrackShape(),
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        showValueIndicator: widget.showLabel ? ShowValueIndicator.always : ShowValueIndicator.never,
        activeTrackColor: Colors.blue,
        inactiveTrackColor: Colors.grey.shade300,
        thumbColor: Colors.white,
      ),
      child: Slider(
        min: widget.min,
        max: widget.max,
        value: widget.value,
        label: widget.showLabel ? widget.value.toStringAsFixed(0) : null,
        onChanged: _handleChanged,
      ),
    );
  }
}

class _ShadowRectThumbShape extends SliderComponentShape {
  final Size size;
  final double borderRadius;
  final Color borderColor;
  final double shadowBlur;
  final double shadowYOffset;

  const _ShadowRectThumbShape({
    this.size = const Size(28, 18),
    this.borderRadius = 6,
    this.borderColor = const Color(0xFFBDBDBD),
    this.shadowBlur = 6,
    this.shadowYOffset = 2,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => size;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    final rect = Rect.fromCenter(center: center, width: size.width, height: size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlur);
    canvas.drawRRect(rrect, shadowPaint); // no shift

    // Background
    final fillPaint = Paint()..color = sliderTheme.thumbColor ?? Colors.white;
    canvas.drawRRect(rrect, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);
  }
}

class _GradientTrackShape extends RoundedRectSliderTrackShape {
  const _GradientTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    double additionalActiveTrackHeight = 0,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    required RenderBox parentBox,
    Offset? secondaryOffset,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required Offset thumbCenter,
  }) {
    final canvas = context.canvas;

    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackLeft = offset.dx;
    final trackTop = thumbCenter.dy - trackHeight / 2;
    final trackRight = trackLeft + parentBox.size.width;
    final trackRadius = Radius.circular(trackHeight / 2);

    final activeTrackRect = Rect.fromLTRB(
      trackLeft,
      trackTop,
      thumbCenter.dx,
      trackTop + trackHeight,
    );

    final inactiveTrackRect = Rect.fromLTRB(
      thumbCenter.dx,
      trackTop,
      trackRight,
      trackTop + trackHeight,
    );

    // 🎨 Active Paint (Gradient or solid color)
    final activePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          sliderTheme.activeTrackColor ?? Colors.blue,
          sliderTheme.activeTrackColor?.withOpacity(0.7) ?? Colors.blueAccent,
        ],
      ).createShader(activeTrackRect);

    // 🎨 Inactive Paint
    final inactivePaint = Paint()..color = sliderTheme.inactiveTrackColor ?? Colors.grey;

    // 🟦 Vẽ phần track từ đầu tới thumb (active)
    canvas.drawRRect(
      RRect.fromRectAndRadius(activeTrackRect, trackRadius),
      activePaint,
    );

    // ⬜️ Vẽ phần còn lại (inactive)
    canvas.drawRRect(
      RRect.fromRectAndRadius(inactiveTrackRect, trackRadius),
      inactivePaint,
    );
  }
}

class CenteredThumbTrackShape extends RoundedRectSliderTrackShape {
  final double thumbWidth;

  const CenteredThumbTrackShape({this.thumbWidth = 36});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    double additionalActiveTrackHeight = 0,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    required RenderBox parentBox,
    Offset? secondaryOffset,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required Offset thumbCenter,
  }) {
    // Lùi start điểm của track lại một nửa thumb
    final double trackLeft = offset.dx + thumbWidth / 2;
    final double trackWidth = parentBox.size.width - thumbWidth;

    final Rect trackRect = Rect.fromLTWH(
      trackLeft,
      offset.dy + (parentBox.size.height - sliderTheme.trackHeight!) / 2,
      trackWidth,
      sliderTheme.trackHeight!,
    );

    final Paint activePaint = Paint()
      ..color = sliderTheme.activeTrackColor!
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.square;
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final Radius trackRadius = Radius.circular(sliderTheme.trackHeight! / 2);

    final RRect leftTrackSegment = RRect.fromLTRBR(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
      trackRadius,
    );

    final RRect rightTrackSegment = RRect.fromLTRBR(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      trackRadius,
    );

    context.canvas.drawRRect(leftTrackSegment, activePaint);
    context.canvas.drawRRect(rightTrackSegment, inactivePaint);
  }
}

class CenteredValueIndicatorShape extends SliderComponentShape {
  final double width;
  final double height;
  final double borderRadius;
  final Color color;
  final TextStyle textStyle;

  const CenteredValueIndicatorShape({
    this.width = 48,
    this.height = 28,
    this.borderRadius = 12,
    this.color = Colors.blue,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    final paint = Paint()..color = color;
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.translate(0, -height), width: width, height: height),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rect, paint);

    labelPainter.paint(
      canvas,
      Offset(
        center.dx - (labelPainter.width / 2),
        center.dy - height - (labelPainter.height / 2) + 6,
      ),
    );
  }
}

class CustomPaddleValueIndicatorShape extends SliderComponentShape {
  final double width;
  final double height;
  final Color color;
  final double borderRadius;

  const CustomPaddleValueIndicatorShape({
    this.width = 48,
    this.height = 32,
    this.color = Colors.blue,
    this.borderRadius = 12,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Lấy progress từ activation animation (0 -> 1)
    final double t = activationAnimation.value;
    final double scale = lerpDouble(0.5, 1.0, Curves.easeOut.transform(t))!;
    final double opacity = lerpDouble(0.0, 1.0, t)!;

    final Paint paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final double boxWidth = width * scale;
    final double boxHeight = height * scale;

    final Rect rect = Rect.fromCenter(
      center: center.translate(0, -boxHeight),
      width: boxWidth,
      height: boxHeight,
    );

    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius * scale));

    canvas.drawRRect(rrect, paint);

    // Vẽ text label (value)
    final double textX = center.dx - (labelPainter.width / 2);
    final double textY = rect.top + (boxHeight - labelPainter.height) / 2;

    labelPainter.paint(canvas, Offset(textX, textY));
  }
}
