import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter/physics.dart';

/// Một ScrollPhysics mô phỏng hiệu ứng bật lại khi vượt quá giới hạn cuộn
class RubberSpringBackPhysics extends ScrollPhysics {
  final double overscrollResistance; // Càng nhỏ càng "nặng", khó kéo quá

  const RubberSpringBackPhysics({
    ScrollPhysics? parent,
    this.overscrollResistance = 0.3,
  }) : super(parent: parent);

  @override
  RubberSpringBackPhysics applyTo(ScrollPhysics? ancestor) {
    return RubberSpringBackPhysics(
      parent: buildParent(ancestor),
      overscrollResistance: overscrollResistance,
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final overscroll = value - position.pixels;

    // Kéo xuống quá min (trên cùng)
    if (value < position.minScrollExtent) {
      return overscroll * overscrollResistance;
    }

    // Kéo lên quá max (dưới cùng)
    if (value > position.maxScrollExtent) {
      return overscroll * overscrollResistance;
    }

    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final outOfRangeTop = position.pixels < position.minScrollExtent * overscrollResistance;
    final outOfRangeBottom = position.pixels > position.maxScrollExtent * overscrollResistance;

    if (outOfRangeTop || outOfRangeBottom) {
      final spring = SpringDescription(
        mass: 0.5,
        stiffness: 200.0,
        damping: 15.0,
      );

      final double end = outOfRangeTop ? position.minScrollExtent : position.maxScrollExtent;

      return ScrollSpringSimulation(
        spring,
        position.pixels,
        end,
        velocity,
        tolerance: tolerance,
      );
    }

    if (velocity.abs() >= tolerance.velocity) {
      return ClampingScrollSimulation(
        position: position.pixels,
        velocity: velocity,
        tolerance: tolerance,
      );
    }

    return null;
  }

  @override
  bool get allowImplicitScrolling => true;
}
