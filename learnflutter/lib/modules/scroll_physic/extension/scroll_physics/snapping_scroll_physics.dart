import 'package:flutter/material.dart';

class SnappingScrollPhysics extends ClampingScrollPhysics {
  final double itemDimension;

  /// Cuộn và snap lại theo 1 đơn vị chiều cao cố định (ví dụ item height)

  const SnappingScrollPhysics({required this.itemDimension, ScrollPhysics? parent}) : super(parent: parent);
  @override
  SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappingScrollPhysics(itemDimension: itemDimension, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Simulation? simulation = super.createBallisticSimulation(position, velocity);

    if (simulation == null || velocity.abs() < tolerance.velocity) {
      final double targetPixels = (position.pixels / itemDimension).roundToDouble() * itemDimension;
      if (targetPixels != position.pixels) {
        return ScrollSpringSimulation(
          spring,
          position.pixels,
          targetPixels,
          0,
          tolerance: tolerance,
        );
      }
      return null;
    }

    return simulation;
  }
}
