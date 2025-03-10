import 'package:flutter/material.dart';

class NoBounceScrollPhysics extends ScrollPhysics {
  const NoBounceScrollPhysics({super.parent});

  @override
  NoBounceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoBounceScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // If the scrolling is outside the bounds, prevent it (no bounce effect)
    if (value < position.minScrollExtent) {
      return value - position.minScrollExtent;
    } else if (value > position.maxScrollExtent) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }
}
