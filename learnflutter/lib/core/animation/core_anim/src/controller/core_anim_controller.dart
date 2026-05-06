import 'dart:math';

/// Spring-based animation controller.
/// Mô phỏng vật lý lò xo (spring physics) để tạo chuyển động tự nhiên.
class CoreAnimController {
  double value;
  double target;
  double velocity;

  CoreAnimController({
    this.value = 1.0,
    this.target = 1.0,
    this.velocity = 0.0,
  });

  /// Di chuyển animation tới giá trị [t] bằng lực lò xo.
  void animateTo(double t) {
    target = t;
  }

  /// Cập nhật mỗi frame với delta time [dt] (giây).
  /// Spring stiffness = 300, damping = 20.
  void update(double dt) {
    if (dt <= 0) return;
    const k = 300.0; // stiffness
    const d = 20.0;  // damping

    final force = k * (target - value);
    velocity += force * dt;
    velocity *= exp(-d * dt);
    value += velocity * dt;
  }

  /// Kiểm tra animation đã ổn định chưa (gần target, velocity nhỏ).
  bool get isSettled =>
      (value - target).abs() < 0.001 && velocity.abs() < 0.001;
}

/// Extension API tiện lợi cho tap interactions.
extension CoreAnimControllerX on CoreAnimController {
  void press() => animateTo(0.0);
  void release() => animateTo(1.0);
  void toggle() => animateTo(value > 0.5 ? 0.0 : 1.0);
}
