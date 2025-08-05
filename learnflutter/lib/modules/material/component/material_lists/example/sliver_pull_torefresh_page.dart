import 'package:flutter/material.dart';
import 'package:learnflutter/modules/material/component/material_lists/widgets/sliver_pull_to_refresh_blur.dart';

class SliverPullToRefreshPage extends StatefulWidget {
  const SliverPullToRefreshPage({super.key});

  @override
  State<SliverPullToRefreshPage> createState() => _SliverPullToRefreshPageState();
}

class _SliverPullToRefreshPageState extends State<SliverPullToRefreshPage> {
  double overscroll = 0;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll is OverscrollNotification) {
            setState(() {
              overscroll = (scroll.overscroll + overscroll).clamp(0, 150);
            });
          } else if (scroll is ScrollEndNotification) {
            setState(() => overscroll = 0);
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          edgeOffset: 100,
          displacement: 80,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverBackdropHeader(
                blurAmount: overscroll / 20,
                backgroundColor: Colors.blue,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Pull to Refresh',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ListTile(title: Text('Item \$index')),
                  childCount: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
