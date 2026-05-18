---
description: build 1 base pagination chia làm 3 phần , header , content , footer
---

# 1. Kiến trúc
 ## BasePaginationScaffold
    ├── Header
    ├── PageView Content
    └── Footer
# 2. Structure
 ## pagination/
├── pagination_controller.dart
├── pagination_scaffold.dart
├── pagination_page.dart
└── pagination_layout.dart
# 3. PaginationController
 ## class PaginationController<T> extends ChangeNotifier {
  final items = <T>[];

  final PageController pageController =
      PageController();

  int currentIndex = 0;

  bool loading = false;
  bool hasMore = true;

  final Future<List<T>> Function(int page)
      onLoad;

  PaginationController({
    required this.onLoad,
  });

  Future<void> loadMore() async {
    if (loading || !hasMore) return;

    loading = true;
    notifyListeners();

    final result = await onLoad(currentIndex);

    if (result.isEmpty) {
      hasMore = false;
    } else {
      items.addAll(result);
    }

    loading = false;
    notifyListeners();
  }

  void attach() {
    pageController.addListener(_onScroll);
  }

  void _onScroll() {
    final page = pageController.page ?? 0;

    currentIndex = page.round();

    // preload next
    if (page >= items.length - 2) {
      loadMore();
    }

    notifyListeners();
  }
}
#4. BasePaginationScaffold
class BasePaginationScaffold<T>
    extends StatefulWidget {
  final PaginationController<T> controller;

  final Widget Function(
    BuildContext context,
    int index,
  ) headerBuilder;

  final Widget Function(
    BuildContext context,
    T item,
    int index,
  ) contentBuilder;

  final Widget Function(
    BuildContext context,
    int index,
  ) footerBuilder;

  const BasePaginationScaffold({
    super.key,
    required this.controller,
    required this.headerBuilder,
    required this.contentBuilder,
    required this.footerBuilder,
  });

  @override
  State createState() =>
      _BasePaginationScaffoldState<T>();
}
#5. Core Layout
 class _BasePaginationScaffoldState<T>
    extends State<BasePaginationScaffold<T>> {
  @override
  void initState() {
    super.initState();

    widget.controller.attach();
    widget.controller.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        final current =
            widget.controller.currentIndex;

        return Column(
          children: [
            // HEADER
            widget.headerBuilder(
              context,
              current,
            ),

            // CONTENT
            Expanded(
              child: PageView.builder(
                controller:
                    widget.controller.pageController,
                itemCount:
                    widget.controller.items.length,
                itemBuilder: (_, index) {
                  final item =
                      widget.controller.items[index];

                  return widget.contentBuilder(
                    context,
                    item,
                    index,
                  );
                },
              ),
            ),

            // FOOTER
            widget.footerBuilder(
              context,
              current,
            ),
          ],
        );
      },
    );
  }
}
# 6. Usage

BasePaginationScaffold<Post>(
  controller: controller,

  headerBuilder: (_, index) {
    return HeaderWidget(
      currentIndex: index,
    );
  },

  contentBuilder: (_, item, index) {
    return FeedPage(item: item);
  },

  footerBuilder: (_, index) {
    return FooterIndicator(
      currentIndex: index,
    );
  },
)
# 7. Animation integration (QUAN TRỌNG)
final page =
    controller.pageController.page ?? 0;

final offset = page - index;
#8. Animated content example
final t =
    (1 - offset.abs()).clamp(0.0, 1.0);

return Transform.scale(
  scale: 0.95 + (0.05 * t),
  child: Opacity(
    opacity: t,
    child: child,
  ),
);
#9. Header/Footer dynamic animation
Header collapse
height = 80 * t;
Footer progress
widthFactor = t;
#10. Production upgrades
## 🔥 Sticky header
Positioned(
  top: 0,
)
🔥 Floating footer
Align(
  alignment: Alignment.bottomCenter,
)
🔥 Overlay pagination indicator
1 / 10
🔥 Auto preload media
precacheImage(...)
🔥 Visibility detector

Pause:

video
animation
shader
##
# 11. Advanced layout mode
## Bạn có thể extend:

🔹 Vertical feed
scrollDirection: Axis.vertical
🔹 Horizontal onboarding
scrollDirection: Axis.horizontal
🔹 Hybrid layout
header collapse
footer floating
page parallax 
## 