import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double maxLife;
  double size;
  Color color;
  bool alive;

  /// Số điểm tối đa giữ lại trong [trail]. `0` = không vẽ trail.
  /// Emitter set khi muốn effect kiểu comet/streak.
  int maxTrail;

  /// Lịch sử position để vẽ vệt đuôi. Engine tự push mỗi frame nếu
  /// [maxTrail] > 0, và tự trim khi vượt ngưỡng.
  List<Offset>? trail;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    this.maxLife = 1.0,
    required this.size,
    required this.color,
    this.alive = true,
    this.maxTrail = 0,
    this.trail,
  });
}
