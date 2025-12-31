import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class LuxuryCardStackController extends ChangeNotifier {
  late AnimationController _dragAnim;
  late AnimationController _dropAnim;

  double dragX = 0;
  double dropY = 0;
  double dropScale = 1.0;
  double dropShadow = 1.0;

  LuxuryCardStackController({required TickerProvider vsync}) {
    _dragAnim = AnimationController.unbounded(vsync: vsync)
      ..addListener(() {
        dragX = _dragAnim.value;
        notifyListeners();
      });

    _dropAnim = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 420),
    )..addListener(() {
        final t = Curves.easeIn.transform(_dropAnim.value);

        dropY = lerpDouble(0, 300, t)!;
        dropScale = lerpDouble(1.0, 0.92, t)!;
        dropShadow = lerpDouble(1.0, 0.4, t)!;

        notifyListeners();
      });
  }

  void updateDrag(double dx) {
    dragX += dx;
    _dragAnim.value = dragX;
  }

  void updateVerticalDrag(double dy) {
    // chỉ cho kéo xuống, không kéo lên
    dragX = 0;
    dropY = (dropY + dy).clamp(0, 300);
    notifyListeners();
  }

  Future<void> snapBack(double velocity) async {
    final spring = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 360,
        damping: 32,
      ),
      dragX,
      0,
      velocity,
    );
    await _dragAnim.animateWith(spring);
  }

  Future<void> snapBackVertical(double velocity) async {
    final spring = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 360,
        damping: 32,
      ),
      dropY,
      0,
      velocity,
    );

    await _dropAnim.animateWith(spring);
  }

  Future<void> dropDown() async {
    await _dropAnim.forward(from: 0);

    // reset state
    dragX = 0;
    dropY = 0;
    dropScale = 1.0;
    dropShadow = 1.0;

    _dragAnim.value = 0;
    _dropAnim.value = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _dragAnim.dispose();
    _dropAnim.dispose();
    super.dispose();
  }
}
