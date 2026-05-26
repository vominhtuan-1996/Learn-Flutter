# Quy trình xây dựng Viewport Transform Engine cho Flutter

## 🧠 Tổng quan

Viewport Transform Engine là một **viewport-aware rendering engine** tạo ra:
- TikTok depth effect
- App Store card scaling
- Carousel transform
- CoverFlow
- Reels focus effect
- Viewport-aware animation

### 🎯 Mục tiêu (Goal)
Build một engine hỗ trợ:
- ✅ Scale theo viewport
- ✅ Blur theo distance
- ✅ Opacity transform
- ✅ 3D transform
- ✅ Parallax
- ✅ Velocity-aware
- ✅ Sliver compatible
- ✅ Zero rebuild capable

---

## 🏗️ 1. Core concept

```text
Viewport
    ↓
Item position
    ↓
Distance from center
    ↓
Transform pipeline
    ↓
Paint/render
```

---

## 📦 2. Architecture

```text
engine/
└── viewport_transform/
    ├── core/
    ├── transforms/
    ├── effects/
    ├── interaction/
    ├── compositor/
    ├── sliver/
    ├── physics/
    ├── debug/
    └── widgets/
```

---

## ⚙️ 3. Core structure

`core/`
- `viewport_context.dart`
- `viewport_item.dart`
- `viewport_transform.dart`
- `viewport_pipeline.dart`
- `viewport_controller.dart`

---

## 🧠 4. ViewportContext

```dart
class ViewportContext {
  final double viewportSize;
  final double scrollOffset;
  final double velocity;

  const ViewportContext({
    required this.viewportSize,
    required this.scrollOffset,
    required this.velocity,
  });
}
```

---

## 🎬 5. ViewportItem

```dart
class ViewportItem {
  final int index;
  final double itemOffset;
  final double itemExtent;

  ViewportItem({
    required this.index,
    required this.itemOffset,
    required this.itemExtent,
  });
}
```

---

## 🌊 6. Transform pipeline

```text
distance
   ↓
normalize
   ↓
transform chain
   ↓
render
```

---

## 🚀 7. Core Transform API

```dart
abstract class ViewportTransform {
  void apply(
    TransformState state,
    ViewportItem item,
    ViewportContext context,
  );
}
```

---

## 🎨 8. TransformState

```dart
class TransformState {
  double scale = 1;
  double opacity = 1;
  double translateY = 0;
  double blur = 0;
  double rotation = 0;
}
```

---

## 🔥 9. Scale Transform

```dart
class ScaleTransform extends ViewportTransform {
  final double minScale;

  ScaleTransform({
    this.minScale = 0.8,
  });

  @override
  void apply(
    TransformState state,
    ViewportItem item,
    ViewportContext context,
  ) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final distance = (itemCenter - center).abs();
    
    final normalized = (distance / context.viewportSize).clamp(0.0, 1.0);
    
    state.scale = lerpDouble(1, minScale, normalized)!;
  }
}
```

---

## 🌊 10. Blur Transform

```dart
class BlurTransform extends ViewportTransform {
  @override
  void apply(
    TransformState state,
    ViewportItem item,
    ViewportContext context,
  ) {
    final center = context.scrollOffset + context.viewportSize / 2;
    final itemCenter = item.itemOffset + item.itemExtent / 2;
    final distance = (itemCenter - center).abs();

    state.blur = (distance / 100).clamp(0, 20);
  }
}
```

---

## 🎮 11. Pipeline

```dart
class ViewportPipeline {
  final transforms = <ViewportTransform>[];

  TransformState evaluate(
    ViewportItem item,
    ViewportContext context,
  ) {
    final state = TransformState();

    for (final transform in transforms) {
      transform.apply(state, item, context);
    }

    return state;
  }
}
```

---

## ⚡ 12. Sliver integration

👉 Cực quan trọng.

Sử dụng `RenderSliverMultiBoxAdaptor`.
Mỗi child:
- Compute viewport position
- Apply transform

---

## 🌊 13. Widget structure

`widgets/`
- `viewport_transform_list.dart`
- `viewport_transform_builder.dart`
- `viewport_transform_item.dart`

---

## 🚀 14. Example usage

```dart
ViewportTransformList(
  transforms: [
    ScaleTransform(),
    BlurTransform(),
  ],
)
```

---

## 🎬 15. Effects system

`effects/`
- `depth_effect.dart`
- `carousel_effect.dart`
- `coverflow_effect.dart`
- `tiktok_focus_effect.dart`
- `appstore_effect.dart`

**🔥 TikTok effect**
- Center item -> scale 1.0, opacity 1
- Items xa center -> blur, scale nhỏ, dark overlay

---

## 🌊 16. App Store effect

Card approach center:
- Scale up
- Shadow increase

---

## 🎥 17. 3D transforms

```dart
Matrix4.identity()
  ..setEntry(3, 2, 0.001)
  ..rotateX(rotation)
```

---

## 🚀 18. Velocity-aware transform

Khi scroll fast:
- Reduce blur
- Reduce shader

---

## ⚡ 19. Performance system

- ✅ **Visible only**: Viewport culling
- ✅ **No rebuild**: `markNeedsPaint()`
- ✅ **Layer cache**
- ✅ **Adaptive quality**

---

## 🧠 20. Interaction integration

```text
gesture
   ↓
timeline
   ↓
viewport transform
```

Ví dụ: drag focus, press scale, spring snap.

---

## 🌊 21. Debug tools

`debug/`
- `viewport_bounds.dart`
- `transform_overlay.dart`
- `fps_overlay.dart`
- `visible_items.dart`

---

## 🚀 22. Advanced future direction

- **🔥 GPU shader transform**: Fragment shader blur/distortion.
- **🔥 Physics transform**: Spring scale theo velocity.
- **🔥 AI adaptive transform**: Dynamic motion quality.
- **🔥 Focus-aware feed**: Center item playback priority.

---

## 🎯 23. Real production use

Engine này dùng được cho:
- ✅ TikTok feed
- ✅ Reels
- ✅ App Store cards
- ✅ CoverFlow
- ✅ Carousel
- ✅ Music player
- ✅ Story viewer

---

## 🏁 24. Recommended production structure

`engine/viewport_transform/` như đã nêu ở mục 2.

---

## 🧠 25. Quan trọng nhất

Viewport Transform Engine **không phải** animation widget.

Nó là **viewport-aware rendering engine** gần giống:
- `UICollectionViewLayout` (iOS)
- `RecyclerView LayoutManager` (Android)
- Các hệ thống feed compositor.
