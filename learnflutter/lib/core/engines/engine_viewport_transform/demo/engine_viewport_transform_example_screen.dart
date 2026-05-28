import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/viewport_context.dart';
import '../core/viewport_item.dart';
import '../core/viewport_pipeline.dart';
import '../core/viewport_transform.dart';
import '../transforms/blur_transform.dart';
import '../transforms/elastic_overshoot_transform.dart';
import '../transforms/hue_shift_transform.dart';
import '../transforms/opacity_transform.dart';
import '../transforms/perspective_flip_transform.dart';
import '../transforms/rotation_transform.dart';
import '../transforms/saturation_transform.dart';
import '../transforms/scale_transform.dart';
import '../transforms/shadow_transform.dart';
import '../transforms/skew_transform.dart';
import '../transforms/squeeze_transform.dart';
import '../transforms/stagger_index_transform.dart';
import '../transforms/tint_transform.dart';
import '../transforms/translate_x_transform.dart';
import '../transforms/translate_y_transform.dart';
import '../transforms/velocity_stretch_transform.dart';
import '../transforms/wave_y_transform.dart';

class EngineViewportTransformExampleScreen extends StatefulWidget {
  const EngineViewportTransformExampleScreen({super.key});

  @override
  State<EngineViewportTransformExampleScreen> createState() => _State();
}

class _State extends State<EngineViewportTransformExampleScreen> {
  static const double _itemHeight = 160;
  static const double _itemSpacing = 12;
  static const double _padding = 12;

  final ScrollController _scroll = ScrollController();
  double _scrollOffset = 0;
  double _velocity = 0;
  double _viewportSize = 0;
  Duration _lastTick = Duration.zero;
  double _lastOffset = 0;

  // Toggle state (key → on?)
  final Map<String, bool> _on = {
    'scale': true,
    'elastic': false,
    'squeeze': false,
    'velocityStretch': false,
    'blur': false,
    'opacity': true,
    'saturation': false,
    'hueShift': false,
    'tint': false,
    'rotation': false,
    'flipX': false,
    'flipY': false,
    'skew': false,
    'translateY': false,
    'translateX': false,
    'waveY': false,
    'stagger': false,
    'shadow': false,
  };

  late ViewportPipeline _pipeline = _buildPipeline();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    final now = WidgetsBinding.instance.currentSystemFrameTimeStamp;
    final dt = (now - _lastTick).inMicroseconds / 1e6;
    if (dt > 0) _velocity = (_scroll.offset - _lastOffset) / dt;
    _lastTick = now;
    _lastOffset = _scroll.offset;
    setState(() => _scrollOffset = _scroll.offset);
  }

  ViewportPipeline _buildPipeline() {
    return ViewportPipeline(transforms: [
      if (_on['scale']!) ScaleTransform(minScale: 0.78),
      if (_on['elastic']!) ElasticOvershootTransform(peakScale: 1.12, minScale: 0.85),
      if (_on['squeeze']!) SqueezeTransform(minScaleAcrossAxis: 0.55),
      if (_on['velocityStretch']!) VelocityStretchTransform(),
      if (_on['blur']!) BlurTransform(maxBlur: 8, distanceDivisor: 60),
      if (_on['opacity']!) OpacityTransform(minOpacity: 0.25),
      if (_on['saturation']!) SaturationTransform(minSaturation: 0.0),
      if (_on['hueShift']!) HueShiftTransform(maxHueDegrees: 90),
      if (_on['tint']!) TintTransform(color: Colors.black, maxAlpha: 0.65),
      if (_on['rotation']!) RotationTransform(maxAngleDegrees: 10),
      if (_on['flipX']!) PerspectiveFlipTransform(axis: 'X', maxAngleDegrees: 45),
      if (_on['flipY']!) PerspectiveFlipTransform(axis: 'Y', maxAngleDegrees: 45),
      if (_on['skew']!) SkewTransform(maxSkewY: 0.2),
      if (_on['translateY']!) TranslateYTransform(maxOffset: 40),
      if (_on['translateX']!) TranslateXTransform(maxOffset: 60),
      if (_on['waveY']!) WaveYTransform(amplitude: 22),
      if (_on['stagger']!) StaggerIndexTransform(offsetX: 18, opacityDip: 0.15),
      if (_on['shadow']!) ShadowTransform(),
    ]);
  }

  void _toggle(String k) {
    setState(() {
      _on[k] = !(_on[k] ?? false);
      _pipeline = _buildPipeline();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1220),
        foregroundColor: Colors.white,
        title: const Text('Viewport Transform Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, c) {
                _viewportSize = c.maxHeight;
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: _padding),
                  itemCount: 30,
                  itemExtent: _itemHeight + _itemSpacing,
                  itemBuilder: (_, i) {
                    final item = ViewportItem(
                      index: i,
                      itemOffset: _padding + i * (_itemHeight + _itemSpacing),
                      itemExtent: _itemHeight,
                    );
                    final ctxV = ViewportContext(
                      viewportSize: _viewportSize,
                      scrollOffset: _scrollOffset,
                      velocity: _velocity,
                    );
                    final state = _pipeline.evaluate(item, ctxV);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: _itemSpacing),
                      child: _applyState(state, _card(i)),
                    );
                  },
                );
              },
            ),
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _card(int i) => Container(
        height: _itemHeight,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HSLColor.fromAHSL(1, (i * 30) % 360, 0.6, 0.55).toColor(),
              HSLColor.fromAHSL(1, (i * 30 + 40) % 360, 0.6, 0.45).toColor(),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: Text('Item #$i', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
        ),
      );

  /// Map [TransformState] → widget tree. Thứ tự wrap quan trọng cho composition đúng.
  Widget _applyState(TransformState s, Widget child) {
    Widget w = child;

    // Shadow đổ động — wrap container có boxShadow theo state.
    if (s.shadowSigma > 0.5) {
      w = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: s.shadowSigma,
              offset: Offset(0, s.shadowDy),
            ),
          ],
        ),
        child: w,
      );
    }

    // Hue shift qua ColorFiltered matrix.
    if (s.hueShift.abs() > 0.001) {
      w = ColorFiltered(colorFilter: _hueRotationFilter(s.hueShift), child: w);
    }

    // Saturation qua ColorFiltered matrix (chỉ wrap khi cần — đắt).
    if (s.saturation < 0.999) {
      w = ColorFiltered(colorFilter: _saturationFilter(s.saturation), child: w);
    }

    // Tint overlay
    if (s.tintARGB != null && ((s.tintARGB! >> 24) & 0xff) > 0) {
      w = Stack(children: [
        w,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Color(s.tintARGB!), borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ]);
    }

    // Blur
    if (s.blur > 0.01) {
      w = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: s.blur, sigmaY: s.blur), child: w);
    }

    // 3D matrix: rotationX + rotationY + perspective + 2D rotation + skew + scale
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012) // perspective
      ..rotateX(s.rotationX)
      ..rotateY(s.rotationY)
      ..rotateZ(s.rotation)
      ..scale(s.scale * s.scaleX, s.scale * s.scaleY);
    if (s.skewX != 0 || s.skewY != 0) {
      matrix.multiply(Matrix4(1, s.skewY, 0, 0, s.skewX, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1));
    }

    w = Transform(transform: matrix, alignment: Alignment.center, child: w);
    w = Transform.translate(offset: Offset(s.translateX, s.translateY), child: w);
    w = Opacity(opacity: s.opacity, child: w);
    return w;
  }

  ColorFilter _hueRotationFilter(double rad) {
    final cos = math.cos(rad);
    final sin = math.sin(rad);
    // Standard hue rotation matrix (luminance-preserving).
    const lr = 0.213, lg = 0.715, lb = 0.072;
    return ColorFilter.matrix(<double>[
      lr + cos * (1 - lr) + sin * (-lr), lg + cos * (-lg) + sin * (-lg), lb + cos * (-lb) + sin * (1 - lb), 0, 0,
      lr + cos * (-lr) + sin * 0.143, lg + cos * (1 - lg) + sin * 0.140, lb + cos * (-lb) + sin * (-0.283), 0, 0,
      lr + cos * (-lr) + sin * (-(1 - lr)), lg + cos * (-lg) + sin * lg, lb + cos * (1 - lb) + sin * lb, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  ColorFilter _saturationFilter(double sat) {
    // ITU-R BT.601 luminance weights
    const r = 0.213, g = 0.715, b = 0.072;
    final s = sat;
    final inv = 1 - s;
    return ColorFilter.matrix(<double>[
      r * inv + s, g * inv, b * inv, 0, 0,
      r * inv, g * inv + s, b * inv, 0, 0,
      r * inv, g * inv, b * inv + s, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  Widget _buildControls() {
    return Container(
      color: const Color(0xFF111827),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Transforms (offset: ${_scrollOffset.toStringAsFixed(0)}, v: ${_velocity.toStringAsFixed(0)} px/s)',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in _on.keys) _chip(k),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String k) {
    final on = _on[k] ?? false;
    return GestureDetector(
      onTap: () => _toggle(k),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: on ? const Color(0xFF2563EB) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: on ? const Color(0xFF60A5FA) : Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(on ? Icons.check_circle : Icons.radio_button_unchecked, size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(k, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
