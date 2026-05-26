# Particle Engine Workflow

Quy trình xây dựng Particle Engine trong Flutter với hiệu suất cao (60fps, low GC) sử dụng Object Pool và CustomPainter/RenderObject.

## 🌊 Particle Engine trong Flutter

Particle engine = nền tảng cho:
- spark
- fire
- smoke
- ripple
- explosion
- rain
- snow
- magic effect
- background ambient motion

## 🧠 1. Architecture đúng

Production particle engine thường:
`Emitter` → `Particle Pool` → `Physics Update` → `Renderer` → `Compositor`

## 🎯 2. Goal

Bạn muốn:
✅ 60fps
✅ thousands particles
✅ low GC
✅ no rebuild
✅ reusable
✅ timeline support

## 📦 3. Structure

```text
particle_engine/
├── core/
│   ├── particle.dart
│   ├── emitter.dart
│   ├── particle_system.dart
│   └── particle_pool.dart
│
├── physics/
│   ├── gravity.dart
│   ├── velocity.dart
│   └── collision.dart
│
├── render/
│   ├── particle_renderer.dart
│   ├── particle_painter.dart
│   └── particle_layer.dart
│
├── effects/
│   ├── fire.dart
│   ├── smoke.dart
│   ├── sparkle.dart
│   └── explosion.dart
│
└── widgets/
```

## 🧠 4. Particle model

```dart
class Particle {
  double x;
  double y;

  double vx;
  double vy;

  double life;
  double size;

  Color color;

  bool alive;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.size,
    required this.color,
    this.alive = true,
  });
}
```

## ⚡ 5. Particle Pool (QUAN TRỌNG)

❌ đừng tạo particle liên tục.

👉 dùng object pool:

```dart
class ParticlePool {
  final particles = <Particle>[];

  Particle obtain() {
    for (final p in particles) {
      if (!p.alive) {
        p.alive = true;
        return p;
      }
    }

    final p = Particle(
      x: 0,
      y: 0,
      vx: 0,
      vy: 0,
      life: 0,
      size: 0,
      color: Colors.white,
    );

    particles.add(p);

    return p;
  }
}
```

## 🎮 6. Emitter

```dart
class ParticleEmitter {
  final ParticlePool pool;

  ParticleEmitter(this.pool);

  void emit({
    required Offset position,
  }) {
    final p = pool.obtain();

    p.x = position.dx;
    p.y = position.dy;

    p.vx = Random().nextDouble() * 4 - 2;
    p.vy = Random().nextDouble() * -4;

    p.life = 1;
    p.size = 4;
    p.color = Colors.orange;
  }
}
```

## 🌊 7. Physics update

```dart
void updateParticle(
  Particle p,
  double dt,
) {
  p.vy += 300 * dt;

  p.x += p.vx * dt;
  p.y += p.vy * dt;

  p.life -= dt;

  if (p.life <= 0) {
    p.alive = false;
  }
}
```

## 🎨 8. Renderer

👉 dùng: `CustomPainter` hoặc `RenderBox`

### Particle Painter

```dart
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final p in particles) {
      if (!p.alive) continue;

      paint.color = p.color.withOpacity(p.life);

      canvas.drawCircle(
        Offset(p.x, p.y),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
```

## 🚀 9. Animation loop

👉 dùng Ticker:

```dart
late final Ticker ticker;

ticker = createTicker((elapsed) {
  updateParticles();
  setState(() {});
});
```

## ⚡ 10. Nhưng production-level nên:

❌ tránh `setState`
✅ dùng `RenderObject` và `markNeedsPaint()`

## 🧠 11. RenderObject particle layer

Dùng `LeafRenderObjectWidget`
👉 best performance.

## 🌊 12. Timeline integration

Tích hợp với timeline engine đã build.
map particle lifetime (`life = 1 → 0`) thành:
- scale
- fade
- color
- velocity

## 🎬 13. Effects system

- 🔥 **Fire**: upward velocity, orange/red, fade
- ❄️ **Snow**: slow fall, wind sway
- ✨ **Sparkle**: short life, bright, random burst
- 💥 **Explosion**: radial velocity, fast fade

## ⚡ 14. Optimization cực quan trọng

✅ object pool
✅ no allocation per frame
✅ reuse Paint
✅ visibility culling (outside viewport → skip)
✅ batch render

## 🚀 15. GPU-style architecture

`update` → `render buffer` → `paint`

## 🌊 16. Advanced direction

- 🔥 collision: particle ↔ particle
- 🔥 fluid simulation: SPH
- 🔥 shader particles: Fragment shader
- 🔥 mesh particles: GPU mesh rendering

## 🎯 17. Real production usage

Particle engine thường dùng cho:
- pull-to-refresh
- loading
- background motion
- onboarding
- gesture feedback
- map pulse
- success animation

## 🏁 18. Recommended architecture cho bạn

```text
engine/
 ├── particle/
 ├── timeline/
 ├── interaction/
 ├── compositor/
 └── shader/
```
