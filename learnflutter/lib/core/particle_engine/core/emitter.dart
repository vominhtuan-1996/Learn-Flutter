import 'dart:math';
import 'package:flutter/material.dart';
import 'particle_pool.dart';

abstract class ParticleEmitter {
  final ParticlePool pool;
  final Random random = Random();

  ParticleEmitter(this.pool);

  void emit({required Offset position});
}
