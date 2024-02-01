import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learnflutter/helpper/bitmap_utils.dart';

class ProgressBar extends LeafRenderObjectWidget {
  const ProgressBar({
    Key? key,
    required this.barColor,
    required this.thumbColor,
    this.thumbSize = 20.0,
  }) : super(key: key);

  final Color barColor;
  final Color thumbColor;
  final double thumbSize;

  @override
  RenderProgressBar createRenderObject(BuildContext context) {
    return RenderProgressBar(
      barColor: barColor,
      thumbColor: thumbColor,
      thumbSize: thumbSize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderProgressBar renderObject) {
    renderObject
      ..barColor = barColor
      ..thumbColor = thumbColor
      ..thumbSize = thumbSize;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('barColor', barColor));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties.add(DoubleProperty('thumbSize', thumbSize));
  }
}

class RenderProgressBar extends RenderBox {
  RenderProgressBar({
    required Color barColor,
    required Color thumbColor,
    required double thumbSize,
  })  : _barColor = barColor,
        _thumbColor = thumbColor,
        _thumbSize = thumbSize {
    // initialize the gesture recognizer
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = (DragStartDetails details) {
        _updateThumbPosition(details.localPosition);
      }
      ..onUpdate = (DragUpdateDetails details) {
        _updateThumbPosition(details.localPosition);
      };
  }

  void _updateThumbPosition(Offset localPosition) {
    var dx = localPosition.dx.clamp(0, size.width);
    _currentThumbValue = dx / size.width;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  Color get barColor => _barColor;
  Color _barColor;
  set barColor(Color value) {
    if (_barColor == value) return;
    _barColor = value;
    markNeedsPaint();
  }

  Color get thumbColor => _thumbColor;
  Color _thumbColor;
  set thumbColor(Color value) {
    if (_thumbColor == value) return;
    _thumbColor = value;
    markNeedsPaint();
  }

  double get thumbSize => _thumbSize;
  double _thumbSize;
  set thumbSize(double value) {
    if (_thumbSize == value) return;
    _thumbSize = value;
    markNeedsLayout();
  }

  static const _minDesiredWidth = 100.0;

  @override
  double computeMinIntrinsicWidth(double height) => _minDesiredWidth;

  @override
  double computeMaxIntrinsicWidth(double height) => _minDesiredWidth;

  @override
  double computeMinIntrinsicHeight(double width) => thumbSize;

  @override
  double computeMaxIntrinsicHeight(double width) => thumbSize;

  late HorizontalDragGestureRecognizer _drag;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final desiredWidth = constraints.maxWidth;
    final desiredHeight = thumbSize;
    final desiredSize = Size(desiredWidth, desiredHeight);
    return constraints.constrain(desiredSize);
  }

  double _currentThumbValue = 0.0;

  @override
  void paint(PaintingContext context, Offset offset) async {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // paint bar
    final barPaint = Paint()
      ..color = barColor
      ..strokeWidth = 5;
    final point1 = Offset(0, size.height / 2);
    final point2 = Offset(size.width, size.height / 2);
    canvas.drawLine(point1, point2, barPaint);
    // paint thumb
    final thumbPaint = Paint()..color = thumbColor;
    final thumbDx = _currentThumbValue * size.width;
    final center = Offset(thumbDx, size.height / 2);
    canvas.drawCircle(center, thumbSize / 2, thumbPaint);

    // triangle
    thumbPaint.color = Colors.blue;
    thumbPaint.strokeCap = StrokeCap.square;
    final backgroundTriangleLine = Path();
    //start
    backgroundTriangleLine.moveTo(thumbDx, (thumbSize));
    // point 1
    print(_currentThumbValue);
    Offset point1Triangle = Offset(thumbDx + (thumbSize / 2), (thumbSize * 2));
    backgroundTriangleLine.lineTo(point1Triangle.dx, point1Triangle.dy);
    // point 2
    Offset point2Triangle = Offset((thumbDx + size.width / 12) * _currentThumbValue - thumbSize, (point1Triangle.dy));
    backgroundTriangleLine.lineTo(point2Triangle.dx, point2Triangle.dy);
    // point 3
    Offset point3Triangle = Offset(point2Triangle.dx, (thumbSize * 6));
    backgroundTriangleLine.lineTo(point3Triangle.dx, point3Triangle.dy);
    // point 4
    Offset point4Triangle = Offset(thumbDx / 2, point3Triangle.dy);
    backgroundTriangleLine.lineTo(point4Triangle.dx + (thumbSize * 2), point4Triangle.dy);

    print(point4Triangle);
    // point 5
    // Offset point5Triangle = Offset(point4Triangle.dx, point4Triangle.dx - thumbDx);
    // backgroundTriangleLine.lineTo(point5Triangle.dx, point5Triangle.dy);
    // // point 6
    // Offset point6Triangle = Offset(point5Triangle.dx, point5Triangle.dx);
    // backgroundTriangleLine.lineTo(point6Triangle.dx, point6Triangle.dy);

    backgroundTriangleLine.close();
    canvas.drawPath(backgroundTriangleLine, thumbPaint);

    canvas.restore();
  }

//   Future<Uint8List> drawMarker({
//     required Size markerSize,
//     bool showInfoWindow = true,
//     double infoWindowBorderSize = 4,
//     double infoWindowBorderRadius = 10,
//     Color infoWindowBorderColor = Colors.blue,
//     Color infoWindowBackgroundColor = Colors.white,
//     String text = 'none',
//     Color textColor = Colors.blue,
//     double textSize = 20,
//     FontWeight textFontWeight = FontWeight.w500,
//     required String icon,
//     double iconSizeRatio = 0.3,
//     double borderSize = 0,
//     Color borderColor = Colors.yellow,
//     double footerSizeRatio = 0.2,
//     double footerWidthRatio = 1,
//     double footerHeightRatio = 1,
//   }) async {
//     // paint the text inside the rectangle
//     TextPainter painter;
//     painter = TextPainter(
//         textAlign: TextAlign.center,
//         textDirection: TextDirection.ltr,
//         maxLines: 1,
//         text: TextSpan(
//           text: text,
//           style: TextStyle(
//             overflow: TextOverflow.ellipsis,
//             color: textColor,
//             fontSize: textSize,
//             fontWeight: textFontWeight,
//           ),
//         ))
//       ..layout();

//     // decide width and height for marker
//     final width = painter.width > markerSize.width ? painter.width + 20 : markerSize.width;
//     final height = showInfoWindow ? markerSize.height : markerSize.height * iconSizeRatio;

//     // then split it to 3 pieces, 1 is rectangle on top, 1 is triangle on bottom, 1 is the icon
//     final iconSize = markerSize.height * iconSizeRatio;

//     final triangleSize = height * footerSizeRatio;
//     final triangleWith = triangleSize * footerWidthRatio;
//     final triangleHeight = triangleSize * footerHeightRatio;

//     // width and height of rectangle
//     final originRectWidth = width;
//     final originRectHeight = height - triangleSize - iconSize;
//     final rectWidth = originRectWidth - borderSize;
//     // final rectHeight = originRectHeight - borderSize;

//     // first of all, initialize canvas
//     PictureRecorder p = PictureRecorder();
//     Canvas canvas = Canvas(p, Rect.fromCenter(center: const Offset(0, 0), width: width, height: height));

//     // get the icon
//     // final ByteData iconData = await rootBundle.load(icon);
//     // final iconD = await decodeImageFromList(Uint8List.view(iconData.buffer));
//     final iconD = await decodeImageFromList(await _getBytesFromAsset(icon, iconSize.toInt()));
//     // paint
//     final paint = Paint();

//     // paint the border
//     if (borderSize != 0) {
//       paint
//         ..color = borderColor
//         ..style = PaintingStyle.fill
//         ..strokeCap = StrokeCap.round;

//       // rectangle (info window)
//       if (showInfoWindow) {
//         Rect rectBackground = Rect.fromPoints(const Offset(0, 0), Offset(originRectWidth, originRectHeight));
//         Radius radius = Radius.circular(infoWindowBorderRadius);

//         canvas.drawRRect(RRect.fromRectAndRadius(rectBackground, radius), paint);

//         // triangle
//         paint.strokeCap = StrokeCap.square;

//         final backgroundTriangleLine = Path();

//         backgroundTriangleLine.moveTo(((originRectWidth - (triangleWith / 2 + borderSize)) / 2),
//             (originRectHeight + triangleHeight + borderSize / 2));
//         backgroundTriangleLine.lineTo(originRectWidth / 2, height - iconSize - triangleSize - borderSize);
//         backgroundTriangleLine.lineTo(((originRectWidth + triangleWith / 2 + borderSize) / 2),
//             (originRectHeight + triangleHeight + borderSize / 2));
//         backgroundTriangleLine.close();

//         canvas.drawPath(backgroundTriangleLine, paint);
//       }

//       // image
//       final srcBg = Offset((width - iconSize - borderSize) / 2, height - iconSize) &
//           Size(iconD.width.toDouble(), iconD.height.toDouble());
//       final dstBg = Offset((width - iconSize - borderSize) / 2, height - iconSize - borderSize) &
//           Size(iconSize + borderSize, iconSize + borderSize);

//       canvas.drawImageNine(
//         iconD,
//         srcBg,
//         dstBg,
//         Paint()..colorFilter = ColorFilter.mode(borderColor, BlendMode.srcATop),
//       );
//     }

//     // reset the paint
//     paint
//       ..color = infoWindowBackgroundColor
//       ..strokeWidth = infoWindowBorderSize
//       ..style = PaintingStyle.fill
//       ..strokeCap = StrokeCap.round;

//     if (showInfoWindow) {
//       // paint the background rectangle
//       Rect rectBackground = Rect.fromPoints(
//           Offset(borderSize / 2, borderSize / 2),
//           Offset(rectWidth - infoWindowBorderSize / 2 + borderSize / 2,
//               height - iconSize - triangleSize - borderSize / 2));
//       Radius radius = Radius.circular(infoWindowBorderRadius);

//       canvas.drawRRect(RRect.fromRectAndRadius(rectBackground, radius), paint);

//       // then paint its stroke
//       paint.style = PaintingStyle.stroke;
//       paint.color = infoWindowBorderColor;

//       Rect lineRect = Rect.fromPoints(
//           Offset((infoWindowBorderSize + borderSize) / 2,
//               (infoWindowBorderSize + borderSize) / 2 - (borderSize == 0 ? 0 : infoWindowBorderSize) / 2),
//           Offset(
//               rectWidth - (infoWindowBorderSize - borderSize) / 2, height - iconSize - triangleSize - borderSize / 2));
//       canvas.drawRRect(RRect.fromRectAndRadius(lineRect, radius), paint);

//       // paint the triangle

//       // then paint the stroke for the triangle
//       paint.style = PaintingStyle.fill;
//       paint.color = infoWindowBorderColor;

//       final lineTriangle = Path();

//       lineTriangle.moveTo(
//           ((originRectWidth - triangleWith / 2) / 2), (originRectHeight + triangleHeight + infoWindowBorderSize));
//       lineTriangle.lineTo(width / 2, height - iconSize - triangleSize - borderSize / 2);
//       lineTriangle.lineTo(
//           ((originRectWidth + triangleWith / 2) / 2), (originRectHeight + triangleHeight + infoWindowBorderSize));
//       lineTriangle.close();

//       // we don't need the last line, so we don't close
//       canvas.drawPath(lineTriangle, paint);

//       // this is where the text is
//       Offset position = Offset(
//         originRectWidth / 2 - painter.width / 2,
//         originRectHeight / 2 - textSize / 2 - infoWindowBorderSize,
//       );
//       painter.layout();
//       painter.paint(canvas, position);
//     }

//     // the last one is paint the icon in the bottom

//     // draw the icon back ground
//     final src =
//         Offset((width - iconSize) / 2, height - iconSize) & Size(iconD.width.toDouble(), iconD.height.toDouble());
//     final dst = Offset((width - iconSize) / 2, height - iconSize - borderSize / 2) & Size(iconSize, iconSize);

//     canvas.drawImageNine(iconD, src, dst, Paint());

//     // then parse it to Uint8List and return
//     final result = await p.endRecording().toImage(width.toInt(), height.toInt());
//     final img = await result.toByteData(format: ImageByteFormat.png);

//     return img!.buffer.asUint8List();
//   }
// }

  // @override
  // void paint(PaintingContext context, Offset offset) {
  //   final double value = _state.positionController.value;
  //   final double? secondaryValue = _secondaryTrackValue;

  //   // The visual position is the position of the thumb from 0 to 1 from left
  //   // to right. In left to right, this is the same as the value, but it is
  //   // reversed for right to left text.
  //   final double visualPosition;
  //   final double? secondaryVisualPosition;
  //   switch (textDirection) {
  //     case TextDirection.rtl:
  //       visualPosition = 1.0 - value;
  //       secondaryVisualPosition = (secondaryValue != null) ? (1.0 - secondaryValue) : null;
  //     case TextDirection.ltr:
  //       visualPosition = value;
  //       secondaryVisualPosition = (secondaryValue != null) ? secondaryValue : null;
  //   }

  //   final Rect trackRect = _sliderTheme.trackShape!.getPreferredRect(
  //     parentBox: this,
  //     offset: offset,
  //     sliderTheme: _sliderTheme,
  //     isDiscrete: isDiscrete,
  //   );
  //   final Offset thumbCenter = Offset(trackRect.left + visualPosition * trackRect.width, trackRect.center.dy);
  //   if (isInteractive) {
  //     final Size overlaySize = sliderTheme.overlayShape!.getPreferredSize(isInteractive, false);
  //     overlayRect = Rect.fromCircle(center: thumbCenter, radius: overlaySize.width / 2.0);
  //   }
  //   final Offset? secondaryOffset = (secondaryVisualPosition != null) ? Offset(trackRect.left + secondaryVisualPosition * trackRect.width, trackRect.center.dy) : null;

  //   _sliderTheme.trackShape!.paint(
  //     context,
  //     offset,
  //     parentBox: this,
  //     sliderTheme: _sliderTheme,
  //     enableAnimation: _enableAnimation,
  //     textDirection: _textDirection,
  //     thumbCenter: thumbCenter,
  //     secondaryOffset: secondaryOffset,
  //     isDiscrete: isDiscrete,
  //     isEnabled: isInteractive,
  //   );

  //   if (!_overlayAnimation.isDismissed) {
  //     _sliderTheme.overlayShape!.paint(
  //       context,
  //       thumbCenter,
  //       activationAnimation: _overlayAnimation,
  //       enableAnimation: _enableAnimation,
  //       isDiscrete: isDiscrete,
  //       labelPainter: _labelPainter,
  //       parentBox: this,
  //       sliderTheme: _sliderTheme,
  //       textDirection: _textDirection,
  //       value: _value,
  //       textScaleFactor: _textScaleFactor,
  //       sizeWithOverflow: screenSize.isEmpty ? size : screenSize,
  //     );
  //   }

  //   if (isDiscrete) {
  //     final double tickMarkWidth = _sliderTheme.tickMarkShape!
  //         .getPreferredSize(
  //           isEnabled: isInteractive,
  //           sliderTheme: _sliderTheme,
  //         )
  //         .width;
  //     final double padding = trackRect.height;
  //     final double adjustedTrackWidth = trackRect.width - padding;
  //     // If the tick marks would be too dense, don't bother painting them.
  //     if (adjustedTrackWidth / divisions! >= 3.0 * tickMarkWidth) {
  //       final double dy = trackRect.center.dy;
  //       for (int i = 0; i <= divisions!; i++) {
  //         final double value = i / divisions!;
  //         // The ticks are mapped to be within the track, so the tick mark width
  //         // must be subtracted from the track width.
  //         final double dx = trackRect.left + value * adjustedTrackWidth + padding / 2;
  //         final Offset tickMarkOffset = Offset(dx, dy);
  //         _sliderTheme.tickMarkShape!.paint(
  //           context,
  //           tickMarkOffset,
  //           parentBox: this,
  //           sliderTheme: _sliderTheme,
  //           enableAnimation: _enableAnimation,
  //           textDirection: _textDirection,
  //           thumbCenter: thumbCenter,
  //           isEnabled: isInteractive,
  //         );
  //       }
  //     }
  //   }

  //   if (isInteractive && label != null && !_valueIndicatorAnimation.isDismissed) {
  //     if (showValueIndicator) {
  //       _state.paintValueIndicator = (PaintingContext context, Offset offset) {
  //         if (attached) {
  //           _sliderTheme.valueIndicatorShape!.paint(
  //             context,
  //             offset + thumbCenter,
  //             activationAnimation: _valueIndicatorAnimation,
  //             enableAnimation: _enableAnimation,
  //             isDiscrete: isDiscrete,
  //             labelPainter: _labelPainter,
  //             parentBox: this,
  //             sliderTheme: _sliderTheme,
  //             textDirection: _textDirection,
  //             value: _value,
  //             textScaleFactor: textScaleFactor,
  //             sizeWithOverflow: screenSize.isEmpty ? size : screenSize,
  //           );
  //         }
  //       };
  //     }
  //   }

  //   _sliderTheme.thumbShape!.paint(
  //     context,
  //     thumbCenter,
  //     activationAnimation: _overlayAnimation,
  //     enableAnimation: _enableAnimation,
  //     isDiscrete: isDiscrete,
  //     labelPainter: _labelPainter,
  //     parentBox: this,
  //     sliderTheme: _sliderTheme,
  //     textDirection: _textDirection,
  //     value: _value,
  //     textScaleFactor: textScaleFactor,
  //     sizeWithOverflow: screenSize.isEmpty ? size : screenSize,
  //   );
  // }

  @override
  bool get isRepaintBoundary => true;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    // description
    config.textDirection = TextDirection.ltr;
    config.label = 'Progress bar';
    config.value = '${(_currentThumbValue * 100).round()}%';

    // increase action
    config.onIncrease = increaseAction;
    final increased = _currentThumbValue + _semanticActionUnit;
    config.increasedValue = '${((increased).clamp(0.0, 1.0) * 100).round()}%';

    // descrease action
    config.onDecrease = decreaseAction;
    final decreased = _currentThumbValue - _semanticActionUnit;
    config.decreasedValue = '${((decreased).clamp(0.0, 1.0) * 100).round()}%';
  }

  static const double _semanticActionUnit = 0.05;

  void increaseAction() {
    final newValue = _currentThumbValue + _semanticActionUnit;
    _currentThumbValue = (newValue).clamp(0.0, 1.0);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  void decreaseAction() {
    final newValue = _currentThumbValue - _semanticActionUnit;
    _currentThumbValue = (newValue).clamp(0.0, 1.0);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }
}
