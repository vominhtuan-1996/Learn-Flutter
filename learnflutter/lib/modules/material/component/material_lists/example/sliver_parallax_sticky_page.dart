import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/parallax_image.dart';

class SliverParallaxStickyPage extends StatelessWidget {
  const SliverParallaxStickyPage({super.key});

  @override
  Widget build(BuildContext context) {
    const double imageHeight = 300;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Optional: App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 80,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Product Page'),
            ),
          ),

          // Parallax effect
          SliverToBoxAdapter(
            child: ParallaxImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1503264116251-35a269479413?auto=format&fit=crop&w=1000&q=80',
              height: imageHeight,
            ),
          ),

          // Sticky Info Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyInfoHeaderDelegate(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Thông tin sản phẩm 1',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              height: 60,
            ),
          ),

          // Content
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Chi tiết #$index'),
              ),
              childCount: 30,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyInfoHeaderDelegate(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Thông tin sản phẩm 2',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              height: 60,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Chi tiết #$index'),
              ),
              childCount: 30,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyInfoHeaderDelegate(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Thông tin sản phẩm 3',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              height: 60,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Chi tiết #$index'),
              ),
              childCount: 30,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyInfoHeaderDelegate(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Thông tin sản phẩm 4',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              height: 60,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Chi tiết #$index'),
              ),
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyInfoHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyInfoHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StickyInfoHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
