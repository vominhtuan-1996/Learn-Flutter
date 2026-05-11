import 'package:learnflutter/core/animation/core_anim/core_anim.dart';

/// Model quản lý animation state cho từng item trong list.
class ListItemAnim {
  final CoreAnimController ctrl = CoreAnimController(value: 1.0, target: 1.0);
  bool removing = false;

  /// Kích hoạt animation xoá (collapse + fade out).
  void remove() {
    removing = true;
    ctrl.animateTo(0.0);
  }
}
