import 'package:flutter/material.dart';
import 'package:learnflutter/core/app/device_dimension.dart';
import 'package:learnflutter/shared/widgets/routes/route.dart';
import 'package:learnflutter/shared/widgets/tap_builder/tap_animated_button_builder.dart';
import 'package:learnflutter/features/material/component/material_lists/model/router_model.dart';
import 'package:learnflutter/shared/widgets/lib/src/utils/utils.dart';
import 'package:learnflutter/core/utils/extension/extension_context.dart';
import 'package:learnflutter/features/material/component/component_material_mixi.dart';
import 'package:learnflutter/features/material/material_screen.dart';
import 'package:learnflutter/features/material/material_screen_detail.dart';

class MaterialListsDetail extends StatefulWidget {
  const MaterialListsDetail({super.key, required this.data});
  final RouterMaterialModel data;
  @override
  State<MaterialListsDetail> createState() => _MaterialListsDetailState();
}

class _MaterialListsDetailState extends State<MaterialListsDetail> with ComponentMaterialDetail {
  final List<RouterModel> routers = [
    RouterModel(
        title: "🚀 1. SliverAppBar biến hình (Collapsing Header Hero)",
        router: Routes.sliverAppbarCollapsingHeaderHero),
    RouterModel(
        title: "🚀 2. SliverPersistentHeader + TabBar pinned",
        router: Routes.sliverAppbarPersistentHeaderTabbar),
    RouterModel(
        title: "🚀 3. SliverAnimatedList với hiệu ứng cuộn thêm",
        router: Routes.sliverAnimationListWrapperExample),
    RouterModel(
        title: "🚀 4. SliverToBoxAdapter với hiệu ứng parallax / sticky info",
        router: Routes.sliverParalaxSticky),
    RouterModel(
        title: "🚀 5. SliverGrid với layout dạng Pinterest / Masonry",
        router: Routes.sliverMasonryGrid),
    RouterModel(
        title: " 🧩 6. SliverFillRemaining với trạng thái Empty", router: Routes.sliverEmptyState),
    RouterModel(
        title: " 🎯 7. CustomSliverHeader có animation scale hoặc opacity",
        router: Routes.sliverHeaderAnimationPage),
    RouterModel(
        title: "🧊 8. SliverFadeOnScroll — làm mờ dần khi cuộn", router: Routes.sliverEffects),
    RouterModel(
        title: "🎙 9. SliverHeader biến thành Floating Action Button",
        router: Routes.sliverCollapseToFAB),
    RouterModel(
        title: "🌀 10. Sliver pull-to-refresh + backdrop blur",
        router: Routes.sliverPullToRefreshPage),
    RouterModel(
        title: "🧾 11. Sliver Timeline View — dạng Facebook timeline",
        router: Routes.sliverTimeLinePage),
    RouterModel(
        title: "🔗 13. SliverSection liên kết với Sidebar / ScrollSpy",
        router: Routes.scrollSpySliverViewExample),
    RouterModel(
        title: "🧲 14. Sliver sticky animation + snapping", router: Routes.stickyHeaderExample),
    RouterModel(
        title: "15. Sliver-based onboarding / intro pages",
        router: Routes.sliverOnboardingWithContentExample),
    RouterModel(
        title: "🧊 22. SliverInteractiveMapSection", router: Routes.sliverMapPreviewExample),
    RouterModel(
        title: "🧊 23 . sliverFadeSearchHeaderExample",
        router: Routes.sliverFadeSearchHeaderExample),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialScreenDetail(
      title: widget.data.title,
      description: widget.data.description,
      contentWidget: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              routers.length,
              (index) {
                return AnimatedTapButtonBuilder(
                  background: context.colorScheme.primaryContainer,
                  child: Text(routers[index].title),
                  onTap: () {
                    // Hapit
                    Navigator.of(context).pushNamed(routers[index].router);
                  },
                ).paddingSymmetric(vertical: DeviceDimension.padding / 2);
              },
            )),
      ),
    );
  }
}
