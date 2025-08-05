import 'dart:ui';

import 'package:flutter/material.dart';

class AdvancedBottomSheet extends StatefulWidget {
  const AdvancedBottomSheet({super.key});

  @override
  State<AdvancedBottomSheet> createState() => _AdvancedBottomSheetState();
}

class _AdvancedBottomSheetState extends State<AdvancedBottomSheet> with SingleTickerProviderStateMixin {
  late DraggableScrollableController _sheetController;
  late AnimationController _blurController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _blurController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌫️ Blur nền
        AnimatedBuilder(
          animation: _blurController,
          builder: (_, __) => BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10 * _blurController.value,
              sigmaY: 10 * _blurController.value,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3 * _blurController.value),
            ),
          ),
        ),

        // 📏 Bottom Sheet dạng Snap
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.3, 0.6, 0.9],
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // 🌀 Parallax Header
                  SliverPersistentHeader(
                    delegate: _ParallaxHeader(),
                    pinned: false,
                  ),

                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => ListTile(
                        title: Text('Item #$index'),
                      ),
                      childCount: 20,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ParallaxHeader extends SliverPersistentHeaderDelegate {
  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    final percent = shrinkOffset / maxExtent;
    return Opacity(
      opacity: 1 - percent,
      child: Container(
        height: maxExtent,
        alignment: Alignment.center,
        child: const Text(
          'Parallax Header',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(_) => true;
}
