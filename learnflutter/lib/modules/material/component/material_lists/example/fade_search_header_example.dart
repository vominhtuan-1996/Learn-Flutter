import 'package:flutter/material.dart';
import 'package:learnflutter/app/device_dimension.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/sliver_fade_search_header.dart';

class FadeSearchBarSliverExample extends StatefulWidget {
  const FadeSearchBarSliverExample({super.key});

  @override
  State<FadeSearchBarSliverExample> createState() => _FadeSearchBarSliverExampleState();
}

class _FadeSearchBarSliverExampleState extends State<FadeSearchBarSliverExample> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearchIcon = false;
  bool _forceShowSearchBar = false;

  void _handleScroll() {
    final offset = _scrollController.offset;
    final shouldShowIcon = offset > 100 && !_forceShowSearchBar;

    if (shouldShowIcon != _showSearchIcon) {
      setState(() {
        _showSearchIcon = shouldShowIcon;
      });
    }
  }

  void _toggleSearchBar() {
    setState(() {
      _forceShowSearchBar = !_forceShowSearchBar;
      if (_forceShowSearchBar) {
        _showSearchIcon = false;
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = _forceShowSearchBar ? 1.0 : (_scrollController.hasClients ? (1.0 - (_scrollController.offset / 100)).clamp(0.0, 1.0) : 1.0);
    final FocusNode _focusNode = FocusNode();
    final TextEditingController _textController = TextEditingController();
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: FlexibleSearchHeader(
              maxExtentHeight: 120,
              minExtentHeight: DeviceDimension.appBar,
              controller: _textController,
              focusNode: _focusNode,
              onSearchIconPressed: () {},
              showSearchIcon: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                title: Text('Item #$index'),
              ),
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}

class FlexibleSearchHeader extends SliverPersistentHeaderDelegate {
  final double maxExtentHeight;
  final double minExtentHeight;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSearchIconPressed;
  final bool showSearchIcon;

  FlexibleSearchHeader({
    required this.maxExtentHeight,
    required this.minExtentHeight,
    required this.controller,
    required this.focusNode,
    required this.onSearchIconPressed,
    required this.showSearchIcon,
    this.hintText = 'Tìm kiếm...',
  });

  @override
  double get minExtent => minExtentHeight;

  @override
  double get maxExtent => maxExtentHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtentHeight - minExtentHeight)).clamp(0.0, 1.0);
    final scale = 1.0 - (0.3 * progress);

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            backgroundColor: Colors.white,
            // automaticallyImplyLeading: false,
            title: const Text('Flexible Search Header'),
            actions: [
              if (showSearchIcon)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: onSearchIconPressed,
                ),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.bottomCenter,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: hintText,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant FlexibleSearchHeader oldDelegate) => true;
}
