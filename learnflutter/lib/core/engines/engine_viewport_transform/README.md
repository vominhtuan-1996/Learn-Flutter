# Engine Viewport Transform

Pipeline tính toán hiệu ứng (scale/blur/opacity/rotation/translate) **theo vị trí của item so với tâm viewport** trong khi cuộn list. Tách rời logic transform khỏi widget — dễ tổ hợp nhiều effect, dễ viết transform tự custom.

## Cấu trúc thư mục

```
core/engines/engine_viewport_transform/
├── core/
│   ├── viewport_context.dart      # Context cuộn: viewportSize, scrollOffset, velocity
│   ├── viewport_item.dart         # Thông tin item: index, offset, extent
│   ├── viewport_transform.dart    # Abstract `ViewportTransform` + `TransformState`
│   └── viewport_pipeline.dart     # Chạy chuỗi transform tuần tự → output `TransformState`
├── transforms/
│   ├── scale_transform.dart            # Scale uniform theo khoảng cách
│   ├── squeeze_transform.dart          # scaleY shrink ở biên (cover flow vertical)
│   ├── blur_transform.dart             # Blur sigma — auto disable khi velocity cao
│   ├── opacity_transform.dart          # Fade ở biên
│   ├── saturation_transform.dart       # Desaturate về grayscale ở biên
│   ├── tint_transform.dart             # Phủ màu tint alpha tăng theo khoảng cách
│   ├── rotation_transform.dart         # Rotation 2D signed
│   ├── perspective_flip_transform.dart # Rotation 3D rotateX/rotateY (coverflow)
│   ├── skew_transform.dart             # Skew X/Y theo dấu khoảng cách
│   ├── translate_y_transform.dart      # Parallax Y
│   ├── translate_x_transform.dart      # Parallax X
│   ├── z_index_transform.dart          # zIndex cao ở tâm — cho stack overlay
│   ├── wave_y_transform.dart           # Sóng sin chạy dọc list theo scrollOffset + index
│   ├── elastic_overshoot_transform.dart# Bell curve scale, overshoot ở tâm
│   ├── hue_shift_transform.dart        # Dịch hue theo signed distance
│   ├── velocity_stretch_transform.dart # Squash/stretch theo velocity cuộn
│   ├── stagger_index_transform.dart    # So le item lẻ/chẵn
│   └── shadow_transform.dart           # Box shadow đậm ở tâm, nhẹ ở biên
└── demo/
    └── engine_viewport_transform_example_screen.dart
```

## Khái niệm

```
ViewportItem      (vị trí item trong sliver)
       \
        ──► ViewportPipeline ──► TransformState (scale, opacity, blur, rotation, translateY)
       /
ViewportContext   (offset/size/velocity hiện tại của scroll)
```

`TransformState` là **kết quả thuần dữ liệu** — widget tự quyết định map sang `Transform.scale`, `Opacity`, `ImageFiltered`, ... `Pipeline` chỉ tính số, không render.

## Cách sử dụng

### 1. Tạo pipeline

```dart
final pipeline = ViewportPipeline(transforms: [
  ScaleTransform(minScale: 0.8),
  OpacityTransform(minOpacity: 0.3),
  BlurTransform(maxBlur: 10, distanceDivisor: 80),
]);
```

### 2. Trong `ListView.builder`, evaluate mỗi item

```dart
final ctx = ViewportContext(
  viewportSize: viewportHeight,
  scrollOffset: scrollController.offset,
  velocity: currentVelocity,
);

ListView.builder(
  itemExtent: itemHeight + spacing,
  itemBuilder: (context, i) {
    final item = ViewportItem(
      index: i,
      itemOffset: padding + i * (itemHeight + spacing),
      itemExtent: itemHeight,
    );
    final state = pipeline.evaluate(item, ctx);
    return _applyState(state, MyCard(index: i));
  },
);
```

### 3. Map `TransformState` → widget

```dart
Widget _applyState(TransformState s, Widget child) {
  Widget w = child;
  if (s.blur > 0) {
    w = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: s.blur, sigmaY: s.blur), child: w);
  }
  return Transform.translate(
    offset: Offset(0, s.translateY),
    child: Transform.rotate(
      angle: s.rotation,
      child: Transform.scale(
        scale: s.scale,
        child: Opacity(opacity: s.opacity, child: w),
      ),
    ),
  );
}
```

### 4. Viết transform custom

```dart
class HueRotationTransform extends ViewportTransform {
  @override
  void apply(TransformState s, ViewportItem item, ViewportContext ctx) {
    final dist = ((item.itemOffset + item.itemExtent / 2) - (ctx.scrollOffset + ctx.viewportSize / 2)).abs();
    // Lưu vào field tự thêm vào TransformState hoặc tận dụng rotation/blur sẵn có.
    s.rotation = (dist / 200).clamp(0, 0.5);
  }
}
```

## API chính

### `ViewportContext`
| Field | Mô tả |
|---|---|
| `viewportSize` | Chiều cao (vertical scroll) hoặc rộng (horizontal) của viewport. |
| `scrollOffset` | Offset cuộn hiện tại của `ScrollController`. |
| `velocity` | px/s — đo bằng `(offset - lastOffset) / dt` trong scroll listener. |

### `ViewportItem`
| Field | Mô tả |
|---|---|
| `index` | Vị trí trong list. |
| `itemOffset` | Toạ độ bắt đầu của item trên trục cuộn (đã tính padding). |
| `itemExtent` | Chiều dài item trên trục cuộn. |

### `TransformState`
| Field | Default | Ghi chú |
|---|---|---|
| `scale` | `1.0` | scale uniform — nhân vào cả X và Y |
| `scaleX` / `scaleY` | `1.0` | scale theo trục — ghép `Matrix4.scale(scale*scaleX, scale*scaleY)` |
| `opacity` | `1.0` | `Opacity` |
| `translateX` / `translateY` | `0.0` | `Transform.translate` (cộng dồn được) |
| `blur` | `0.0` | sigma cho `ImageFilter.blur` |
| `rotation` | `0.0` | rotation 2D (radian) |
| `rotationX` | `0.0` | rotation 3D quanh trục X (cần perspective entry trong Matrix4) |
| `rotationY` | `0.0` | rotation 3D quanh trục Y (coverflow) |
| `skewX` / `skewY` | `0.0` | skew radian |
| `saturation` | `1.0` | 0 = grayscale — apply qua `ColorFiltered` matrix |
| `tintARGB` | `null` | overlay color (alpha tăng → tint mạnh) |
| `zIndex` | `0.0` | cho list custom dùng Stack để item ở tâm nổi lên |
| `hueShift` | `0.0` | radian dịch hue — apply qua `ColorFiltered` hue rotation matrix |
| `shadowSigma` | `0.0` | blur radius cho `BoxShadow` |
| `shadowDy` | `0.0` | offset Y cho `BoxShadow` |

### `ViewportPipeline`
| Method | Mô tả |
|---|---|
| `evaluate(item, ctx) → TransformState` | Chạy tuần tự `transforms`, mỗi cái sửa trực tiếp `state`. |

## Built-in transforms

| Transform | Param | Hiệu ứng |
|---|---|---|
| `ScaleTransform` | `minScale` | 1.0 ở tâm → `minScale` ở biên. |
| `SqueezeTransform` | `minScaleAcrossAxis` | Bóp `scaleY` ở biên (cover flow vertical). |
| `BlurTransform` | `maxBlur`, `distanceDivisor` | Sigma theo khoảng cách. **Auto disable khi velocity > 2000 px/s.** |
| `OpacityTransform` | `minOpacity` | Fade 1.0 → `minOpacity` ở biên. |
| `SaturationTransform` | `minSaturation` | Desaturate về grayscale dần ở biên (cần `ColorFiltered` matrix). |
| `TintTransform` | `color`, `maxAlpha` | Phủ màu, alpha tăng theo khoảng cách (vd vignette). |
| `RotationTransform` | `maxAngleDegrees` | Xoay 2D signed theo dấu. |
| `PerspectiveFlipTransform` | `maxAngleDegrees`, `axis` ('X'/'Y') | Xoay 3D — coverflow/flip với perspective trong Matrix4. |
| `SkewTransform` | `maxSkewX`, `maxSkewY` | Skew radian theo dấu khoảng cách. |
| `TranslateYTransform` | `maxOffset`, `invert` | Parallax Y. |
| `TranslateXTransform` | `maxOffset`, `invert` | Parallax X. |
| `ZIndexTransform` | `maxZ` | Item ở tâm có `zIndex` cao — dùng với Stack custom. |
| `WaveYTransform` | `amplitude`, `frequency`, `indexPhase` | Sóng sin lan dọc list theo `scrollOffset + index*phase`. |
| `ElasticOvershootTransform` | `peakScale`, `minScale`, `curvePower` | Bell curve — scale > 1 ở tâm (overshoot), giảm về `minScale` ở biên. |
| `HueShiftTransform` | `maxHueDegrees` | Dịch hue signed — item trên/dưới ngả 2 phía hue khác nhau. |
| `VelocityStretchTransform` | `maxStretchY`, `velocityCap` | Squash & stretch — cuộn nhanh → kéo Y, ép X. |
| `StaggerIndexTransform` | `offsetX`, `opacityDip` | So le item lẻ/chẵn theo X + giảm opacity item lệch. |
| `ShadowTransform` | `maxSigma`, `maxDy` | BoxShadow đậm ở tâm (item "bay"), tắt dần ở biên. |

### Map composite — gợi ý wrap order

```dart
Widget _apply(TransformState s, Widget child) {
  Widget w = child;
  if (s.saturation < 1) w = ColorFiltered(colorFilter: _saturationMatrix(s.saturation), child: w);
  if (s.tintARGB != null) w = Stack(children: [w, Positioned.fill(child: ColoredBox(color: Color(s.tintARGB!)))]);
  if (s.blur > 0) w = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: s.blur, sigmaY: s.blur), child: w);

  final m = Matrix4.identity()
    ..setEntry(3, 2, 0.0012)            // perspective cho rotateX/Y
    ..rotateX(s.rotationX)
    ..rotateY(s.rotationY)
    ..rotateZ(s.rotation)
    ..scale(s.scale * s.scaleX, s.scale * s.scaleY);
  w = Transform(transform: m, alignment: Alignment.center, child: w);
  w = Transform.translate(offset: Offset(s.translateX, s.translateY), child: w);
  return Opacity(opacity: s.opacity, child: w);
}
```

## Performance notes

- **Pipeline đánh giá O(N transforms)** mỗi item mỗi frame — giữ số transform ≤ 5, mỗi transform chỉ làm số học cơ bản.
- **Blur cực đắt** (offscreen layer). `BlurTransform` đã tự off khi cuộn nhanh — không xoá guard này.
- **Tránh `Transform.scale(scale: 1.0)`** mọi frame nếu có thể (cost paint vẫn tốn); kiểm tra `s.scale != 1.0` trước khi wrap nếu cần micro-opt.
- Pipeline thuần tính toán, **không gây rebuild list** — chỉ widget của item trong `itemBuilder` rebuild theo scroll, đó là điều mong muốn.

## Demo

Xem `demo/engine_viewport_transform_example_screen.dart` — list 30 card gradient, 5 chip toggle (Scale/Blur/Opacity/Rotation/TranslateY) bật tắt từng transform, có HUD show `scrollOffset` + `velocity` realtime.
