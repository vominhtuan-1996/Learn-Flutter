import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learnflutter/utils_helper/utils_helper.dart';

class ProgressBar extends LeafRenderObjectWidget {
  const ProgressBar({
    super.key,
    required this.barColor,
    required this.thumbColor,
    this.thumbSize = 20.0,
    this.strokeWidth = 8,
    this.strokeCap = StrokeCap.round,
    this.min = 0,
    this.max = 100,
    this.styleLabel =
        const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
    this.backGroundLabel = Colors.blue,
    this.onChanged,
    this.showLabel = true,
    required this.initValue,
  })  : assert(initValue <= max, 'giá trị ban đầu phải bé hơn giá trị max'),
        assert(initValue >= min, 'giá trị ban đầu phải lớn hơn giá trị min');

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
  final double initValue;
  @override
  RenderProgressBar createRenderObject(BuildContext context) {
    return RenderProgressBar(
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
        showLabel: showLabel,
        initValue: initValue);
  }

  @override
  void updateRenderObject(BuildContext context, RenderProgressBar renderObject) {
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

class RenderProgressBar extends RenderBox {
  RenderProgressBar({
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
    required double initValue,
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
        _showLabel = showLabel,
        _currentThumbValue = initValue / max {
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
    _currentThumbValue = (dx / size.width);
    if (_onChanged != null) {
      _onChanged!(_currentThumbValue * max);
    }
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

  double get initValue => _currentThumbValue;
  double _currentThumbValue;
  set initValue(double value) {
    _currentThumbValue = value / max;
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

  late HorizontalDragGestureRecognizer _drag;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
      markNeedsLayout();
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

  // double currentThumbValue = _initValue ??  0.0;

  static double widthText = 0;
  @override
  void paint(PaintingContext context, Offset offset) async {
    // _currentThumbValue = _currentThumbValue * (initValue / max);
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    String value = _currentThumbValue == 0
        ? min.toStringAsFixed(0)
        : (_currentThumbValue * _max).toStringAsFixed(0);
    widthText = UtilsHelper.getTextWidth(text: value, textStyle: styleLabel);

    TextPainter painter;
    painter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: value,
        style: styleLabel,
      ),
    )..layout();
    final thumbDx = _currentThumbValue * size.width;
    final center = Offset(thumbDx, size.height / 2);
    // paint bar
    final barPaint = Paint()
      ..color = barColor.withOpacity(0.3)
      ..strokeWidth = _strokeWidth
      ..strokeCap = _strokeCap;
    final point1 = Offset(0, size.height / 2);
    final point2 = Offset(size.width, size.height / 2);
    canvas.drawLine(point1, point2, barPaint);

    // paint bar
    final barPaintActive = Paint()
      ..color = barColor
      ..strokeWidth = _strokeWidth
      ..strokeCap = _strokeCap;

    final point1Active = Offset(0, size.height / 2);
    final point2Active = Offset(center.dx, size.height / 2);
    canvas.drawLine(point1Active, point2Active, barPaintActive);

    // paint thumb
    final thumbPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = _strokeWidth;

    // final pathThumb = Path();
    final point1pathThumb = Offset(center.dx, center.dy - size.height / 2);
    final point2pathThumb = Offset(center.dx, center.dy + size.height / 2);
    canvas.drawLine(point1pathThumb, point2pathThumb, thumbPaint);

    final thumbFillPaint = Paint()
      ..color = thumbColor
      ..strokeWidth = _strokeWidth * 0.8
      ..strokeCap = _strokeCap;

    // final pathThumb = Path();
    final point1paththumbFillPaint = Offset(center.dx, center.dy - (size.height / 2 * 0.6));
    final point2paththumbFillPaint = Offset(center.dx, center.dy + (size.height / 2) * 0.6);
    canvas.drawLine(point1paththumbFillPaint, point2paththumbFillPaint, thumbFillPaint);
    if (showLabel) {
      painter.paint(
          canvas,
          Offset(center.dx - (widthText / 2) - (widthText / 24 * _currentThumbValue),
              point1pathThumb.dy - thumbSize));
    }
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
