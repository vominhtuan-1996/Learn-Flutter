import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GraphicsWidget extends LeafRenderObjectWidget {
  GraphicsWidget({
    Key? key,
    required this.barColor,
    required this.thumbColor,
    this.thumbSize = 20.0,
    this.strokeWidth = 8,
    this.strokeCap = StrokeCap.round,
    this.min = 0,
    this.max = 100,
    this.styleLabel = const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
    this.backGroundLabel = Colors.blue,
    this.onChanged,
    this.showLabel = true,
  }) : super(key: key);

  final Color barColor;
  final Color thumbColor;
  final double thumbSize;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final double min;
  final double max;
  final TextStyle styleLabel;
  final Color backGroundLabel;
  final ValueChanged<double>? onChanged;
  final bool showLabel;
  @override
  RenderGraphicsWidget createRenderObject(BuildContext context) {
    return RenderGraphicsWidget(
        barColor: barColor,
        thumbColor: thumbColor,
        thumbSize: thumbSize,
        strokeWidth: strokeWidth,
        strokeCap: strokeCap,
        min: min,
        max: max,
        styleLabel: styleLabel,
        backGroundLabel: backGroundLabel,
        onChanged: onChanged,
        showLabel: showLabel);
  }

  @override
  void updateRenderObject(BuildContext context, RenderGraphicsWidget renderObject) {
    renderObject
      ..barColor = barColor
      ..thumbColor = thumbColor
      ..strokeWidth = strokeWidth
      ..min = min
      ..max = max
      ..thumbSize = thumbSize
      .._backGroundLabel = backGroundLabel
      .._onChanged = onChanged
      .._showLabel = showLabel;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('barColor', barColor));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties.add(DoubleProperty('thumbSize', thumbSize));
    properties.add(DoubleProperty('strokeWidth', strokeWidth));
    properties.add(DoubleProperty('min', min));
    properties.add(DoubleProperty('max', max));
  }
}

class RenderGraphicsWidget extends RenderBox {
  RenderGraphicsWidget({
    required Color barColor,
    required Color thumbColor,
    required double thumbSize,
    required double strokeWidth,
    required StrokeCap strokeCap,
    required double min,
    required double max,
    required TextStyle styleLabel,
    required Color backGroundLabel,
    required bool showLabel,
    ValueChanged<double>? onChanged,
  })  : _barColor = barColor,
        _thumbColor = thumbColor,
        _thumbSize = thumbSize,
        _strokeWidth = strokeWidth,
        _strokeCap = strokeCap,
        _min = min,
        _max = max,
        _styleLabel = styleLabel,
        _backGroundLabel = backGroundLabel,
        _onChanged = onChanged,
        _showLabel = showLabel {
    // initialize the gesture recognizer
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

  double get strokeWidth => _strokeWidth;
  double _strokeWidth;
  set strokeWidth(double value) {
    if (_strokeWidth == value) return;
    _strokeWidth = value;
    markNeedsLayout();
  }

  StrokeCap get strokeCap => _strokeCap;
  StrokeCap _strokeCap;
  set strokeCap(StrokeCap value) {
    _strokeCap = value;
    markNeedsLayout();
  }

  double get min => _min;
  double _min;
  set min(double value) {
    _min = value;
    markNeedsLayout();
  }

  double get max => _max;
  double _max;
  set max(double value) {
    _max = value;
    markNeedsLayout();
  }

  TextStyle get styleLabel => _styleLabel;
  TextStyle _styleLabel;
  set styleLabel(TextStyle value) {
    _styleLabel = value;
    markNeedsLayout();
  }

  ValueChanged<double>? _onChanged;
  onChanged(ValueChanged<double>? value) {
    _onChanged = value;
    markNeedsLayout();
  }

  Color get backGroundLabel => _backGroundLabel;
  Color _backGroundLabel;
  set backGroundLabel(Color value) {
    if (_backGroundLabel == value) return;
    _backGroundLabel = value;
    markNeedsPaint();
  }

  bool get showLabel => _showLabel;
  bool _showLabel;
  set showLabel(bool value) {
    if (_showLabel == value) return;
    _showLabel = value;
    markNeedsPaint();
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

  late DragGestureRecognizer _drag;

  @override
  bool hitTestSelf(Offset position) => true;

  List<Offset> pointsMove = [];

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    // pointsMove = [];
    assert(debugHandleEvent(event, entry));
    if (event is PointerMoveEvent) {
      pointsMove.add(event.localPosition);
      markNeedsPaint();
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

  static double widthText = 0;
  @override
  void paint(PaintingContext context, Offset offset) async {
    final canvas = context.canvas;
    final barPaint = Paint()
      ..color = barColor.withOpacity(0.3)
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = _strokeWidth
      ..isAntiAlias = true;
    var point1 = pointsMove.isNotEmpty ? pointsMove.first : Offset.zero;
    for (int i = 0; i < pointsMove.length - 1; i++) {
      canvas.drawLine(pointsMove[i], pointsMove[i + 1], barPaint);
    }
    // for (var element in pointsMove) {
    //   canvas.drawLine(point1, element, barPaint);
    //   point1 = element;
    // }
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
