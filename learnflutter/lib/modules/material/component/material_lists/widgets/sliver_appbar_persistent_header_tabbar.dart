import 'package:flutter/material.dart';

class SliverAppbarPersistentHeaderTabbar extends StatefulWidget {
  const SliverAppbarPersistentHeaderTabbar({super.key});
  @override
  State<SliverAppbarPersistentHeaderTabbar> createState() =>
      _SliverAppbarPersistentHeaderTabbarState();
}

class _SliverAppbarPersistentHeaderTabbarState extends State<SliverAppbarPersistentHeaderTabbar>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final tabs = const [
    Tab(text: 'Overview'),
    Tab(text: 'Details'),
    Tab(text: 'Reviews'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: tabs,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.deepPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Product Name'),
                background: Image.network(
                  'https://images.unsplash.com/photo-1503264116251-35a269479413?auto=format&fit=crop&w=1000&q=80',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(child: _buildTabBar(), height: kToolbarHeight),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent('Overview Content'),
              _buildTabContent('Details Content'),
              _buildTabContent('Reviews Content'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String title) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('$title - Item ${i + 1}', style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverTabBarDelegate({required this.child, required this.height});

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
