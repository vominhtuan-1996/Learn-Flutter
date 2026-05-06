import 'package:flutter/widgets.dart';
import '../core/render_viewport_aware.dart';
import '../core/viewport_engine.dart';

/// TikTok-style viewport list.
/// Mỗi item tự tính toán progress dựa trên khoảng cách tới tâm viewport.
/// Item ở giữa màn hình → scale/opacity cực đại.
/// Item xa tâm → scale/opacity giảm dần.
class TikTokViewportList extends StatefulWidget {
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ViewportAnimationConfig config;
  final void Function(int index, bool visible)? onItemVisibilityChanged;

  const TikTokViewportList({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.config = ViewportAnimationConfig.defaultConfig,
    this.onItemVisibilityChanged,
  });

  @override
  State<TikTokViewportList> createState() => _TikTokViewportListState();
}

class _TikTokViewportListState extends State<TikTokViewportList> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ViewportAwareItem(
                config: widget.config,
                onVisibilityChanged: widget.onItemVisibilityChanged != null
                    ? (visible) => widget.onItemVisibilityChanged!(index, visible)
                    : null,
                child: widget.itemBuilder(context, index),
              );
            },
            childCount: widget.itemCount,
          ),
        ),
      ],
    );
  }
}
