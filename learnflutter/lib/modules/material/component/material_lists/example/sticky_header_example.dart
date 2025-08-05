import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/animated_sticky_header.dart';

class StickyHeaderExample extends StatelessWidget {
  const StickyHeaderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Sliver Sticky Header'),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            floating: true,
            delegate: AnimatedStickyHeader(
              title: '🔥 Mục nổi bật',
              maxExtentHeight: 120,
              minExtentHeight: 60,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Item #$index'),
              ),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}
