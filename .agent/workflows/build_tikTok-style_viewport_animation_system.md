---
description: Build a TikTok-style viewport animation system
---

#1. Ý tưởng cốt lõi (TikTok behavior)
Mỗi item:

 ## Ở giữa màn hình → scale = 1.0, opacity = 1.0
 ## Xa dần → scale ↓, opacity ↓
 ## Ra khỏi viewport → gần như invisible

 ###Công thức:
distanceFromCenter = |itemCenter - viewportCenter|
normalized = distance / viewportHeight
progress = 1 - normalized

#2. Widget API (reusable)
TikTokViewportList(
  itemBuilder: (context, index) => YourItem(),
  itemCount: 200,
)
#3. Core widget
class TikTokViewportList extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;

  const TikTokViewportList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _ViewportItem(
                child: itemBuilder(context, index),
              );
            },
            childCount: itemCount,
          ),
        ),
      ],
    );
  }
}
#4. Viewport-aware RenderObject (quan trọng nhất)
class ViewportAware extends SingleChildRenderObjectWidget {
  const ViewportAware({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderViewportAware();
  }
}
 ## Render logic (60fps key)
class _RenderViewportAware extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    final scrollable = Scrollable.of(this);
    if (scrollable == null || child == null) {
      super.paint(context, offset);
      return;
    }

    final viewportHeight = scrollable.position.viewportDimension;

    final globalTop = localToGlobal(Offset.zero).dy;
    final itemHeight = size.height;
    final itemCenter = globalTop + itemHeight / 2;

    final viewportCenter = viewportHeight / 2;

    final distance = (itemCenter - viewportCenter).abs();

    final normalized = (distance / viewportHeight).clamp(0.0, 1.0);
    final progress = 1 - normalized;

    // 🎨 Effects
    final scale = 0.85 + 0.15 * progress;
    final opacity = progress.clamp(0.3, 1.0);
    final translateY = (1 - progress) * 40;

    final matrix = Matrix4.identity()
      ..translate(offset.dx, offset.dy + translateY)
      ..scale(scale);

    context.pushOpacity(
      offset,
      (opacity * 255).toInt(),
      (context, offset) {
        context.pushTransform(
          needsCompositing,
          Offset.zero,
          matrix,
          (context, offset) {
            context.paintChild(child!, offset);
          },
        );
      },
    );
  }
}
#5. Wrapper widget
class _ViewportItem extends StatelessWidget {
  final Widget child;

  const _ViewportItem({required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ViewportAware(
        child: child,
      ),
    );
  }
}

#7. Nâng cấp PRO

#1. Snap to center (rất quan trọng)
void snapToNearest(ScrollController controller, double itemHeight) {
  final offset = controller.offset;
  final target = (offset / itemHeight).round() * itemHeight;

  controller.animateTo(
    target,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}
#2. Velocity-aware (xịn hơn TikTok)
#3. Blur + depth effect
final blur = (1 - progress) * 10;
#4. Z-index (center item nổi lên)
context.pushLayer(...)

##1. Đóng gói thành package 
 
sliver_animation/
 ├── core/
 │    ├── viewport_engine.dart
 │    ├── render_viewport_aware.dart
 │
 ├── effects/
 │    ├── fade.dart
 │    ├── scale.dart
 │    ├── parallax.dart
 │    ├── blur.dart
 │
 ├── widgets/
 │    ├── sliver_animated_item.dart
 │    ├── tiktok_viewport_list.dart
 │
 └── sliver_animation.dart

#2. Tách config thành system (đừng hardcode)
Hiện tại bạn có kiểu:

scale = 0.85 + 0.15 * progress;

👉 refactor thành:

class ViewportAnimationConfig {
  final double minScale;
  final double maxTranslate;
  final double minOpacity;

  const ViewportAnimationConfig({
    this.minScale = 0.85,
    this.maxTranslate = 40,
    this.minOpacity = 0.3,
  });
}
#3. Cache transform (tránh repaint dư)
if ((progress - _lastProgress).abs() < 0.01) return;
#4. Thêm visibility detection (critical)
final isVisible = progress > 0.01;
5. Hook lifecycle cho item
typedef VisibilityCallback = void Function(bool visible);
if (isVisible != _lastVisible) {
  onVisibilityChanged?.call(isVisible);
}
Preload item kế tiếp (pro UX)
if (progress > 0.8) {
  preload(index + 1);
}
7. Image & video optimization

Nếu bạn không làm cái này → mọi animation vô nghĩa

✅ Image
dùng cacheWidth
precacheImage
✅ Video
reuse player
preload next
pause ngoài viewport

10. API hoàn chỉnh (đề xuất)

TikTokViewportList(
  itemCount: 200,
  config: ViewportAnimationConfig(
    minScale: 0.9,
    maxTranslate: 30,
  ),
  onItemVisibilityChanged: (index, visible) {
    // play / pause video
  },
  onItemNearCenter: (index) {
    // preload next
  },
  itemBuilder: ...
)