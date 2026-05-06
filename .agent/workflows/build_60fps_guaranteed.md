---
description: Build 60fps guaranteed với 100+ items
---

#1. Bỏ setState + bỏ listener kiểu thường
scrollController.addListener(() {
  setState(() {}); // ❌ giết FPS
});
#2. Dùng SliverList + SliverChildBuilderDelegate (lazy)
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AnimatedListItem(index: index);
        },
        childCount: 100,
      ),
    ),
  ],
)
#3. Viewport-aware progress (không dùng offset global)
double computeProgress(RenderBox box, ScrollableState scrollable) {
  final position = scrollable.position;
  final viewport = position.viewportDimension;

  final offset = box.localToGlobal(Offset.zero).dy;

  final progress = 1 - (offset / viewport);
  return progress.clamp(0.0, 1.0);
}
##mỗi item tự tính progress → không cần controller

#4. Zero rebuild animation (AnimatedBuilder + Listenable merge)
class AnimatedListItem extends StatefulWidget {
  final int index;
  const AnimatedListItem({super.key, required this.index});

  @override
  State createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> {
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _ViewportAwareItem(key: _key),
    );
  }
}

#5. Custom RenderObject (quan trọng nhất)
class ViewportTransform extends SingleChildRenderObjectWidget {
  const ViewportTransform({super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderViewportTransform();
  }
}

class _RenderViewportTransform extends RenderProxyBox {
  double _progress = 0;

  @override
  void paint(PaintingContext context, Offset offset) {
    final scrollable = Scrollable.of(this);
    if (scrollable != null && child != null) {
      final viewport = scrollable.position.viewportDimension;
      final dy = localToGlobal(Offset.zero).dy;

      _progress = (1 - dy / viewport).clamp(0.0, 1.0);

      final scale = 0.9 + 0.1 * _progress;

      final matrix = Matrix4.identity()
        ..translate(offset.dx, offset.dy)
        ..scale(scale);

      context.pushTransform(
        needsCompositing,
        Offset.zero,
        matrix,
        (context, offset) {
          context.paintChild(child!, offset);
        },
      );
    } else {
      super.paint(context, offset);
    }
  }
}

#6. Combine multiple effects (GPU friendly)
final opacity = _progress;
final translateY = (1 - _progress) * 50;

#7. RepaintBoundary chiến lược
RepaintBoundary(
  child: ViewportTransform(
    child: YourItem(),
  ),
)