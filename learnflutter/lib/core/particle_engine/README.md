# Particle Engine

Engine particle 2D viết thuần Flutter — **zero allocation per frame** nhờ pool tái dùng, render trực tiếp ở tầng `RenderBox.paint()` (không qua `setState`/widget tree).

```
lib/core/particle_engine/
├── core/
│   ├── particle.dart          -> Particle (model: x/y/vx/vy/life/size/color/alive)
│   ├── particle_pool.dart     -> ParticlePool (object pool reusable)
│   └── emitter.dart           -> ParticleEmitter (abstract base)
├── physics/
│   ├── gravity.dart           -> GravityPhysics.update()
│   └── velocity.dart          -> VelocityPhysics.update()
├── effects/
│   ├── fire.dart              -> FireEmitter + updateFirePhysics
│   ├── snow.dart              -> SnowEmitter + updateSnowPhysics
│   ├── sparkle.dart           -> SparkleEmitter + updateSparklePhysics
│   └── explosion.dart         -> ExplosionEmitter + updateExplosionPhysics
├── widgets/
│   └── particle_layer.dart    -> ParticleLayer (widget chính)
├── demo/
│   └── particle_demo_screen.dart -> demo trực quan (4 effect)
└── README.md
```

---

## 1. Dùng nhanh

```dart
import 'package:learnflutter/core/particle_engine/widgets/particle_layer.dart';
import 'package:learnflutter/core/particle_engine/effects/fire.dart';

Scaffold(
  backgroundColor: Colors.black,
  body: ParticleLayer(
    poolCapacity: 2000,
    emitterBuilder: (pool) => FireEmitter(pool),
    customPhysicsUpdate: updateFirePhysics,
    autoEmitOnTouch: true,
  ),
);
```

Chạm và kéo trên màn hình → particle emit tại vị trí chạm.

---

## 2. `ParticleLayer`

| Tham số | Kiểu | Mặc định | Ý nghĩa |
|---|---|---|---|
| `emitterBuilder` | `ParticleEmitter Function(ParticlePool)` | **bắt buộc** | Tạo emitter — nhận pool sẵn |
| `customPhysicsUpdate` | `void Function(Particle, double dt)?` | `null` → default (gravity + velocity) | Override logic update từng particle |
| `poolCapacity` | `int` | `1000` | Số particle khởi tạo sẵn trong pool |
| `autoEmitOnTouch` | `bool` | `true` | Tự emit theo `onPanDown/Update`; `false` → tự gọi `emitAt()` |
| `intensity` | `double` | `1.0` | Bội số tần suất emit (`2.0` = 2 lần/frame, `0.25` = 1 lần / 4 frame) |

### State methods (qua `GlobalKey<ParticleLayerState>`)

| Member | Kiểu | Mục đích |
|---|---|---|
| `emitAt(Offset)` | method | Emit 1 burst tại vị trí (dùng khi `autoEmitOnTouch: false`) |
| `clearAll()` | method | Kill toàn bộ particle ngay lập tức |
| `aliveCount` | `ValueNotifier<int>` | Listen để hiển thị counter realtime |

### Emit thủ công

```dart
final layerKey = GlobalKey<ParticleLayerState>();

ParticleLayer(
  key: layerKey,
  emitterBuilder: (pool) => ExplosionEmitter(pool),
  autoEmitOnTouch: false,
);

// Sau đó:
layerKey.currentState?.emitAt(const Offset(200, 300));
```

---

## 3. Effects có sẵn

| Effect | Emitter | Physics | Mô tả |
|---|---|---|---|
| 🔥 Fire | `FireEmitter` | `updateFirePhysics` | 3 hạt/frame bay lên, nhỏ dần ở nửa sau life |
| ❄️ Snow | `SnowEmitter` | `updateSnowPhysics` | Tuyết rơi chậm, drift ngang |
| ✨ Sparkle | `SparkleEmitter` | `updateSparklePhysics` | Pháo bông sáng nhấp nháy |
| 💥 Explosion | `ExplosionEmitter` | `updateExplosionPhysics` | Nổ tỏa tia ra 360° |

Tất cả `*Emitter` đều kế thừa `ParticleEmitter` — chỉ cần override `emit({required Offset position})`.

---

## 4. Tự viết effect mới

```dart
class StarEmitter extends ParticleEmitter {
  StarEmitter(super.pool);

  @override
  void emit({required Offset position}) {
    final p = pool.obtain();          // tái sử dụng từ pool
    p.x = position.dx;
    p.y = position.dy;
    p.vx = random.nextDouble() * 40 - 20;
    p.vy = -random.nextDouble() * 100;
    p.maxLife = 1.5;
    p.life = p.maxLife;
    p.size = 4;
    p.color = Colors.yellow;
  }
}

void updateStarPhysics(p, dt) {
  GravityPhysics.update(p, dt, gravity: 200);
  VelocityPhysics.update(p, dt);
  p.life -= dt;
}
```

Dùng:

```dart
ParticleLayer(
  emitterBuilder: (pool) => StarEmitter(pool),
  customPhysicsUpdate: updateStarPhysics,
)
```

---

## 5. Cách hoạt động

- **`ParticlePool`** preallocate `initialCapacity` `Particle` ngay từ đầu, đánh dấu `alive = false`. Khi cần particle mới, `obtain()` tìm 1 hạt dead (O(n)) và bật `alive = true`. Hết → tạo mới (tránh được trong steady state).
- **`Ticker` của Flutter** drive update với `dt` tự tính — clamp >0.1s để khỏi nhảy sau khi pause.
- **Render**: `_ParticleRenderWidget extends LeafRenderObjectWidget` → `_RenderParticleLayer extends RenderBox`. Mỗi frame `_paintNotifier.notifyListeners()` → `markNeedsPaint()`. Không có rebuild widget tree, không `setState()` cho 1000 particle.
- **Painter**: lặp `_pool.particles`, bỏ qua `!alive`, vẽ `canvas.drawCircle()` với `opacity = life/maxLife`.

---

## 6. Performance tips

- Tăng `poolCapacity` đến mức peak particle thực tế — vượt ngưỡng pool sẽ allocate thêm (chậm).
- Particle quá dày → cân nhắc giảm số hạt/frame trong `emit()`.
- `customPhysicsUpdate` chạy mỗi particle mỗi frame — giữ logic gọn, tránh `new`.
- Pool dùng linear scan tìm slot dead — nếu particle alive ratio cao (>90%), lookup chậm; cân nhắc reset index hint.

---

## 7. Demo trực quan

Mở `ParticleDemoScreen` ([demo/particle_demo_screen.dart](demo/particle_demo_screen.dart)) — 4 nút chuyển đổi Fire / Snow / Sparkle / Explosion realtime, chạm và kéo để bắn hạt.

Route: `Routes.particleEngineDemo` → card "Particle Engine" trong `test_screen.dart`.
