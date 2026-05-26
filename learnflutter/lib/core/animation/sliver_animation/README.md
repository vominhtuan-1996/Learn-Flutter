# Sliver Animation Engine

1 engine — 1 effect interface — 2 chiến lược tính `progress`. Áp được cho mọi `CustomScrollView` / `Slivers`, ưu tiên 60fps.

## Cấu trúc

```
sliver_animation/
├── sliver_animation.dart           ← barrel (chỉ cần import file này)
├── sliver_effect.dart              ← SliverEffect (abstract) + 5 effect concrete
├── coordinator/                    ← Engine 1: scroll-offset range driven
│   ├── sliver_animation_state.dart       SliverAnimationState (ChangeNotifier, progress 0..1)
│   ├── sliver_animation_coordinator.dart SliverAnimationCoordinator (đăng ký nhiều state theo id)
│   ├── sliver_animated_builder.dart      SliverAnimatedBuilder (rebuild theo state)
│   └── sliver_animated_item.dart         SliverAnimatedItem (wrap SliverToBoxAdapter + effect)
└── viewport/                       ← Engine 2: distance-to-center auto-compute
    ├── viewport_engine.dart        ViewportAnimationConfig (min scale/opacity/translate)
    ├── viewport_aware.dart         ViewportAware + ViewportAwareItem + RenderViewportAware
    └── tiktok_viewport_list.dart   TikTokViewportList (sẵn dùng)
```

```dart
import 'package:learnflutter/core/animation/sliver_animation/sliver_animation.dart';
```

---

## 1. Effects (interface chung)

Mọi effect implement [SliverEffect](sliver_effect.dart):

```dart
abstract class SliverEffect {
  Widget build(BuildContext context, Widget child, double progress);
}
```

Quy ước:
- `progress = 1.0` → trạng thái "đầy đủ" (xuất hiện hoàn toàn / ở tâm viewport).
- `progress = 0.0` → trạng thái "khởi đầu" (chưa xuất hiện / xa tâm).

### 5 effect built-in

| Effect | Tham số | Mặc định | Hành vi |
|---|---|---|---|
| `FadeEffect` | `minOpacity` | `0.0` | Opacity = lerp(minOpacity → 1, progress) |
| `ScaleEffect` | `minScale`, `alignment` | `0.8`, center | Scale = lerp(minScale → 1, progress) |
| `ParallaxEffect` | `maxOffsetY`, `maxOffsetX` | `80`, `0` | Translate = (1-progress) × max |
| `BlurEffect` | `maxBlur` | `10` | Gaussian blur (1-progress) × max |
| `CombinedEffect` | `List<SliverEffect>` | — | Áp dụng các effect theo thứ tự khai báo |

### Ví dụ

```dart
const CombinedEffect([
  FadeEffect(),
  ScaleEffect(minScale: 0.5),
  ParallaxEffect(maxOffsetY: 150),
])
```

### Tự viết effect mới

```dart
class TiltEffect extends SliverEffect {
  final double maxAngle;
  const TiltEffect({this.maxAngle = 0.2});

  @override
  Widget build(BuildContext context, Widget child, double progress) {
    return Transform.rotate(
      angle: (1 - progress) * maxAngle,
      child: child,
    );
  }
}
```

Đặt vào `sliver_effect.dart` cuối file (giữ chung 1 chỗ) hoặc file riêng cùng folder.

---

## 2. Engine A — Coordinator (scroll-offset range)

Dùng khi cần điều khiển chính xác **vùng scroll** nào trigger animation nào (ví dụ: header animate khi scroll 0→200px, hero animate 200→400px…).

```dart
class _MyPageState extends State<MyPage> {
  final _scrollController = ScrollController();
  late final SliverAnimationCoordinator _coordinator;
  late final SliverAnimationState _heroState;

  @override
  void initState() {
    super.initState();
    _coordinator = SliverAnimationCoordinator(_scrollController);
    _heroState = _coordinator.register('hero', start: 0, end: 200);
    _coordinator.attach();
  }

  @override
  void dispose() {
    _coordinator.detach();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAnimatedItem(
          state: _heroState,
          effect: const CombinedEffect([
            FadeEffect(),
            ScaleEffect(minScale: 0.5),
            ParallaxEffect(maxOffsetY: 150),
          ]),
          child: const HeroBanner(),
        ),
        // … sliver khác
      ],
    );
  }
}
```

| API | Mục đích |
|---|---|
| `register(id, start, end)` | Tạo + lưu một `SliverAnimationState` cho 1 vùng scroll |
| `attach()` / `detach()` | Bind listener vào ScrollController (gọi trong initState/dispose) |
| `SliverAnimationState.progress` | Reactive `ChangeNotifier`, value 0..1 |
| `SliverAnimatedItem(state, effect, child)` | Wrap sliver con với effect |
| `SliverAnimatedBuilder(state, builder)` | Builder thủ công nếu cần truy cập progress |

Ưu điểm: rõ ràng, ranges độc lập, dễ debug.
Nhược điểm: rebuild qua widget tree (vẫn tốt cho danh sách trung bình).

---

## 3. Engine B — Viewport (distance-to-center, zero-rebuild)

Dùng khi cần effect kiểu **TikTok / Snapchat reels** — item ở tâm screen "đầy đủ", càng ra rìa càng mờ/nhỏ. Tự tính progress, paint trực tiếp ở RenderObject layer, **không rebuild widget tree** khi cuộn.

### Sẵn dùng

```dart
TikTokViewportList(
  itemCount: 200,
  config: const ViewportAnimationConfig(
    minScale: 0.88,
    minOpacity: 0.25,
    maxTranslateY: 35,
  ),
  itemBuilder: (_, i) => MyCard(index: i),
  onItemVisibilityChanged: (i, visible) => print('$i visible=$visible'),
)
```

### Tự lắp với `ViewportAwareItem`

```dart
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => ViewportAwareItem(
          config: const ViewportAnimationConfig(minScale: 0.9, minOpacity: 0.4),
          child: MyCard(i),
        ),
        childCount: 50,
      ),
    ),
  ],
)
```

### `ViewportAnimationConfig`

| Tham số | Mặc định | Ý nghĩa |
|---|---|---|
| `minScale` | `0.85` | Scale tối thiểu khi ở rìa viewport |
| `minOpacity` | `0.3` | Opacity tối thiểu |
| `maxTranslateY` | `40.0` | Dịch dọc tối đa khi ở rìa |
| `progressThreshold` | `0.01` | Skip repaint nếu thay đổi progress < ngưỡng (tối ưu hiệu năng) |

### Vì sao zero-rebuild?

`RenderViewportAware` (RenderObject riêng) tự đo `localToGlobal` và `viewportDimension` mỗi paint, áp `pushOpacity` + `pushTransform` trực tiếp ở layer. Không có `setState` / `notifyListeners` cho mỗi pixel cuộn → giữ 60fps cho list ngàn item.

---

## 4. So sánh nhanh

| | Coordinator | Viewport |
|---|---|---|
| Progress source | Scroll offset trong range `[start, end]` | Khoảng cách item → tâm viewport |
| Đăng ký | Thủ công per `id` | Tự động per item |
| Hiệu năng | Rebuild via ChangeNotifier | Zero-rebuild, paint layer |
| Phù hợp | Header hero, parallax cố định, onboarding step | Reels, carousel ngang, infinite list |
| Effect | Bất kỳ `SliverEffect` (bao gồm Blur) | Chỉ hardcoded Scale/Opacity/Translate trong `RenderViewportAware` |

> Nếu cần Blur trong viewport engine: hiện tại không hỗ trợ trực tiếp (paint layer không có blur primitive cheap). Workaround: wrap child với `BlurEffect` qua `AnimatedBuilder` + custom progress listener.

---

## 5. Maintenance rules

1. **Effect mới** → thêm vào [sliver_effect.dart](sliver_effect.dart) (giữ 1 chỗ duy nhất), implement `SliverEffect`. Tránh tạo subclass `StatelessWidget` riêng — interface phải đồng nhất.
2. **Coordinator** → luôn cặp `attach()`/`detach()` trong `initState`/`dispose` để không leak listener.
3. **Viewport** → bọc nội dung phức tạp trong `RepaintBoundary` (đã có sẵn trong `ViewportAwareItem`).
4. **`progressThreshold`** → tăng lên `0.05` nếu list rất dài / item rất nặng, giảm xuống `0.005` nếu cần silky smooth.
5. **Không gọi `setState` trong scroll callback** — dùng `ChangeNotifier`/`ValueListenableBuilder` để chỉ rebuild đúng phần cần thiết.

---

## 6. Demo trực quan

| Demo | File | Engine |
|---|---|---|
| Coordinator (header + items với ranges khác nhau) | [sliver_animation_demo_screen.dart](../../../features/test_screen/sliver_animation_demo_screen.dart) | Engine A |
| TikTok feed 200 cards | [tiktok_animation_demo_screen.dart](../../../features/test_screen/tiktok_animation_demo_screen.dart) | Engine B |
