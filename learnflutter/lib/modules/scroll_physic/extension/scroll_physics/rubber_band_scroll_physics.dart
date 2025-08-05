import 'package:flutter/widgets.dart';

class RubberBandScrollPhysics extends BouncingScrollPhysics {
  final double overscrollResistance; // Giá trị càng nhỏ thì càng căng
  /// Đàn hồi mạnh hơn khi cuộn quá giới hạn
  const RubberBandScrollPhysics({
    ScrollPhysics? parent,
    this.overscrollResistance = 0.2, // default: lực cản 20%
  }) : super(parent: parent);

  @override
  RubberBandScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return RubberBandScrollPhysics(
      parent: buildParent(ancestor),
      overscrollResistance: overscrollResistance,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Kéo quá max
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return (value - position.pixels) * overscrollResistance;
    }

    // Kéo quá min
    if (value > position.pixels && position.pixels >= position.maxScrollExtent) {
      return (value - position.pixels) * overscrollResistance;
    }

    // Đã vượt qua cả hai ranh giới
    if (value < position.minScrollExtent && position.pixels < position.minScrollExtent) {
      return 0.0;
    }

    if (value > position.maxScrollExtent && position.pixels > position.maxScrollExtent) {
      return 0.0;
    }

    return 0.0;
  }
}
