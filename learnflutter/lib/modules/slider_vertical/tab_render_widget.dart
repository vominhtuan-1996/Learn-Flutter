
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TabRenderWidget extends LeafRenderObjectWidget {
  const TabRenderWidget({
    super.key,
    required this.tabColor,
    required this.thumbColor,
    this.thumbSize = 20.0,
  });

  final Color tabColor;
  final Color thumbColor;
  final double thumbSize;

  @override
  RenderTabBar createRenderObject(BuildContext context) {
    return RenderTabBar(
      tabColor: tabColor,
      thumbColor: thumbColor,
      thumbSize: thumbSize,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTabBar renderObject) {
    renderObject
      ..tabColor = tabColor
      ..thumbColor = thumbColor
      ..thumbSize = thumbSize;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('tabColor', tabColor));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties.add(DoubleProperty('thumbSize', thumbSize));
  }
}

class RenderTabBar extends RenderBox {
  RenderTabBar({
    required Color tabColor,
    required Color thumbColor,
    required double thumbSize,
  })  : _tabColor = tabColor,
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

  Color get tabColor => _tabColor;
  Color _tabColor;
  set tabColor(Color value) {
    if (_tabColor == value) return;
    _tabColor = value;
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
    // canvas.translate(offset.dx, offset.dy);

    // paint bar
    final barPaint = Paint()
      ..color = tabColor
      ..strokeWidth = 5;

    // final point2 = Offset(size.width, size.height / 2);
    // canvas.drawLine(point1, point2, barPaint);
    var widthtemp = 45;
    final backgroundTriangleLine = Path();
    //1
    const point1 = Offset.zero;
    backgroundTriangleLine.moveTo(point1.dx, point1.dy);
    //1+
    final point1plus = Offset(point1.dx + widthtemp / 2, -30);
    print(point1plus);

    // backgroundTriangleLine.lineTo(point1plus.dx, point1plus.dy);
    //2
    final point2 = Offset(point1.dx + widthtemp, point1plus.dy - 30);
    print(point2);
    backgroundTriangleLine.lineTo(point2.dx, point2.dy);
    //
    // 2+
    final point2plust = Offset(point2.dx + 40, size.height / 2 - 60);
    backgroundTriangleLine.cubicTo(point1.dx, point1.dy, point1plus.dx + 25, point1plus.dy + 25, point2.dx, point2.dy);
    // 3
    final point3 = Offset(point2.dx + 30, size.height / 2 - 70);
    print(point3);

    // backgroundTriangleLine.lineTo(point3.dx, point3.dy);
    backgroundTriangleLine.cubicTo(point2.dx, point2.dy, point2plust.dx, point2plust.dy, point3.dx, point3.dy);
    // 4
    final point4 = Offset(point2.dx + widthtemp * 4, point3.dy);
    print(point4);
    backgroundTriangleLine.lineTo(point4.dx, point4.dy);
    // 5
    final point5 = Offset(point4.dx, point2.dy);
    print(point5);
    backgroundTriangleLine.lineTo(point5.dx, point5.dy);
    // 5+
    final point5plus = Offset(point5.dx + widthtemp / 2, point1plus.dy);
    print(point5plus);
    backgroundTriangleLine.lineTo(point5plus.dx, point5plus.dy);
    //6
    final point6 = Offset(point5plus.dx + widthtemp / 2, point1.dy);
    print(point6);
    backgroundTriangleLine.lineTo(point6.dx, point6.dy);
    // final scale = 2;
    // final pointstart = Offset(0, 0);
    // final pointcurve1 = Offset(52, -43);
    // final pointcurve2 = Offset(88, -43);
    // final pointend = Offset(140, 0);

    // // final point2 = Offset(pointend.dx + 30, pointend.dy);

    // final pointendcurve1 = Offset(pointend.dx + 2, pointend.dy - 3);
    // final pointendcurve2 = Offset(pointend.dx + 15, pointend.dy - 2);
    // final pointend2 = Offset(pointendcurve2.dx + 15, pointend.dy - 2);

    // final pointend2curve1 = Offset(pointend2.dx + 6, pointend2.dy - 13);
    // final pointend2curve2 = Offset(pointend2curve1.dx + 4, pointend2curve1.dy - 9);
    // final pointend3 = Offset(pointend2.dx + 40, pointstart.dy);

    // final backgroundTriangleLine = Path()
    //   ..moveTo(pointstart.dx, pointstart.dy)
    //   ..cubicTo(pointcurve1.dx * scale, pointcurve1.dy * scale, pointcurve2.dx * scale, pointcurve2.dy * scale, pointend.dx * scale, pointend.dy * scale);
    // ..cubicTo(pointendcurve1.dx, pointendcurve1.dy, pointendcurve2.dx, pointendcurve2.dy, pointend2.dx, pointend2.dy)
    // ..cubicTo(pointend2curve1.dx * scale, pointend2curve1.dy * scale, pointend2curve2.dx * scale, pointend2curve2.dy * scale, pointend3.dy * scale, 0);
    backgroundTriangleLine.close();
    // backgroundTriangleLine.addArc(rect, startAngle, sweepAngle);
    canvas.drawPath(backgroundTriangleLine, barPaint);
    // paint thumb

    // // triangle
    // thumbPaint.color = Colors.blue;
    // thumbPaint.strokeCap = StrokeCap.square;
    // final backgroundTriangleLine = Path();
    // //start
    // backgroundTriangleLine.moveTo(thumbDx, (thumbSize));
    // // point 1
    // print(_currentThumbValue);
    // Offset point1Triangle = Offset(thumbDx + (thumbSize / 2), (thumbSize * 2));
    // backgroundTriangleLine.lineTo(point1Triangle.dx, point1Triangle.dy);
    // // point 2
    // Offset point2Triangle = Offset((thumbDx + size.width / 12) * _currentThumbValue - thumbSize, (point1Triangle.dy));
    // backgroundTriangleLine.lineTo(point2Triangle.dx, point2Triangle.dy);
    // // point 3
    // Offset point3Triangle = Offset(point2Triangle.dx, (thumbSize * 6));
    // backgroundTriangleLine.lineTo(point3Triangle.dx, point3Triangle.dy);
    // // point 4
    // Offset point4Triangle = Offset(thumbDx / 2, point3Triangle.dy);
    // backgroundTriangleLine.lineTo(point4Triangle.dx + (thumbSize * 2), point4Triangle.dy);

    // // print(point4Triangle);
    // // point 5
    // // Offset point5Triangle = Offset(point4Triangle.dx, point4Triangle.dx - thumbDx);
    // // backgroundTriangleLine.lineTo(point5Triangle.dx, point5Triangle.dy);
    // // // point 6
    // // Offset point6Triangle = Offset(point5Triangle.dx, point5Triangle.dx);
    // // backgroundTriangleLine.lineTo(point6Triangle.dx, point6Triangle.dy);

    // backgroundTriangleLine.close();
    // canvas.drawPath(backgroundTriangleLine, thumbPaint);

    canvas.restore();
  }

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
