import 'package:flutter/widgets.dart';
import 'package:learnflutter/app/device_dimension.dart';

class SegmentedWidget extends LeafRenderObjectWidget {
  final double splitRatio; // Tỷ lệ phân chia
  final Color color1;
  final Color color2;

  SegmentedWidget({
    Key? key,
    required this.splitRatio,
    required this.color1,
    required this.color2,
  }) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SegmentedRenderBox(
      splitRatio: splitRatio,
      color1: color1,
      color2: color2,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant SegmentedRenderBox renderObject) {
    renderObject
      ..splitRatio = splitRatio
      ..color1 = color1
      ..color2 = color2;
  }
}

class SegmentedRenderBox extends RenderBox {
  double _splitRatio;
  Color _color1;
  Color _color2;

  SegmentedRenderBox({
    required double splitRatio,
    required Color color1,
    required Color color2,
  })  : _splitRatio = splitRatio,
        _color1 = color1,
        _color2 = color2;

  double get splitRatio => _splitRatio;
  set splitRatio(double value) {
    if (_splitRatio != value) {
      _splitRatio = value;
      markNeedsLayout();
    }
  }

  Color get color1 => _color1;
  set color1(Color value) {
    if (_color1 != value) {
      _color1 = value;
      markNeedsPaint();
    }
  }

  Color get color2 => _color2;
  set color2(Color value) {
    if (_color2 != value) {
      _color2 = value;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    // ; // Sử dụng toàn bộ không gian có sẵn
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final double splitPoint = size.width * _splitRatio;

    final Paint paint1 = Paint()..color = _color1;
    final Paint paint2 = Paint()..color = _color2;
    Path path1 = Path();
    final pointstart = Offset(0, 0);
    final pointcurve1 = Offset(52, -43);
    final pointcurve2 = Offset(88, -43);
    final pointend = Offset(140, 0);
    final pointendcurve1 = Offset(pointend.dx + 2, pointend.dy - 3);
    final pointendcurve2 = Offset(pointend.dx + 15, pointend.dy - 2);
    final pointend2 = Offset(pointendcurve2.dx + 15, pointend.dy - 2);
    final pointend2curve1 = Offset(pointend2.dx + 6, pointend2.dy - 13);
    final pointend2curve2 = Offset(pointend2curve1.dx + 4, pointend2curve1.dy - 9);
    final pointend3 = Offset(pointend2.dx + 40, pointstart.dy);
    final backgroundTriangleLine = Path()
      ..moveTo(pointstart.dx, pointstart.dy)
      ..cubicTo(pointcurve1.dx, pointcurve1.dy, pointcurve2.dx, pointcurve2.dy, pointend.dx, pointend.dy)
      ..cubicTo(pointendcurve1.dx, pointendcurve1.dy, pointendcurve2.dx, pointendcurve2.dy, pointend2.dx, pointend2.dy)
      ..cubicTo(pointend2curve1.dx, pointend2curve1.dy, pointend2curve2.dx, pointend2curve2.dy, pointend3.dy, 0);
    backgroundTriangleLine.close();
    context.canvas.drawPath(
      backgroundTriangleLine,
      paint1,

      // offset & Size(splitPoint, size.height), // Vẽ phần đầu tiên
      // paint1,
    );

    // context.canvas.drawRect(
    //   offset.translate(splitPoint, 0.0) & Size(size.width - splitPoint, size.height), // Vẽ phần thứ hai
    //   paint2,
    // );
  }
}
