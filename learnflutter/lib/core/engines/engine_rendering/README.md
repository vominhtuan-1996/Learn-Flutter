# Engine Rendering

Engine custom rendering dựa trên Canvas: cho phép vẽ nhiều **layer** chồng lên nhau, mỗi layer có `update(dt)` riêng và được composite trong một `RenderBox` duy nhất → **không rebuild widget tree** dù animation chạy 60fps.

## Cấu trúc thư mục

```
core/engine_rendering/
├── core/
│   ├── render_layer.dart            # Lớp cơ sở `RenderLayer` (visible, opacity, update, paint)
│   ├── render_layer_controller.dart # `ChangeNotifier` quản lý danh sách layer + tick
│   └── render_pipeline.dart         # Pipeline update → layout → paint (tùy chọn, gọi từ controller)
├── layers/
│   ├── background_layer.dart        # Solid color background
│   ├── gradient_layer.dart          # Radial gradient có tâm di chuyển
│   ├── grid_layer.dart              # Grid trôi dx/dy
│   ├── wave_layer.dart              # Sóng sin chạy ngang
│   ├── glow_layer.dart              # Vòng tròn glow blur
│   ├── pulse_ring_layer.dart        # Radar rings lan ra fade
│   ├── confetti_layer.dart          # Confetti rơi với gió + rotation
│   ├── lightning_layer.dart         # Sét đánh ngẫu nhiên + flash
│   ├── text_layer.dart              # Text HUD/branding overlay
│   └── particle_effect_layer.dart   # Bridge → dùng emitters của core/particle_engine
├── widgets/
│   └── render_layer_view.dart       # `LeafRenderObjectWidget` gắn controller vào tree
└── demo/
    └── engine_rendering_example_screen.dart
```

## Kiến trúc

```
[Widget Tree]
   └─ RenderLayerView (LeafRenderObjectWidget)
        └─ RenderLayerBox (RenderBox)
              └─ paint() → controller.paint(canvas, size)
                              └─ for each visible layer: layer.paint(canvas, size)

[Animation]
   Ticker → controller.update(dt) → markNeedsPaint → frame mới được vẽ
   (widget không rebuild — chỉ RenderBox repaint)
```

## Cách sử dụng

### 1. Tạo controller + Ticker

```dart
class MyState extends State<MyScreen> with SingleTickerProviderStateMixin {
  late final RenderLayerController controller;
  late final Ticker ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    controller = RenderLayerController()
      ..add(BackgroundLayer(color: Colors.black))
      ..add(GlowLayer(radius: 120));

    ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      controller.update(dt);
    })..start();
  }

  @override
  void dispose() {
    ticker.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RenderLayerView(controller: controller);
  }
}
```

### 2. Viết layer tự custom

```dart
class PulseCircleLayer extends RenderLayer {
  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = 40 + math.sin(_t * 2) * 20;
    final paint = Paint()..color = Colors.cyan;
    canvas.drawCircle(size.center(Offset.zero), r, paint);
  }
}
```

Sau đó: `controller.add(PulseCircleLayer())`.

### 3. Toggle / animate properties

Layer là object mutable — sửa field rồi gọi `controller.update(0)` (hoặc đợi tick kế) để repaint:

```dart
glowLayer.radius = 200;
glowLayer.opacity = 0.5;
glowLayer.visible = false;
```

## API chính

### `RenderLayer` (abstract)
| Field / Method | Mô tả |
|---|---|
| `bool visible` | Bỏ qua layer khi false. |
| `double opacity` | < 1.0 → controller dùng `canvas.saveLayer` cho alpha blend toàn layer. |
| `void update(double dt)` | Cập nhật state mỗi tick. |
| `void paint(Canvas, Size)` | Vẽ nội dung. |

### `RenderLayerController extends ChangeNotifier`
| Method | Mô tả |
|---|---|
| `add(layer)` | Thêm vào cuối list (vẽ lên trên cùng). |
| `remove(layer)` | Xoá khỏi list. |
| `clear()` | Xoá tất cả. |
| `update(dt)` | Update tất cả layer + `notifyListeners()` → trigger repaint. |
| `paint(canvas, size)` | Vẽ tất cả layer theo thứ tự thêm vào. |
| `layers` | List bất biến (read-only). |

### `RenderLayerView`
`LeafRenderObjectWidget` nhận `controller`. Gắn vào tree là xong — không có child, không gây layout phức tạp.

### `RenderPipeline` (optional)
Wrapper gọi tuần tự `update → layout → paint`. Hiện chỉ dùng khi cần lifecycle pipeline rõ ràng (ví dụ inject `dt` thủ công ngoài Ticker).

## Layers built-in

| Layer | Param chính | Công dụng |
|---|---|---|
| `BackgroundLayer` | `color` | Fill solid. Đặt làm layer đầu tiên. |
| `GradientLayer` | `colors`, `stops`, `radiusFactor`, `speed`, `orbitRadius` | Radial gradient với tâm quay quỹ đạo — nền aurora/sống động. |
| `GridLayer` | `cellSize`, `color`, `strokeWidth`, `dx`, `dy` | Lưới ô vuông trôi theo dx/dy — background kiểu techy. |
| `WaveLayer` | `color`, `amplitude`, `wavelength`, `speed`, `yFactor`, `fill`, `strokeWidth` | Sóng sin chạy ngang — fill xuống hoặc chỉ line. |
| `GlowLayer` | `position`, `radius`, `color`, `blurSigma` | Vòng tròn blur. `position == Offset.zero` → giữa canvas. |
| `PulseRingLayer` | `color`, `ringCount`, `maxRadius`, `duration`, `strokeWidth`, `center` | Radar/sonar — N ring lan ra từ tâm, fade dần. |
| `ConfettiLayer` | `count`, `colors`, `gravity`, `windAmplitude`, `seed` | Confetti rơi với gió + rotation, loop vô hạn. |
| `LightningLayer` | `color`, `flashColor`, `intervalMin/Max`, `flashDuration`, `segments`, `jitter` | Sét đánh ngẫu nhiên + flash overlay. |
| `TextLayer` | `text`, `style`, `alignment`, `padding`, `textAlign` | Text HUD/branding overlay. |
| `ParticleEffectLayer` | `emitterBuilder`, `poolCapacity`, `intensity`, `emitPosition`, `customPhysicsUpdate`, `autoEmit` | **Bridge** — tái sử dụng toàn bộ emitters của `core/particle_engine` (Fire, Snow, Sparkle, Comet, Confetti, Explosion, Firework, Heart, Rain, Smoke, Vortex, Aura, Bubble, RainbowTrail). |

### Tái sử dụng effects của `particle_engine`

`ParticleEffectLayer` là adapter dùng cho việc dùng lại emitters đã có. Khác với `ParticleLayer` widget (có Ticker + RenderBox riêng), adapter này được drive bởi `RenderLayerController.update` cùng nhịp với mọi layer khác → 1 tick = update toàn bộ engine.

```dart
import 'package:learnflutter/core/particle_engine/effects/fire.dart';
import 'package:learnflutter/core/particle_engine/effects/snow.dart';

final controller = RenderLayerController()
  ..add(BackgroundLayer(color: Colors.black))
  ..add(ParticleEffectLayer(
    emitterBuilder: (pool) => FireEmitter(pool),
    poolCapacity: 400,
    intensity: 1.5,                       // emit/frame
    emitPosition: const Offset(200, 600), // null = giữa canvas
  ))
  ..add(ParticleEffectLayer(
    emitterBuilder: (pool) => SnowEmitter(pool),
    intensity: 1.0,
  ));
```

Burst thủ công khi tap:

```dart
final fire = ParticleEffectLayer(
  emitterBuilder: (pool) => FireworkEmitter(pool),
  intensity: 0, // không auto emit
);
controller.add(fire);

// trong onTapDown:
fire.emitAt(tapPosition);
```

Custom physics:

```dart
ParticleEffectLayer(
  emitterBuilder: (pool) => FireEmitter(pool),
  customPhysicsUpdate: (p, dt) {
    VelocityPhysics.update(p, dt);
    if (p.life < p.maxLife / 2) p.size -= dt * 5;
    p.life -= dt;
  },
)
```

## Performance notes

- **Không rebuild:** `notifyListeners` chỉ trigger `markNeedsPaint`, không invalidate widget tree.
- **`saveLayer` đắt:** chỉ kích hoạt khi `layer.opacity < 1.0` — giữ `opacity = 1.0` khi có thể.
- **`MaskFilter.blur` đắt** (gpu offscreen): hạn chế số `GlowLayer` đồng thời nếu chạy trên thiết bị yếu.
- **`sizedByParent = true`:** `RenderLayerBox` không tự đo size con — layout cost = 0.
- **Pool object:** với particle nhiều phần tử (vd `StarField`), allocate object 1 lần trong constructor, không tạo mới trong `paint`.

## Demo

Xem `demo/engine_rendering_example_screen.dart`:
- Đổi background color
- Slider điều chỉnh `GlowLayer.radius` / `opacity`
- Toggle `OrbitGlow` (glow di chuyển theo quỹ đạo) và `StarField` (80 particle)
